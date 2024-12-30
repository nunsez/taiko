defmodule Mix.Tasks.MediaSync do
  alias Taiko.Repo
  alias Taiko.MediaLibrary.Song

  @root Path.expand("~/Music")

  @formats ["mp3", "m4a", "wav", "flac", "ogg"]

  def run(_args) do
    # Mix.Task.run "app.start"
    Application.ensure_all_started(:taiko)
    Enum.each(files(), &handle_file/1)
  end

  def files do
    formats = Enum.join(@formats, ",")
    wildcard = Path.join(@root, ["**/*", "{", formats, "}"])
    Path.wildcard(wildcard)
  end

  def handle_file(file_path) do
    with {:ok, stat} <- File.stat(file_path),
         :ok <- check_stat(stat),
         {:ok, content} <- File.read(file_path) do
      content_hash = hash(content)
      file_path_hash = hash(file_path)

      attrs = %{
        name: file_path,
        content_hash: content_hash,
        file_path: file_path,
        file_path_hash: file_path_hash,
        file_size: stat.size
      }

      sync(attrs)
    end
  end

  def sync(attrs) do
    case Repo.get_by(Song, content_hash: attrs[:content_hash]) do
      nil ->
        case Repo.get_by(Song, file_path_hash: attrs[:file_path_hash]) do
          nil -> insert(attrs)
          song -> update(song, attrs)
        end

      song ->
        update(song, attrs)
    end
  end

  def check_stat(stat) do
    if stat.type == :regular and stat.access in [:read, :read_write] do
      :ok
    else
      {:error, :invalid_stat}
    end
  end

  def hash(data) do
    :crypto.hash(:md5, data)
    |> Base.encode16(case: :lower)
  end

  def update(song, attrs) do
    changeset = Song.changeset(song, attrs)

    case Repo.update(changeset) do
      {:ok, _} -> :ok
      {:error, _} -> :error
    end
  end

  def insert(attrs) do
    changeset = Song.changeset(%Song{}, attrs)

    case Repo.insert(changeset) do
      {:ok, _} -> :ok
      _ -> :error
    end
  end
end
