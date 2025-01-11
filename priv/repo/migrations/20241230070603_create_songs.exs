defmodule Taiko.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def change do
    create table(:songs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :duration, :integer
      add :bitrate, :integer
      add :disc_number, :integer
      add :track_number, :integer
      add :year, :integer
      add :picture_data, :string
      add :picture_mime, :string
      add :file_path, :string
      add :file_size, :integer
      add :md5_hash, :string

      timestamps(type: :utc_datetime)
    end
  end
end
