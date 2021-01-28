defmodule Anna.Repo.Migrations.CreateGivingUnits do
  use Ecto.Migration

  def change do
    create table(:giving_units) do
      add :name, :string
      add :campus_id, references(:campuses, on_delete: :nothing)
      add :age, :integer
      add :age_band, :string
      add :outside_id, :integer
      add :zipcode, :integer
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end

    create index(:giving_units, [:account_id])
    create index(:giving_units, [:campus_id])
    create unique_index(:giving_units, [:outside_id])
  end
end
