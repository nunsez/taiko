defmodule TaikoWeb.PlaylistsLive do
  use TaikoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="max-w-xs flex h-screen flex-col justify-between border-e bg-white">
      <div class="px-4 py-6">
        <ul class="mt-6 space-y-1">
          <li>
            <a
              href="#"
              class="block rounded-lg bg-gray-100 px-4 py-2 text-sm font-medium text-gray-700"
            >
              Playlist
            </a>
          </li>

          <li>
            <details class="group [&_summary::-webkit-details-marker]:hidden">
              <summary class="flex cursor-pointer items-center justify-between rounded-lg px-4 py-2 text-gray-500 hover:bg-gray-100 hover:text-gray-700">
                <span class="text-sm font-medium">Playlist</span>

                <span class="shrink-0 transition duration-300 group-open:-rotate-180">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="size-5"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                  >
                    <path
                      fill-rule="evenodd"
                      d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                      clip-rule="evenodd"
                    />
                  </svg>
                </span>
              </summary>

              <ul class="mt-2 space-y-1 px-4">
                <li>
                  <a
                    href="#"
                    class="block rounded-lg px-4 py-2 text-sm font-medium text-gray-500 hover:bg-gray-100 hover:text-gray-700"
                  >
                    Playlist
                  </a>
                </li>
              </ul>
            </details>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end
end