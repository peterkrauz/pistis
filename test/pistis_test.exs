defmodule PistisTest do
  use ExUnit.Case
  alias Pistis.Cluster.Manager
  alias Pistis.Machine.{Request, Response}

  test "basic kv store operations work" do
    TestCluster.start_slaves()
    Manager.boot()

    CLI.put(:a, 3)
    CLI.put(:b, 2)

    assert CLI.get(:a) == 3
    assert CLI.get(:b) == 2
    assert CLI.data() == [a: 3, b: 2]

    CLI.put(:a, 1)
    CLI.put(:c, 3)

    assert CLI.get(:a) == 1
    assert CLI.get(:c) == 3
    assert CLI.data() == [a: 1, b: 2, c: 3]

    Enum.map(Manager.pistis_nodes(as_raft: false),  fn address -> :rpc.call(address, Node, :stop, []) end)
  end

  # test "" do
  #   TestCluster.start_slaves()
  #   Manager.boot()
  #   pistis_nodes = Manager.pistis_nodes(as_raft: true)
  #   put_request = %Request{body: {:put, :e, 5}}
  #   put_response = Enum.map(pistis_nodes, fn node -> :ra.process_command(node, put_request) end
  #   get_request = %Request{body: {:get, :e, 5}}
  #   get_response = Enum.map(nodes, fn node -> :ra.process_command(node, get_request) end)
  #   Enum.map(Manager.pistis_nodes(as_raft: false),  fn address -> :rpc.call(address, Node, :stop, []) end)
  # end
end
