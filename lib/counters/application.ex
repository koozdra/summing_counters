defmodule Counters.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Counters.Repo,
      # Start the Telemetry supervisor
      CountersWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Counters.PubSub},
      # Start the Endpoint (http/https)
      CountersWeb.Endpoint,
      # Start a worker by calling: Counters.Worker.start_link(arg)
      # {Counters.Worker, arg}
      Counters.DBWriteBuffer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Counters.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CountersWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
