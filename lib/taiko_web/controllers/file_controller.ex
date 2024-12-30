defmodule TaikoWeb.FileController do
  use TaikoWeb, :controller

  alias Taiko.MediaLibrary.Song
  alias Taiko.Repo

  def show(conn, %{"token" => token}) do
    result = Phoenix.Token.decrypt(conn, "file", token, max_age: :timer.minutes(1))

    case result do
      {:ok, %{vsn: 1, uuid: id}} ->
        song = Repo.get!(Song, id)
        do_send_file(conn, song.file_path)

      _ ->
        send_resp(conn, :unauthorized, "")
    end
  end

  defp do_send_file(conn, path) do
    conn
    |> put_resp_content_type(MIME.from_path(path))
    |> put_resp_header("accept-ranges", "bytes")
    |> send_file(200, path)
  end
end
