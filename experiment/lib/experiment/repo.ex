defmodule Experiment.Repo do
  use Ecto.Repo,
    otp_app: :experiment,
    adapter: Ecto.Adapters.Postgres
end
