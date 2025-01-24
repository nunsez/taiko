defmodule Taiko.Listener do
  use GenServer

  alias Taiko.MediaLibrary

  @run_cmd :run_sync

  @default_interval :timer.seconds(5)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: args[:dirs] || [])

    state = %{
      watcher_pid: watcher_pid,
      interval: args[:interval] || @default_interval,
      buffer: make_buffer()
    }

    FileSystem.subscribe(state.watcher_pid)
    run_after_delay(state)

    {:ok, state}
  end

  def handle_info(@run_cmd, %{buffer: buffer} = state) do
    start_job(fn -> MediaLibrary.delete(MapSet.to_list(buffer[:delete])) end)
    start_job(fn -> MediaLibrary.update(MapSet.to_list(buffer[:update])) end)
    start_job(fn -> MediaLibrary.create(MapSet.to_list(buffer[:create])) end)
    run_after_delay(state)
    {:noreply, flush(state)}
  end

  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid} = state) do
    events = MapSet.new(events)

    cond do
      member?(events, [:deleted, :moved_from]) ->
        {:noreply, update_buffer(state, :delete, path)}

      member?(events, [:created, :moved_to]) ->
        {:noreply, update_buffer(state, :create, path)}

      member?(events, [:modified]) ->
        {:noreply, update_buffer(state, :update, path)}

      true ->
        {:noreply, state}
    end
  end

  # fallback
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def start_job(f) when is_function(f, 0) do
    Task.Supervisor.async(Taiko.ListenerSupervisor, fn -> f.() end)
  end

  defp member?(%MapSet{} = incoming_events, wanted_events) do
    Enum.any?(wanted_events, fn wanted -> MapSet.member?(incoming_events, wanted) end)
  end

  defp make_buffer do
    %{
      delete: MapSet.new(),
      create: MapSet.new(),
      update: MapSet.new()
    }
  end

  defp update_buffer(%{buffer: buffer} = state, event, path) do
    buffer = Map.update!(buffer, event, fn set -> MapSet.put(set, path) end)
    %{state | buffer: buffer}
  end

  defp flush(state) do
    %{state | buffer: make_buffer()}
  end

  defp run_after_delay(%{interval: interval}) do
    Process.send_after(self(), @run_cmd, interval)
  end
end
