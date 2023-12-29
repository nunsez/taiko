defmodule Taiko.Repo do
  use Ecto.Repo,
    otp_app: :taiko,
    adapter: Ecto.Adapters.Postgres
end
