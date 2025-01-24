defmodule Mix.Tasks.MediaSync do
  alias Taiko.MediaLibrary

  @root Path.expand("~/Music")

  @formats ["mp3", "m4a", "wav", "flac", "ogg"]

  def run(_args) do
    # Mix.Task.run "app.start"
    Application.ensure_all_started(:taiko)

    files()
    |> MediaLibrary.create()
    |> MediaLibrary.cleanup()
  end

  def files do
    formats = Enum.join(@formats, ",")
    wildcard = Path.join(@root, ["**/*", "{", formats, "}"])
    Path.wildcard(wildcard)
  end
end
