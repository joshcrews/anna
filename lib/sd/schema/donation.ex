defmodule Sd.Donation do
  @moduledoc "Transactions that are gifts"

  use Ecto.Schema

  import Ecto.Changeset

  schema "donations" do
    field(:account_id, :integer)
    field(:customer_id, :integer)
    field(:deposit_id, :integer)
    field(:disputed, :boolean)
    field(:donation_subscription_id, :integer)
    field(:donation_type, :string)
    field(:fund_id, :integer)
    field(:gateway_transaction_id, :string)
    field(:gross_amount, :integer)
    field(:merchant_fee, :integer)
    field(:net_amount, :integer)
    field(:offset_fee, :boolean)
    field(:paid_on, :utc_datetime)
    field(:payment_source_id, :integer)
    field(:payment_type, :string)
    field(:refunded, :boolean)
    field(:rock_fee_covered_synced_at, :utc_datetime)
    field(:sd_fee, :integer)
    field(:status, :string)
    field(:total_fee, :integer)
    field(:uuid, :string)
    field(:gateway, :string)

    timestamps(inserted_at: :created_at)
  end

  def create_changeset(payment_source, params \\ %{}) do
    payment_source
    |> cast(params, [
      :account_id,
      :customer_id,
      :donation_subscription_id,
      :donation_type,
      :fund_id,
      :gateway_transaction_id,
      :gross_amount,
      :merchant_fee,
      :net_amount,
      :offset_fee,
      :payment_source_id,
      :payment_type,
      :sd_fee,
      :status,
      :total_fee,
      :gateway,
      :uuid
    ])
    |> validate_required([
      :account_id,
      :customer_id,
      :donation_type,
      :gateway_transaction_id,
      :gross_amount,
      :merchant_fee,
      :net_amount,
      :payment_source_id,
      :payment_type,
      :sd_fee,
      :status,
      :total_fee,
      :gateway
    ])
    |> generate_uuid()
    |> foreign_key_constraint(:fund_id, name: :fk_rails_94eb8b9c3b)
  end

  def generate_uuid(changeset = %{changes: %{uuid: uuid}}) when not is_nil(uuid) do
    changeset
  end

  def generate_uuid(changeset) do
    prefix = "dona"
    uuid = prefix <> "_" <> Ulid.generate()
    put_change(changeset, :uuid, uuid)
  end
end
