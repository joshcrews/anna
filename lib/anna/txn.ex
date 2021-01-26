defmodule Anna.Txn do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :age_of_giver, :integer
    field :amount_cents, :integer
    field :payment_type, :string
    field :source, :string
    field :zipcode, :integer
    field :giving_unit_id, :id
    field :campus_id, :id

    timestamps()
  end

  @doc false
  def changeset(txn, attrs) do
    txn
    |> cast(attrs, [:amount_cents, :source, :age_of_giver, :zipcode, :payment_type])
    |> validate_required([:amount_cents, :source, :age_of_giver, :zipcode, :payment_type])
  end
end
