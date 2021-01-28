defmodule Anna.Campus do
  use Ecto.Schema
  import Ecto.Changeset

  schema "campuses" do
    field :name, :string
    field :account_id, :integer
    timestamps()
  end

  @doc false
  def changeset(campus, attrs) do
    campus
    |> cast(attrs, [])
    |> validate_required([])
  end
end
