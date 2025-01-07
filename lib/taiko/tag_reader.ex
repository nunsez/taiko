defmodule Taiko.TagReader do
  alias Taiko.Tag

  def read_file(path) do
    args = ["-json", "-b", path]

    case System.cmd("exiftool", args) do
      {binary, 0} -> parse(binary)
      {error, _code} -> {:error, error}
    end
  end

  def parse(str) do
    case JSON.decode(str) do
      {:ok, [json | _]} -> Tag.from(json)
      error -> error
    end
  end
end
