defmodule Sd.MerlinWidget do
  @moduledoc "Each Account can have different MerlinWidgets with their own settings"

  use Ecto.Schema

  schema "merlin_widgets" do
    field(:key, :string)
    field(:manage_giving_url, :string)
    field(:show_cover_the_fee, :boolean)
    field(:default_checked_cover_the_fee, :boolean)
    field(:starting_amount_cents, :integer)
    field(:default_recurring_option, :string)

    belongs_to(:account, Sd.Account)

    timestamps(inserted_at: :created_at)
  end
end
