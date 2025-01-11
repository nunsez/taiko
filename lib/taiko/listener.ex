defmodule Taiko.Listener do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)
    {:ok, processor_pid} = Taiko.Listener.Processor.start_link(args)
    state = %{watcher_pid: watcher_pid, processor_pid: processor_pid}
    FileSystem.subscribe(state.watcher_pid)
    {:ok, state}
  end

  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid} = state) do
    events = MapSet.new(events)

    cond do
      member?(events, [:deleted, :moved_from]) ->
        send(state, :delete, path)

      member?(events, [:created, :moved_to]) ->
        send(state, :create, path)

      member?(events, [:modified]) ->
        send(state, :update, path)
    end

    {:noreply, state}
  end

  def send(state, event, path) do
    GenServer.cast(state.processor_pid, {event, path})
  end

  def member?(%MapSet{} = incoming_events, wanted_events) do
    wanted_events
    |> Enum.any?(fn wanted -> MapSet.member?(incoming_events, wanted) end)
  end
end

defmodule Taiko.Listener.Processor do
  use GenServer

  @run_cmd :run_sync

  @default_interval :timer.seconds(5)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    state = %{
      buffer: make_buffer(),
      interval: args[:inverval] || @default_interval
    }

    Process.send_after(self(), @run_cmd, state.interval)

    {:ok, state}
  end

  def handle_cast({event, path}, state) when event in [:delete, :create, :update] do
    {:noreply, add!(state, event, path)}
  end

  def handle_info(@run_cmd, state) do
    Process.send_after(self(), @run_cmd, state.interval)
    {:noreply, flush(state)}
  end

  defp make_buffer do
    %{
      delete: MapSet.new(),
      create: MapSet.new(),
      update: MapSet.new(),
    }
  end

  defp flush(state) do
    %{state | buffer: make_buffer()}
  end

  defp add!(%{buffer: buffer} = state, event, path) do
    buffer = Map.update!(buffer, event, fn set -> MapSet.put(set, path) end)
    %{state | buffer: buffer}
  end
end
