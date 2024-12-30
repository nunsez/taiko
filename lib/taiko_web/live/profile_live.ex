defmodule TaikoWeb.ProfileLive do
  use TaikoWeb, :live_view

  alias Taiko.Repo
  alias Taiko.MediaLibrary.Song

  def render(assigns) do
    ~H"""
    <div>
      <h1>Profile Live</h1>

      <ul>
        <%= for song <- @songs do %>
          <li phx-click={JS.push("play", value: %{id: song.id})}>
            {song.name}
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    songs = Repo.all(Song)
    socket = assign(socket, songs: songs)
    {:ok, socket, []}
  end

  def handle_event("play", %{"id" => id}, socket) do
    song = Repo.get!(Song, id)
    {:noreply, play_song(socket, song)}
  end

  def play_song(socket, %Song{} = song) do
    socket
    |> push_play(song)
  end

  defp push_play(socket, %Song{} = song) do
    token =
      Phoenix.Token.encrypt(socket.endpoint, "file", %{
        vsn: 1,
        uuid: song.id
      })

    push_event(socket, "play2", %{token: token})
  end
end
