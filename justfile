default:
    @just --list

install-deps:
    mix do deps.get, deps.compile

in:
    iex -S mix

s:
    mix phx.server

test *args:
    mix test {{ args }}
