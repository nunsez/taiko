defmodule TaikoWeb.PlayerLive do
  use TaikoWeb, :live_view

  alias Taiko.Repo
  alias Taiko.MediaLibrary.Song
  alias TaikoWeb.ProfileLive

  def render(assigns) do
    ~H"""
    <div id="audio-player" phx-hook="AudioPlayer">
      <div class="flex justify-center">
        <div><audio controls></audio></div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end

  def handle_event("next_song_auto", _unsigned_params, socket) do
    import Ecto.Query

    song =
      Song
      |> order_by(fragment("RANDOM()"))
      |> limit(1)
      |> Repo.one!

    {:noreply, ProfileLive.play_song(socket, song)}
  end
end
