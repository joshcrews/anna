defmodule Anna.Repo.Migrations.CreateCampus do
  use Ecto.Migration

  def change do
    create table(:campuses) do
      add :name, :string
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end

    create index(:campuses, [:account_id])
  end
end
