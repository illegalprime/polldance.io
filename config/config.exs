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
  url: [host: "pollparty.io", scheme: "https", port: 443],
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

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.13.12",
  path: System.get_env("MIX_ESBUILD_PATH"),
  default: [
    args:
    ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" =>
      System.get_env("NODE_PATH") || Path.expand("../deps", __DIR__)
    }
  ]

config :dart_sass,
  version: "1.49.0",
  path: System.get_env("MIX_SASS_PATH"),
  default: [
    args: ~w(css/app.scss ../priv/static/assets/app.css),
    cd: Path.expand("../assets", __DIR__)
  ]

# configure emails
config :vote, Vote.Email,
  verify_subject: "Account Verification for pollparty.io",
  verify_from: "noreply@pollparty.io",
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

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: {System, :get_env, ["GOOGLE_CLIENT_ID"]},
  client_secret: {System, :get_env, ["GOOGLE_CLIENT_SECRET"]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
