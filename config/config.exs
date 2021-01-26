# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :anna,
  ecto_repos: [Anna.Repo]

# Configures the endpoint
config :anna, AnnaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "1+BbjGxe9YsWYmg5zqE9tUuV/y8ZX9d/sQmigIxto8mX/tEG1fo6eVKS2HLNeAPD",
  render_errors: [view: AnnaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Anna.PubSub,
  live_view: [signing_salt: "SOsd6OZ1"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
