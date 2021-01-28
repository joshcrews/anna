defmodule Anna.Repo do
  use Ecto.Repo,
    otp_app: :anna,
    adapter: Ecto.Adapters.Postgres
end

defmodule Anna.ReadOnlyRepo do
  use Ecto.Repo,
    otp_app: :anna,
    adapter: Ecto.Adapters.Postgres,
    read_only: true
end
