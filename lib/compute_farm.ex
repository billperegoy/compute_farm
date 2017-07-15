defmodule ComputeFarm do
  def server(dispatcher_pid, name, options \\ %{register: true}) do
    if options.register do
      send(dispatcher_pid, {:register, %{name: name, pid: self}})
    end

    receive do 
      message -> IO.puts("Server #{name} received #{message}")
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
            IO.puts("Senidng to #{name}")
            send(pid, "message")
          _ ->
            IO.puts("Unexpected condition. Aborting")
        end
        servers

      _ ->
        IO.puts("Unknown command")
        servers
    end

    ComputeFarm.dispatcher(servers)
  end
end
