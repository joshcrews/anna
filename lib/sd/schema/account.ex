defmodule Sd.Account do
  @moduledoc "Represents the church/organization that receives money"

  use Ecto.Schema

  schema "accounts" do
    field(:name, :string)
    field(:full_domain, :string)
    field(:uuid, :string)
    field(:settings, :map)
    field(:stripe_account_id, :string)
    field(:statement_descriptor, :string)
    field(:last_donated_at, :utc_datetime)
    field(:adyen_account_id, :string)

    has_many(:funds, Sd.Fund)

    timestamps(inserted_at: :created_at)
  end
end
