# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Taiko.Repo.insert!(%Taiko.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Taiko.Repo
alias Taiko.Accounts.User

Repo.insert!(%User{email: "admin@admin.com", hashed_password: Bcrypt.hash_pwd_salt("password")})
