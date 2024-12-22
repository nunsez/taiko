defmodule TaikoWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use TaikoWeb, :controller` and
  `use TaikoWeb, :live_view`.
  """
  use TaikoWeb, :html

  embed_templates "layouts/*"
end
