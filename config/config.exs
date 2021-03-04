# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :vote,
  ecto_repos: [Vote.Repo]

# Configures the endpoint
config :vote, VoteWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8S97EM77A/aP/XRU+EFu6z74fb5cGL8H0NCHxZWqLqED+J4nzRjnzpuY3PA4w3lw",
  render_errors: [view: VoteWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Vote.PubSub,
  live_view: [signing_salt: "J1mP4Fjc"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
