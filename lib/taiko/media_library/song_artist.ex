defmodule Taiko.MediaLibrary.SongArtist do
  use Ecto.Schema
  import Ecto.Changeset

  alias Taiko.Repo
  alias Taiko.MediaLibrary.Artist
  alias Taiko.MediaLibrary.Song

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "song_artists" do
    belongs_to :artist, Artist
    belongs_to :song, Song

    timestamps(type: :utc_datetime)
  end

  @required [:artist_id, :song_id]

  @doc false
  def changeset(song_artist, attrs) do
    song_artist
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> unsafe_validate_unique([:artist_id, :song_id], Repo)
    |> unique_constraint([:artist_id, :song_id])
  end
end
