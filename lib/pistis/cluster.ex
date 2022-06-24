defmodule Pistis.Cluster do
  def boot() do
    Pistis.Cluster.Manager.boot()
    Pistis.Cluster.StateRefresher.boot()
    Pistis.Cluster.ConnectionRetrier.boot()
  end

  def primary_node_name(), do: :"primary@127.0.0.1"

  def node_name(node_host) do
    node_host
    |> to_string
    |> String.split("@")
    |> Enum.at(0)
    |> String.to_atom()
  end

  def setup_current_node() do
    toggle_distributed_if_necessary()
    boot_erl_server()
  end

  defp toggle_distributed_if_necessary() do
    if Node.self() |> Atom.to_string() |> String.contains?("nonode") do
      :net_kernel.start([Pistis.Cluster.primary_node_name()])
    end
  end

  defp boot_erl_server() do
    :erl_boot_server.start([])
    to_charlist("127.0.0.1") |> allow_boot()
  end

  defp allow_boot(host) do
    {:ok, ipv4} = :inet.parse_ipv4_address(host)
    :erl_boot_server.add_slave(ipv4)
  end
end
