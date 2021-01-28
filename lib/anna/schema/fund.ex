defmodule Anna.Fund do
  use Ecto.Schema
  import Ecto.Changeset

  schema "funds" do
    field :name, :string
    field :account_id, :integer
    field :campus_id, :integer
    field :outside_id, :integer
    timestamps()
  end

  @doc false
  def changeset(fund, attrs) do
    fund
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
