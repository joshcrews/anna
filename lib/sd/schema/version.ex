defmodule Sd.Version do
  @moduledoc "Rails library uses this for model change history"

  use Ecto.Schema

  schema "versions" do
    field(:item_type, :string)
    field(:item_id, :integer)
    field(:event, :string)
    field(:object, :string)
    field(:object_changes, :string)

    timestamps(inserted_at: :created_at, updated_at: false)
  end
end
