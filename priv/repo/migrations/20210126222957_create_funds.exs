defmodule Anna.Repo.Migrations.CreateFunds do
  use Ecto.Migration

  def change do
    create table(:funds) do
      add :name, :string, null: false

      timestamps()
    end
  end
end
