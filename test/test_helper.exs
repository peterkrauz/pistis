defmodule TestCluster do
  def start_slaves(number) do
    :ok = :net_kernel.monitor_nodes(true)
    :os.cmd('epmd -daemon')
    Node.start(:master@localhost, :shortnames)
    Enum.each(1..number, fn(index) ->
      :slave.start_link(:localhost, 'slave_#{index}')
    end)
    [node() | Node.list()]
  end

  def disconnect(list) do
    Enum.map(list, &Node.disconnect(&1))
  end
end

ExUnit.start()
