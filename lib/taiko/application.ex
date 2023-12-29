defmodule Taiko.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TaikoWeb.Telemetry,
      Taiko.Repo,
      {DNSCluster, query: Application.get_env(:taiko, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Taiko.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Taiko.Finch},
      # Start a worker by calling: Taiko.Worker.start_link(arg)
      # {Taiko.Worker, arg},
      # Start to serve requests, typically the last entry
      TaikoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Taiko.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TaikoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
