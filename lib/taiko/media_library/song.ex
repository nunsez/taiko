defmodule Taiko.MediaLibrary.Song do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "songs" do
    field :name, :string
    field :year, :integer
    field :duration, :integer
    field :bitrate, :integer
    field :disc_number, :integer
    field :track_number, :integer
    field :content_hash, :string
    field :file_path, :string
    field :file_path_hash, :string
    field :file_size, :integer

    timestamps(type: :utc_datetime)
  end

  @required [:name, :content_hash, :file_path, :file_path_hash, :file_size]
  @optional [:duration, :bitrate, :disc_number, :track_number, :year]

  @doc false
  def changeset(song, attrs) do
    song
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
