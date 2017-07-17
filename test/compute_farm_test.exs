defmodule ComputeFarmTest do
  use ExUnit.Case
  doctest ComputeFarm

  test "available_servers matching some" do
    servers = %{"server_1" => %{name: "server_1", pid: 123, status: :avail},
                "server_2" => %{name: "server_2", pid: 456, status: :busy},
                "server_3" => %{name: "server_3", pid: 789, status: :avail}
              }
    assert ComputeFarm.available_servers(servers) == ["server_1", "server_3"]
  end

  test "available_servers matching none" do
    servers = %{"server_1" => %{name: "server_1", pid: 123, status: :busy},
                "server_2" => %{name: "server_2", pid: 456, status: :busy},
                "server_3" => %{name: "server_3", pid: 789, status: :busy}
              }
    assert ComputeFarm.available_servers(servers) == []
  end

  test "available_servers matching all" do
    servers = %{"server_1" => %{name: "server_1", pid: 123, status: :avail},
                "server_2" => %{name: "server_2", pid: 456, status: :avail},
                "server_3" => %{name: "server_3", pid: 789, status: :avail}
              }
    assert ComputeFarm.available_servers(servers) == ["server_1", "server_2", "server_3"]
  end
end
