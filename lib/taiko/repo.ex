defmodule Taiko.Repo do
  use Ecto.Repo,
    otp_app: :taiko,
    adapter: Ecto.Adapters.SQLite3
end
