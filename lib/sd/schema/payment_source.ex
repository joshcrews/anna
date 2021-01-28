defmodule Sd.PaymentSource do
  @moduledoc "Represents a saved payment (bank account or credit card)"

  use Ecto.Schema

  import Ecto.Changeset

  schema "payment_sources" do
    field(:uuid, :string)
    field(:customer_id, :integer)
    field(:expiry_date, :date)
    field(:name, :string)
    field(:payment_type, :string)
    field(:card_type, :string)
    field(:last_4, :string)
    field(:fingerprint, :string)
    field(:gateway_source_id, :string)
    field(:deleted_at, :utc_datetime)
    field(:last_used_at, :utc_datetime)
    field(:gateway, :string)

    timestamps(inserted_at: :created_at)
  end

  def create_changeset(payment_source, params \\ %{}) do
    payment_source
    |> cast(params, [
      :customer_id,
      :payment_type,
      :expiry_date,
      :name,
      :card_type,
      :last_4,
      :fingerprint,
      :last_used_at,
      :gateway_source_id
    ])
    |> validate_required([:customer_id])
    |> generate_uuid()
  end

  def generate_uuid(changeset) do
    if changeset.data.uuid do
      changeset
    else
      prefix = if changeset.changes.payment_type == "card", do: "card", else: "ba"

      uuid = prefix <> "_" <> Ulid.generate()
      put_change(changeset, :uuid, uuid)
    end
  end
end
