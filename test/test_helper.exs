defmodule TestCluster do
  @test_node_suffix for _ <- 1..10, into: "", do: <<Enum.random('0123456789abcdef')>>

  def start_slaves(number) do
    :net_kernel.monitor_nodes(true)
    :os.cmd('epmd -daemon')
    Node.start(:master@localhost, :shortnames)
    Enum.each(1..number, fn(index) ->
      :slave.start_link(:localhost, 'slave_#{@test_node_suffix}_#{index}')
    end)
    [node() | Node.list()]
  end

  def disconnect(list) do
    Enum.map(list, &Node.disconnect(&1))
  end
end

ExUnit.start()
