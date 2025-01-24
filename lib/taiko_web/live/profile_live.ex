defmodule TaikoWeb.ProfileLive do
  use TaikoWeb, :live_view

  alias Taiko.Accounts
  alias Taiko.MediaLibrary.Song
  alias Taiko.Repo

  def render(assigns) do
    ~H"""
    <div>
      <h1>Profile Live</h1>

      <ul>
        <%= for {_id, song} <- @streams.songs do %>
          <li phx-click={JS.push("play", value: %{id: song.id})}>
            {song.name}
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      Accounts.subscribe(current_user.id)
    end

    songs = Repo.all(Song)
    socket = stream(socket, :songs, songs)
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

  def handle_info({Accounts, :library_update}, socket) do
    songs = Repo.all(Song)
    socket = stream(socket, :songs, songs)
    {:noreply, socket}
  end
end
