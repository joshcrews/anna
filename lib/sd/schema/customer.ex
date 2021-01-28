defmodule Sd.Customer do
  @moduledoc "Represents a donor so that we can track same persons transactions (Donation) and saved payments (PaymentSource)"

  use Ecto.Schema

  import Ecto.Changeset

  schema "customers" do
    field(:email, :string)
    field(:account_id, :integer)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:uuid, :string)

    timestamps(inserted_at: :created_at)
  end

  def create_changeset(customer, params \\ %{}) do
    customer
    |> cast(params, [:account_id, :first_name, :last_name, :email, :stripe_customer_id])
    |> validate_required([:account_id])
    |> downcase_email()
    |> strip_email()
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,10}$/)
    |> generate_uuid()
  end

  def downcase_email(changeset = %{changes: %{email: nil}}) do
    changeset
  end

  def downcase_email(changeset = %{changes: %{email: email}}) do
    put_change(changeset, :email, String.downcase(email))
  end

  def downcase_email(changeset) do
    changeset
  end

  def strip_email(changeset = %{changes: %{email: nil}}) do
    changeset
  end

  def strip_email(changeset = %{changes: %{email: email}}) do
    put_change(changeset, :email, String.trim(email))
  end

  def strip_email(changeset) do
    changeset
  end

  def generate_uuid(changeset) do
    prefix = "prsn"
    uuid = prefix <> "_" <> Ulid.generate()
    put_change(changeset, :uuid, uuid)
  end
end
