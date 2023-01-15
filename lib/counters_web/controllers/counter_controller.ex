defmodule CountersWeb.CounterController do
  alias Counters.{DBWriteBuffer, Counters}
  use CountersWeb, :controller

  def show(conn, params) do
    [{key_name, key_increment}] = Map.to_list(params)
    DBWriteBuffer.insert(key_name, key_increment)

    send_resp(conn, 202, "created")
  end

  def get(conn, %{"name" => key_name}) do
    %{sum: key_sum} = Counters.read_counter(key_name)

    send_resp(conn, 200, "#{key_sum}")
  end
end
