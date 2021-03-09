defmodule Vote.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Vote.Repo,
      # Start the Telemetry supervisor
      VoteWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Vote.PubSub},
      # Start the Endpoint (http/https)
      VoteWeb.Endpoint,
      # Start a worker by calling: Vote.Worker.start_link(arg)
      # {Vote.Worker, arg}
      {Vote.Ballots.LiveState, :ok},
      {DynamicSupervisor, name: Vote.Ballots.Supervisor, strategy: :one_for_one},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Vote.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    VoteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
