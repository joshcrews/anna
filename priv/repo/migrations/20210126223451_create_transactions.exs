defmodule Anna.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :amount_cents, :integer, null: false
      add :source, :string, null: false
      add :age_of_giver, :integer
      add :zipcode, :integer
      add :payment_type, :string, null: false
      add :giving_unit_id, references(:giving_units, on_delete: :nothing), null: false
      add :campus_id, references(:campuses, on_delete: :nothing)
      add :fund_id, references(:funds, on_delete: :nothing)
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end

    create index(:transactions, [:giving_unit_id])
    create index(:transactions, [:campus_id])
    create index(:transactions, [:fund_id])
    create index(:transactions, [:source])
    create index(:transactions, [:payment_type])
  end
end
