defmodule Anna.Campus do
  use Ecto.Schema
  import Ecto.Changeset

  schema "campuses" do
    field :name, :string
    timestamps()
  end

  @doc false
  def changeset(campus, attrs) do
    campus
    |> cast(attrs, [])
    |> validate_required([])
  end
end
