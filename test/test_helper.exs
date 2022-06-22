defmodule TestCluster do
  @test_node_suffix for _ <- 1..10, into: "", do: <<Enum.random('56789vwxyz')>>

  def start_slaves() do
    cluster_size = Application.get_env(:pistis, :cluster_size, 5)

    :net_kernel.monitor_nodes(true)
    :os.cmd('epmd -daemon')
    Node.start(:master@localhost, :shortnames)
    Enum.each(1..cluster_size, fn (index) -> :slave.start_link(:localhost, 'pistis_test_pod_#{@test_node_suffix}_#{index}') end)
    [node() | Node.list()]
  end
end

ExUnit.start()
