defmodule Counters.Repo do
  use Ecto.Repo,
    otp_app: :counters,
    adapter: Ecto.Adapters.Postgres
end
