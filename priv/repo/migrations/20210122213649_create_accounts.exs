defmodule Anna.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string, null: false
      add :outside_id, :integer
      timestamps()
    end

    create unique_index(:accounts, [:outside_id])
  end
end
