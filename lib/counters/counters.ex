defmodule Counters.Counters do
  alias Counters.{Repo, Counter}

  def write_counter(name, value) do
    Repo.query(
        """
        insert into counters (key, sum)
        values ($1, $2)
        on conflict (key)
        do update set sum = counters.sum + $2;
        """,
        [name, value]
      )
  end

  def read_counter(name) do
    Repo.get(Counter, name)
  end
end
