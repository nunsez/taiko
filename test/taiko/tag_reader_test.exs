defmodule Taiko.TagReaderTest do
  use ExUnit.Case, async: true

  alias Taiko.Tag

  @picture_data "base64:iVBORw0KGgoAAAANSUhEUgAAADoAAAA3CAYAAABdJVn2AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAACySURBVGhD7c+xDQJRDATRKwQymqYQiqEBAiRqgHwCa3X/ZISZ4CVO1rNd78/3P9h4mMrQaQydxtBpDJ3G0MrrdPka/pIytMLxTvwlZWiF4534S+qw0NvjfDhuGBowtMJxQxdxw9CAoRWOG7qIG4YGDK1w3NBF3DA0YGiF44Yu4oahAUMrHDd0ETcMDRha4Xgn/pIytMLxTvwlZWiF4534S2pX6C8ydBpDpzF0GkOnMXSaD2FjHZ2BnOfMAAAAAElFTkSuQmCC"

  describe "ogg" do
    test "returns valid Tag struct" do
      path = "test/support/files/music_root/ogg.ogg"
      {:ok, tag} = Taiko.TagReader.read_file(path)

      assert %Tag{
               bitrate: 44_100,
               comment: "ogg comment",
               album: "Ogg Album",
               genre: "Trance",
               title: "Ogg Title",
               artist: ["Ogg Artist One", "Ogg Artist Two"],
               track_number: 1,
               disc_number: 3,
               year: 2025,
               picture_mime: "image/png",
               picture_data: @picture_data,
               duration: 0.27
             } = tag
    end
  end

  describe "opus" do
    test "returns valid Tag struct" do
      path = "test/support/files/music_root/opus.opus"
      {:ok, tag} = Taiko.TagReader.read_file(path)

      assert %Tag{
               bitrate: 48_000,
               comment: "opus comment",
               album: "Opus Album",
               genre: "Trance",
               title: "Opus Title",
               artist: ["Opus Artist One", "Opus Artist Two"],
               track_number: 1,
               disc_number: 3,
               year: 2025,
               picture_mime: "image/png",
               picture_data: @picture_data
               #  duration: nil
             } = tag
    end
  end

  describe "mp3" do
    test "returns valid Tag struct" do
      path = "test/support/files/music_root/dir_1/mp3.mp3"
      path = "/mnt/d/Music/Japanese/2017/Jamil - The Rock City Boy.mp3"
      {:ok, tag} = Taiko.TagReader.read_file(path)

      assert %Tag{
               bitrate: 44_100,
               comment: "mp3 comment",
               album: "Mp3 Album",
               genre: "Trance",
               title: "Mp3 Title",
               artist: ["Mp3 Artist One", "Mp3 Artist Two"],
               track_number: 1,
               disc_number: 3,
               year: 2025,
               picture_mime: "image/png",
               picture_data: @picture_data,
               duration: 1.88
             } = tag
    end
  end

  describe "wav" do
    test "returns valid Tag struct" do
      path = "test/support/files/music_root/dir_1/wav.wav"
      {:ok, tag} = Taiko.TagReader.read_file(path)

      assert %Tag{
               bitrate: 48_000,
               comment: "wav comment",
               album: "Wav Album",
               genre: "Trance",
               title: "Wav Title",
               artist: ["Wav Artist One", "Wav Artist Two"],
               track_number: 1,
               #  disc_number: 3,
               year: 2025,
               #  picture_mime: "image/png",
               #  picture_data: @picture_data,
               duration: 1.87
             } = tag
    end
  end

  describe "m4a" do
    test "returns valid Tag struct" do
      path = "test/support/files/music_root/dir_1/dir_3/m4a.m4a"
      {:ok, tag} = Taiko.TagReader.read_file(path)

      assert %Tag{
               bitrate: 44_100,
               comment: "m4a comment",
               album: "M4a Album",
               genre: "Trance",
               title: "M4a Title",
               artist: "M4a Artist Two",
               #  artist: ["M4a Artist One", "M4a Artist Two"],
               track_number: 1,
               disc_number: 3,
               year: 2025,
               #  picture_mime: "image/png",
               picture_data: @picture_data,
               duration: 1.87
             } = tag
    end
  end

  describe "flac" do
    test "returns valid Tag struct" do
      path = "test/support/files/music_root/dir_2/flac.flac"
      {:ok, tag} = Taiko.TagReader.read_file(path)

      assert %Tag{
               bitrate: 44_100,
               comment: "flac comment",
               album: "Flac Album",
               genre: "Trance",
               title: "Flac Title",
               artist: ["Flac Artist One", "Flac Artist Two"],
               track_number: 1,
               disc_number: 3,
               year: 2025,
               picture_mime: "image/png",
               picture_data: @picture_data,
               duration: 1.85
             } = tag
    end
  end
end
