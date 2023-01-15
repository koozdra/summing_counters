defmodule Counters.DBWriteBuffer do
  use DataBuffer
  alias Counters.Counters

  def handle_flush(key_name, values) do
    summed_total = Enum.sum(values)
    IO.puts("flushing #{key_name} #{summed_total}")

    Counters.write_counter(key_name, summed_total)

    :ok
  end
end
