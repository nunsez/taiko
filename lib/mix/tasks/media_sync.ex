defmodule Mix.Tasks.MediaSync do
  alias Taiko.TagReader
  alias Taiko.Repo
  alias Taiko.MediaLibrary.Song

  @root Path.expand("~/Music")

  @formats ["mp3", "m4a", "wav", "flac", "ogg"]

  def run(_args) do
    # Mix.Task.run "app.start"
    Application.ensure_all_started(:taiko)

    added_hashes =
      files()
      |> Stream.map(&handle_file/1)
      |> Stream.filter(&success?/1)
      |> Stream.map(fn {:ok, md5_hash} -> md5_hash end)
      |> Enum.to_list()

    cleanup(added_hashes)
  end

  def success?({:ok, _md5_hash}), do: true
  def success?(_), do: false

  def files do
    formats = Enum.join(@formats, ",")
    wildcard = Path.join(@root, ["**/*", "{", formats, "}"])
    Path.wildcard(wildcard)
  end

  def handle_file(file_path) do
    with {:ok, stat} <- File.stat(file_path),
         :ok <- check_stat(stat),
         {:ok, tag} <- TagReader.read_file(file_path) do
      attrs = Song.from_file(file_path, stat, tag)
      sync(attrs)
    end
  end

  def sync(attrs) do
    md5_hash = attrs[:md5_hash]

    result =
      md5_hash
      |> get_song()
      |> Song.changeset(attrs)
      |> Repo.insert_or_update()

    case result do
      {:ok, _} -> {:ok, md5_hash}
      error -> error
    end
  end

  def get_song(md5_hash) do
    case Repo.get_by(Song, md5_hash: md5_hash) do
      nil -> %Song{md5_hash: md5_hash}
      song -> song
    end
  end

  def check_stat(stat) do
    if stat.type == :regular and stat.access in [:read, :read_write] do
      :ok
    else
      {:error, :invalid_stat}
    end
  end

  def cleanup(hashes) do
    import Ecto.Query

    Song
    |> where([s], s.md5_hash not in ^hashes)
    |> Repo.delete_all()
  end
end
