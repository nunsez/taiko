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
    field :picture_data, :string
    field :picture_mime, :string
    field :file_path, :string
    field :file_size, :integer
    field :md5_hash, :string

    timestamps(type: :utc_datetime)
  end

  @required [:name, :file_path, :file_size, :md5_hash]
  @optional [:duration, :bitrate, :disc_number, :track_number, :year, :picture_data, :picture_mime]

  def from_file(file_path, stat, tag) do
    %{
      name: tag.title,
      year: tag.year,
      duration: ceil(tag.duration),
      bitrate: tag.bitrate,
      disc_number: tag.disc_number,
      track_number: tag.track_number,
      picture_data: tag.picture_data,
      picture_mime: tag.picture_mime,
      file_path: file_path,
      file_size: stat.size,
      md5_hash: md5_hash(file_path, stat)
    }
  end

  def md5_hash(data) when is_binary(data) do
    :crypto.hash(:md5, data)
    |> Base.encode16(case: :lower)
  end

  def md5_hash(file_path, %File.Stat{} = stat) when is_binary(file_path) do
    stat.mtime
    |> NaiveDateTime.from_erl!()
    |> NaiveDateTime.to_string()
    |> then(fn data -> file_path <> data end)
    |> md5_hash()
  end

  @doc false
  def changeset(song, attrs) do
    song
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
