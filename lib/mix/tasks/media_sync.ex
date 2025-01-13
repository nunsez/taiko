defmodule Mix.Tasks.MediaSync do
  alias Taiko.MediaLibrary.Artist
  alias Taiko.MediaLibrary.Song
  alias Taiko.MediaLibrary.SongArtist
  alias Taiko.TagReader
  alias Taiko.Repo

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
      artist_names = List.wrap(tag.artist)

      Repo.transaction(fn ->
        case sync(attrs, artist_names) do
          {:ok, md5_hash} -> md5_hash
          error -> Repo.rollback(error)
        end
      end)
    end
  end

  def sync(attrs, artist_names) do
    with {:ok, artists} <- sync_artists(artist_names),
         {:ok, song} <- sync_song(attrs),
         {:ok, _} <- sync_song_artists(song, artists) do
      {:ok, song.md5_hash}
    end
  end

  def check_list(list) do
    {status, list} =
      Enum.reduce(list, {:ok, []}, fn
        {:ok, value}, {:ok, acc} -> {:ok, [value | acc]}
        {_, value}, {_, acc} -> {:error, [value | acc]}
      end)

    {status, Enum.reverse(list)}
  end

  def sync_artists(artist_names) do
    artist_names
    |> Enum.map(&sync_artist/1)
    |> check_list()
  end

  def sync_artist(artist_name) do
    artist_name
    |> get_artist()
    |> Artist.changeset(%{})
    |> Repo.insert_or_update()
  end

  def sync_song(attrs) do
    attrs[:md5_hash]
    |> get_song()
    |> Song.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def get_song(md5_hash) do
    case Repo.get_by(Song, md5_hash: md5_hash) do
      nil -> %Song{md5_hash: md5_hash}
      song -> song
    end
  end

  def sync_song_artists(song, artists) do
    # TODO: optimize to not to delete_all
    SongArtist
    |> where([sa], sa.song_id == ^song.id)
    |> Repo.delete_all()

    artists
    |> Enum.map(fn artist -> sync_song_artist(song, artist) end)
    |> check_list()
  end

  def sync_song_artist(song, artist) do
    %SongArtist{}
    |> SongArtist.changeset(%{artist_id: artist.id, song_id: song.id})
    |> Repo.insert()
  end

  def get_artist(name) do
    case Repo.get_by(Artist, name: name) do
      nil -> %Artist{name: name}
      artist -> artist
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
