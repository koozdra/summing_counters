# usage
# mix run test/integration/single_key.exs --no-start

defmodule Client do
  def send_counter_increment(name, amount) do
      HTTPoison.post(
        "localhost:3333/increment",
        Jason.encode!(%{
          name => amount
        }),
        [{"Content-Type", "application/json"}]
      )
  end

  def get_counter_sum(name) do
    {:ok, %{body: sum_string}} = HTTPoison.get(
        "localhost:3333/key_sum?name=#{name}"
      )

    sum_string
  end


end

HTTPoison.start()

counter_name = "summing_key_#{System.os_time}"
up_to_limit = 1000
up_to_range = 0..up_to_limit
local_total = Enum.reduce(up_to_range, fn a,b -> a + b end)

IO.puts "Starting key #{counter_name}"

up_to_range
  |> Enum.map(fn num ->
    Task.async(fn -> Client.send_counter_increment(counter_name, num) end)
  end)
  |> Enum.map(fn task -> Task.await(task, :infinity) end)

IO.puts "Requests sent.."
IO.puts "local_total: #{local_total}"

IO.puts "waiting 10 seconds..."
:timer.sleep(10000)

remote_total = Client.get_counter_sum(counter_name)
IO.puts "remote total: #{remote_total}"
