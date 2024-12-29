defmodule TaikoWeb.PlayerLive do
  use TaikoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div id="audio-player">
      <div class="flex justify-center">
        <div>
          <audio controls src="/music/William Black - Deep End.m4a"></audio>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end
end
