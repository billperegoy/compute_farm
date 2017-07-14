defmodule ComputeFarm do
  def server(dispatcher_pid, name) do
    send(dispatcher_pid, {:register, %{name: name}})
    receive do 
      message -> IO.puts("Server #{name} received #{message}")
    end
    ComputeFarm.server(dispatcher_pid, name)
  end

  def dispatcher(servers \\ []) do
    receive do
      :servers ->
        server_string = Enum.join(servers, ", ")
        IO.puts("Available server list: #{server_string}")

      {:register, server_info} ->
        servers = [server_info.name | servers]
        IO.puts("Registered new server: #{server_info.name}")

      _ ->
        IO.puts("Unknown command")
    end
    ComputeFarm.dispatcher(servers)
  end
end
