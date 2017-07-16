defmodule ComputeFarm do

  def factorial(0), do: 1
  def factorial(n), do: n * factorial(n-1)

  def finish(pid, name) do
    IO.puts("Wait complete")
    ComputeFarm.server(pid, name, %{register: false})
  end

  def server(dispatcher_pid, name, options \\ %{register: true}) do
    if options.register do
      send(dispatcher_pid, {:register, %{name: name, pid: self()}})
    end

    receive do 
      message -> IO.puts("Server #{name} received #{message}")
      value = 100_000 * Enum.random(1..5)
      IO.puts("Computing factorial of #{value}...")
      result = factorial(value)
      IO.puts("Computation complete")
      send(dispatcher_pid, {:result, %{server: name, value: value, result: result}})
      ComputeFarm.server(dispatcher_pid, name, %{register: false})
    end
  end

  def dispatcher(servers \\ %{}) do
    servers = receive do
      :servers ->
        server_string = Map.values(servers)
                        |> Enum.map(fn elem -> elem.name end)
                        |> Enum.join(", ")

        IO.puts("Available server list: #{server_string}")
        servers

      {:register, %{name: name}=server_info} ->
        IO.puts("Registered new server: #{server_info.name}")
        Map.put(servers, name, server_info)

      {:dispatch, server_name} ->
        case Map.get(servers, server_name) do
          nil ->
            IO.puts("Cannot find server #{server_name}")
          %{name: name, pid: pid} ->
            IO.puts("Sending to #{name}")
            send(pid, "message")
          _ ->
            IO.puts("Unexpected condition. Aborting")
        end
        servers

      {:result, %{server: server, value: value, result: result}} ->
        IO.puts("Received result from #{server}")

      _ ->
        IO.puts("Unknown command")
        servers
    end

    ComputeFarm.dispatcher(servers)
  end
end
