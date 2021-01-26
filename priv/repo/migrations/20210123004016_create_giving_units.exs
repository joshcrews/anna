defmodule Anna.Repo.Migrations.CreateGivingUnits do
  use Ecto.Migration

  def change do
    create table(:giving_units) do
      add :name, :string
      add :campus_id, references(:campuses, on_delete: :nothing)
      add :age, :integer
      add :age_band, :string
      add :outside_id, :integer

      timestamps()
    end

    create index(:giving_units, [:campus_id])
  end
end
