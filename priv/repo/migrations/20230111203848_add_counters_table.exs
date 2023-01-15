defmodule Counters.Repo.Migrations.AddCountersTable do
  use Ecto.Migration

  def change do
    create table("counters", primary_key: false) do
      add :key, :string, size: 120, primary_key: true
      add :sum, :integer
    end
  end
end
