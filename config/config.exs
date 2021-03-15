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
  url: [host: "polldance.io", scheme: "https", port: 443],
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

config :vote, VoteWeb.Authentication,
  issuer: "vote",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

# configure bamboo
config :vote, Vote.Email.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: {System, :get_env, ["SENDGRID_API_KEY"]}

# configure emails
config :vote, Vote.Email,
  verify_subject: "Account Verification for VOTE",
  verify_from: "themichaeleden@gmail.com",
  verify_body: "Click this link to verify your account: "

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]},
    identity: {
      Ueberauth.Strategy.Identity, [
        param_nesting: "account",
        request_path: "/register",
        callback_path: "/register",
        callback_methods: ["POST"],
      ]
    },
  ]

# configure google OAuth
config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: {System, :get_env, ["GOOGLE_CLIENT_ID"]},
  client_secret: {System, :get_env, ["GOOGLE_CLIENT_SECRET"]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
