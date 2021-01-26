defmodule Anna.GivingUnit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "giving_units" do
    field :name, :string
    field :campus_id, :id

    timestamps()
  end

  @doc false
  def changeset(giving_unit, attrs) do
    giving_unit
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end