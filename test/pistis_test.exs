defmodule PistisTest do
  use ExUnit.Case
  doctest Pistis

  test "basic operations still work" do
    cluster_size = Application.get_env(:pistis, :cluster_size, 5)
    TestCluster.start_slaves(cluster_size)

    Pistis.Cluster.Manager.start_cluster()

    Pistis.put(:a, 3)
    Pistis.put(:b, 2)
    assert Pistis.get(:a) == 3
    assert Pistis.get(:b) == 2

    Pistis.put(:a, 1)
    Pistis.put(:c, 3)

    assert Pistis.get(:a) == 1
    assert Pistis.get(:b) == 2
    assert Pistis.get(:c) == 3
    assert Pistis.data() == [a: 1, b: 2, c: 3]
  end
end
