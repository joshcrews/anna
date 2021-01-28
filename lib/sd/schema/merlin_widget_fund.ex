defmodule Sd.MerlinWidgetFund do
  @moduledoc "Funds are populated for on per merlin widget basis"

  use Ecto.Schema

  schema "merlin_widget_funds" do
    belongs_to(:merlin_widget, Sd.MerlinWidget)
    belongs_to(:fund, Sd.Fund)
    field(:position, :integer)

    timestamps(inserted_at: :created_at)
  end
end
