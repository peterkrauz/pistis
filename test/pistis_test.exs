defmodule PistisTest do
  use ExUnit.Case

  test "basic kv store operations work" do
    cluster_size = Application.get_env(:pistis, :cluster_size, 5)
    TestCluster.start_slaves(cluster_size)

    Pistis.Cluster.Manager.boot()

    CLI.put(:a, 3)
    CLI.put(:b, 2)
    assert CLI.get(:a) == 3
    assert CLI.get(:b) == 2

    CLI.put(:a, 1)
    CLI.put(:c, 3)

    assert CLI.get(:a) == 1
    assert CLI.get(:b) == 2
    assert CLI.get(:c) == 3
    assert CLI.data() == [a: 1, b: 2, c: 3]
  end
end
