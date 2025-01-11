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
      {Ecto.Migrator,
       repos: Application.fetch_env!(:taiko, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:taiko, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Taiko.PubSub},
      # Start a worker by calling: Taiko.Worker.start_link(arg)
      # {Taiko.Worker, arg},
      # Start to serve requests, typically the last entry
      TaikoWeb.Endpoint
    ]

    children = setup_listener(children)

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

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end

  defp setup_listener(children) do
    config = Application.get_env(:taiko, Taiko.Listener)

    if config[:enabled] do
      spec = {Taiko.Listener, dirs: config[:dirs] || []}
      [spec | children]
    else
      children
    end
  end
end
