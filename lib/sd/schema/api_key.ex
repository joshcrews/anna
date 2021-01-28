defmodule Sd.ApiKey do
  use Ecto.Schema

  schema "api_keys" do
    field(:account_id, :integer)
    field(:api_key, :string)

    timestamps(inserted_at: :created_at)
  end
end
