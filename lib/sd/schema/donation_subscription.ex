defmodule Sd.DonationSubscription do
  @moduledoc "Recurring donations"

  use Ecto.Schema

  import Ecto.Changeset

  schema "donation_subscriptions" do
    field(:amount, :integer)
    field(:account_id, :integer)
    field(:customer_id, :integer)
    field(:next_renewal_at, :utc_datetime)
    field(:state, :string)
    field(:offset_fee, :boolean)
    field(:recurring_rule, :string)
    field(:deleted_at, :utc_datetime)
    field(:fund_id, :integer)
    field(:uuid, :string)
    field(:active, :boolean)
    field(:payment_source_id, :integer)
    field(:source, :string)

    timestamps(inserted_at: :created_at)
  end

  def create_changeset(payment_source, params \\ %{}) do
    payment_source
    |> cast(params, [
      :amount,
      :account_id,
      :customer_id,
      :next_renewal_at,
      :state,
      :offset_fee,
      :recurring_rule,
      :fund_id,
      :active,
      :payment_source_id,
      :source
    ])
    |> validate_required([
      :amount,
      :account_id,
      :customer_id,
      :next_renewal_at,
      :state,
      :offset_fee,
      :recurring_rule,
      :payment_source_id,
      :source
    ])
    |> generate_uuid()
  end

  def generate_uuid(changeset) do
    if changeset.data.uuid do
      changeset
    else
      uuid = "recur" <> "_" <> Ulid.generate()

      put_change(changeset, :uuid, uuid)
    end
  end
end
