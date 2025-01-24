defmodule Taiko.MediaLibrary.Artist do
  use Ecto.Schema
  import Ecto.Changeset

  alias Taiko.MediaLibrary.Song
  alias Taiko.MediaLibrary.SongArtist

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "artists" do
    field :name, :string

    has_many :song_artists, SongArtist, on_delete: :delete_all

    many_to_many :songs, Song, join_through: SongArtist

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(artist, attrs) do
    artist
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
