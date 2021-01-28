defmodule Anna.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Anna.Repo,
      Anna.ReadOnlyRepo,
      # Start the Telemetry supervisor
      AnnaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Anna.PubSub},
      # Start the Endpoint (http/https)
      AnnaWeb.Endpoint
      # Start a worker by calling: Anna.Worker.start_link(arg)
      # {Anna.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Anna.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AnnaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
