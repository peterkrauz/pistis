defmodule PistisTest do
  use ExUnit.Case
  doctest Pistis

  test "basic operations still work" do
    nodes = slaves = TestCluster.start_slaves(5)
    Pistis.Cluster.Manager.start_cluster()

    Pistis.put(:a, 3)
    Pistis.put(:b, 2)
    Pistis.put(:a, 1)

    assert Pistis.get(:a) == 1
    assert Pistis.get(:b) == 2
    assert Pistis.data() == [a: 1, b: 2]
  end
end
