defmodule Taiko do
  @moduledoc """
  Taiko keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def sequence(results, success \\ :ok) do
    {status, values} =
      Enum.reduce(results, {:ok, []}, fn
        {^success, value}, {:ok, acc} -> {:ok, [value | acc]}
        {_, value}, {_, acc} -> {:error, [value | acc]}
      end)

    {status, Enum.reverse(values)}
  end
end
