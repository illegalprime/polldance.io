defmodule Vote.Repo do
  use Ecto.Repo,
    otp_app: :vote,
    adapter: Ecto.Adapters.Postgres
end
