defmodule ComputeFarm do

  defp factorial(0), do: 1
  defp factorial(n), do: n * factorial(n-1)

  def available_servers(servers) do
    Map.values(servers)
    |> Enum.filter(fn elem -> elem.status == :avail end)
    |> Enum.map(fn elem -> elem.name end)
  end

  defp dispatch(servers, server_name) do
    server_info = Map.get(servers, server_name)
    case server_info do
      nil ->
        IO.puts("Cannot find server #{server_name}")
        servers

      %{name: name, pid: pid} ->
        IO.puts("Sending to #{name}")
        send(pid, "message")
        server_info = %{server_info | :status => :busy}
        IO.inspect(%{servers | name => server_info})
        %{servers | server_name => server_info}

      _ ->
        IO.puts("Unexpected condition. Aborting")
        servers
    end
  end

  def server(dispatcher_pid, name, options \\ %{register: true}) do
    if options.register do
      send(dispatcher_pid, {:register, %{name: name, pid: self(), status: :avail}})
    end

    receive do 
      message -> IO.puts("Server #{name} received #{message}")
      value = 100_000 * Enum.random(3..3)
      IO.puts("Computing factorial of #{value}...")
      result = factorial(value)
      IO.puts("Computation complete")
      send(dispatcher_pid, {:result, %{server: name, value: value, result: result}})
      ComputeFarm.server(dispatcher_pid, name, %{register: false})
    end
  end

  def dispatcher(servers \\ %{}, queue \\ []) do
    {servers, queue} = receive do
      :servers ->
        server_string = Map.values(servers)
                        |> Enum.map(fn elem -> "#{elem.name}: #{elem.status}" end)
                        |> Enum.join(", ")

        IO.puts("Available server list: #{server_string}")
        {servers, queue}

      {:register, %{name: name}=server_info} ->
        IO.puts("Registered new server: #{server_info.name}")
        {Map.put(servers, name, server_info), queue}

      {:dispatch, server_name} ->
        {dispatch(servers, server_name), queue}

      {:result, %{server: server}} ->
        IO.puts("Received result from #{server}")
        server_info = Map.get(servers, server)
        server_info = %{server_info | :status => :avail}
        {%{servers | server => server_info}, queue}

      {:queue, job} ->
        {servers, queue} = case available_servers(servers) do
          [] ->
            {servers, [job | queue]}

          list ->
            server_name = List.first(list)
            # FIXME - server not getting marked :busy
            {dispatch(servers, server_name), queue}
        end
        {servers, queue}

      :show_queue ->
        IO.inspect(queue)
        {servers, queue}

      _ ->
        IO.puts("Unknown command")
        {servers, queue}
    end

    ComputeFarm.dispatcher(servers, queue)
  end
end
