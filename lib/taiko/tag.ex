defmodule Taiko.Tag do
  defstruct [
    :bitrate,
    :comment,
    :album,
    :genre,
    :title,
    :artist,
    :track_number,
    :disc_number,
    :year,
    :picture_mime,
    :picture_data,
    :duration
  ]

  def from(%{"FileType" => "OGG"} = json) do
    tag = %__MODULE__{
      bitrate: json["SampleRate"],
      comment: json["Comment"],
      album: json["Album"],
      genre: json["Genre"],
      title: json["Title"],
      artist: json["Artist"],
      track_number: json["TrackNumber"],
      disc_number: json["Discnumber"],
      year: json["Date"],
      picture_mime: json["PictureMIMEType"],
      picture_data: json["Picture"],
      duration: parse_float(json["Duration"])
    }

    {:ok, tag}
  end

  # TODO: Add opus duration
  def from(%{"FileType" => "OPUS"} = json) do
    tag = %__MODULE__{
      bitrate: json["SampleRate"],
      comment: json["Comment"],
      album: json["Album"],
      genre: json["Genre"],
      title: json["Title"],
      artist: json["Artist"],
      track_number: json["TrackNumber"],
      disc_number: json["Discnumber"],
      year: json["Date"],
      picture_mime: json["PictureMIMEType"],
      picture_data: json["Picture"],
      duration: nil
    }

    {:ok, tag}
  end

  def from(%{"FileType" => "MP3"} = json) do
    artist =
      json["Artist"]
      |> to_string()
      |> String.split("/")
      |> Enum.reject(fn s -> s == "" end)

    tag = %__MODULE__{
      bitrate: json["SampleRate"],
      comment: json["Comment"],
      album: json["Album"],
      genre: json["Genre"],
      title: json["Title"],
      artist: artist,
      track_number: json["Track"] |> id3_numbers() |> elem(0),
      disc_number: json["PartOfSet"] |> id3_numbers() |> elem(0),
      year: json["Year"],
      picture_mime: json["PictureMIMEType"],
      picture_data: json["Picture"],
      duration: parse_float(json["Duration"])
    }

    {:ok, tag}
  end

  # TODO: add wav picture data
  # TODO: add wav disc_number
  def from(%{"FileType" => "WAV"} = json) do
    artist =
      json["Artist"]
      |> to_string()
      |> String.split(";")
      |> Enum.reject(fn s -> s == "" end)

    tag = %__MODULE__{
      bitrate: json["SampleRate"],
      comment: json["Comment"],
      album: json["Product"],
      genre: json["Genre"],
      title: json["Title"],
      artist: artist,
      track_number: json["TrackNumber"] |> id3_numbers() |> elem(0),
      disc_number: nil,
      year: json["DateCreated"],
      picture_mime: nil,
      picture_data: nil,
      duration: parse_float(json["Duration"])
    }

    {:ok, tag}
  end

  # TODO fix m4a artist
  # TODO: add m4a picture_mime
  def from(%{"FileType" => "M4A"} = json) do
    tag = %__MODULE__{
      bitrate: json["AudioSampleRate"],
      comment: json["Comment"],
      album: json["Album"],
      genre: json["Genre"],
      title: json["Title"],
      artist: json["Artist"],
      track_number: json["TrackNumber"] |> m4a_numbers() |> elem(0),
      disc_number: json["DiskNumber"] |> m4a_numbers() |> elem(0),
      year: json["ContentCreateDate"],
      picture_mime: nil,
      picture_data: json["CoverArt"],
      duration: parse_float(json["Duration"])
    }

    {:ok, tag}
  end

  def from(%{"FileType" => "FLAC"} = json) do
    # Possible formats:
    # - "2024-12-31"
    # - 2024
    year =
      case json["Date"] do
        <<year::binary-size(4), _::binary>> -> parse_integer(year)
        year -> parse_integer(year)
      end

    tag = %__MODULE__{
      bitrate: json["SampleRate"],
      comment: json["Description"],
      album: json["Album"],
      genre: json["Genre"],
      title: json["Title"],
      artist: json["Artist"],
      track_number: json["TrackNumber"],
      disc_number: json["Discnumber"],
      year: year,
      picture_mime: json["PictureMIMEType"],
      picture_data: json["Picture"],
      duration: flac_duration(json["Duration"])
    }

    {:ok, tag}
  end

  def from(_json) do
    {:error, :unknown_file_type}
  end

  @doc """
  Possible formats:
  - "0:03:33"
  - "14.04 s"
  """
  def flac_duration(data) do
    str = to_string(data)

    case Regex.run(~r"(\d+):(\d+):(\d+)", str) do
      [_, hours, minutes, seconds] ->
        [seconds, minutes, hours]
        |> Enum.map(&parse_integer/1)
        |> Enum.with_index()
        |> Enum.reject(&is_nil/1)
        |> Enum.reduce(0, fn {num, idx}, acc -> acc + num * 60 ** idx end)

      _ ->
        parse_float(data)
    end
  end

  @doc """
  Possible formats:
  - 1
  - "/2"
  - "1/2"
  """
  def id3_numbers(data) when is_integer(data) do
    {data, nil}
  end

  def id3_numbers(data) do
    case Regex.run(~r"(\d+)?\/(\d+)", to_string(data)) do
      [_, current, total] ->
        {parse_integer(current), parse_integer(total)}

      _ ->
        {nil, nil}
    end
  end

  @doc """
  Possible formats:
  - 1
  - "0 of 2"
  - "1 of 2"
  """
  def m4a_numbers(data) when is_integer(data) do
    {data, nil}
  end

  def m4a_numbers(data) do
    case Regex.run(~r"(\d+) of (\d+)", to_string(data)) do
      [_, current, total] ->
        {parse_integer(current), parse_integer(total)}

      _ ->
        {nil, nil}
    end
  end

  def parse_integer(nil) do
    nil
  end

  def parse_integer(data) when is_integer(data) do
    data
  end

  def parse_integer(data) when is_float(data) do
    trunc(data)
  end

  def parse_integer(data) when is_binary(data) do
    case Integer.parse(data) do
      {number, _} -> number
      _ -> nil
    end
  end

  def parse_float(nil) do
    nil
  end

  def parse_float(data) when is_integer(data) do
    data / 1
  end

  def parse_float(data) when is_float(data) do
    data
  end

  def parse_float(data) when is_binary(data) do
    case Float.parse(data) do
      {number, _} -> number
      _ -> nil
    end
  end
end
