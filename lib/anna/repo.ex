defmodule Anna.Repo do
  use Ecto.Repo,
    otp_app: :anna,
    adapter: Ecto.Adapters.Postgres
end
