defmodule Taiko.Repo.Migrations.CreateSongArtists do
  use Ecto.Migration

  def change do
    create table(:song_artists, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :artist_id, references(:artists, on_delete: :delete_all, type: :binary_id)
      add :song_id, references(:songs, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:song_artists, [:artist_id])
    create index(:song_artists, [:song_id])
    create unique_index(:song_artists, [:song_id, :artist_id])
  end
end
