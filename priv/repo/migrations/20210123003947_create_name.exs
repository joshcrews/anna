defmodule Anna.Repo.Migrations.CreateCampus do
  use Ecto.Migration

  def change do
    create table(:campuses) do
      timestamps()
    end
  end
end
