defmodule TaikoWeb.ProfileLive do
  use TaikoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <h1>Profile Live</h1>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket, []}
  end
end
