# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :experiment,
  ecto_repos: [Experiment.Repo]

# Configures the endpoint
config :experiment, ExperimentWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "i/df44+dKAK2rM6s38ADrnXLqTW0uk4ze9TlLlQ2ZAOYTbIYPkDzOGnO6VKno18z",
  render_errors: [view: ExperimentWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Experiment.PubSub,
  live_view: [signing_salt: "8J/yBBtX"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
