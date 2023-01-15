defmodule Counters.Counter do
  @moduledoc """
  A counter.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:key, :string, []}

  schema "counters" do
    # field :key, :string
    field :sum, :integer
  end

  @doc false
  def changeset(variant, attrs) do
    variant
    |> cast(attrs, [:key, :sum])
    |> validate_required([:key, :sum])
  end
end
