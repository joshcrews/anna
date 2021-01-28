defmodule Sd.Fund do
  @moduledoc "Arbitrary categories that Donations for reporting and ChMS importing"

  use Ecto.Schema

  schema "funds" do
    field(:name, :string)
    field(:txt_keyword, :string)
    field(:deleted_at, :utc_datetime)
    field(:account_id, :integer)

    timestamps(inserted_at: :created_at)
  end
end
