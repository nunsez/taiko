defmodule Mix.Tasks.MediaSync do
  alias Taiko.MediaLibrary.SongArtist
  alias Ecto.Multi
  alias Taiko.MediaLibrary.Artist
  alias Taiko.TagReader
  alias Taiko.Repo
  alias Taiko.MediaLibrary.Song

  import Ecto.Query

  @root Path.expand("~/Music")

  @formats ["mp3", "m4a", "wav", "flac", "ogg"]

  def run(_args) do
    # Mix.Task.run "app.start"
    Application.ensure_all_started(:taiko)

    added_hashes =
      files()
      |> Stream.map(&handle_file/1)
      |> Stream.filter(&success?/1)
      |> Stream.map(fn {:ok, data} -> data.insert_or_update_song.md5_hash end)
      |> Enum.to_list()

    cleanup(added_hashes)
  end

  def success?({:ok, _data}), do: true
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
      artist_names = List.wrap(tag.artist)

      Multi.new()
      |> sync_artists(artist_names)
      |> sync_song(attrs)
      |> sync_song_artists(artist_names)
      |> Repo.transaction()
    end
  end

  def sync_song(multi, attrs) do
    md5_hash = attrs[:md5_hash]

    changeset =
      md5_hash
      |> get_song()
      |> Song.changeset(attrs)

    Multi.insert_or_update(multi, :insert_or_update_song, changeset)
  end

  def sync_artists(multi, artist_names) do
    Enum.reduce(artist_names, multi, fn name, multi ->
      changeset = get_artist(name) |> Artist.changeset(%{})
      Multi.insert_or_update(multi, {:artist, name}, changeset)
    end)
  end

  def sync_song_artists(multi, artist_names) do
    multi =
      Multi.delete_all(
        multi,
        :delete_all_song_artists,
        fn %{insert_or_update_song: song} ->
          where(SongArtist, [sa], sa.song_id == ^song.id)
        end
      )

    Enum.reduce(artist_names, multi, fn name, multi ->
      Multi.insert(multi, {:insert_song_artist, name}, fn data ->
        artist = data[{:artist, name}]
        song = data.insert_or_update_song
        # TODO: use changeset
        %SongArtist{artist_id: artist.id, song_id: song.id}
      end)
    end)
  end

  def get_artist(name) do
    case Repo.get_by(Artist, name: name) do
      nil -> %Artist{name: name}
      artist -> artist
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
    Song
    |> where([s], s.md5_hash not in ^hashes)
    |> Repo.delete_all()
  end
end
