defmodule Anna.Repo.Migrations.CreateFunds do
  use Ecto.Migration

  def change do
    create table(:funds) do
      add :name, :string, null: false
      add :outside_id, :integer
      add :account_id, references(:accounts, on_delete: :nothing)
      add :campus_id, references(:campuses, on_delete: :nothing)
      timestamps()
    end

    create unique_index(:funds, [:outside_id])
    create index(:funds, [:account_id])
    create index(:funds, [:campus_id])
  end
end
