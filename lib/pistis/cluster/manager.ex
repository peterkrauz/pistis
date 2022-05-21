defmodule Pistis.Cluster.Manager do
  @raft_cluster_name "pistis"
  @node_boot_delay 750

  def start_cluster() do
    cluster_nodes = Range.new(1, 5) |> Enum.map(&start_pod/1)
    # :ra.start_cluster(:default, @raft_cluster_name, machine_spec(), [])
  end

  defp machine_spec(), do: {:module, Pistis.Pod.Machine, %{}}

  defp start_pod(_arg) do
    get_next_pod_name()
    |> boot_pod()
    |> beam_connect()
  end

  defp get_next_pod_name() do
    node_number = Enum.count(Node.list()) + 1
    "#{@raft_cluster_name}_node_#{node_number}"
  end

  defp boot_pod(pod_name) do
    pod_address = "#{pod_name}@localhost"
    Task.async(fn ->
      System.shell("iex --sname #{pod_address} -S mix")
      :rpc.call(String.to_atom(pod_address), Pistis.Pod.RaftServer, :start, [])
    end)
    :timer.sleep(@node_boot_delay)
    pod_name
  end

  def leader_node(), do: cluster_members() |> Map.get(:leader)

  defp server_nodes(), do: all_nodes() |> Enum.filter(&is_server_node/1)
  defp all_nodes(), do: [Node.self() | Node.list()]
  defp is_server_node(node_address), do: Atom.to_string(node_address) |> String.contains?(@raft_cluster_name)

  defp add_raft_member(node) do
    :ra.add_member(leader_node(), server_id(node))
  end

  defp server_id(node_address) when is_atom(node_address), do: {@raft_cluster_name, node_address}
  defp server_id(node_address) when is_binary(node_address), do: {@raft_cluster_name, :"#{node_address}@localhost"}

  defp cluster_members() do
    case :ra.members({@raft_cluster_name, node()}) do
      {:ok, server_ids, leader_id} -> %{members: server_ids, leader: leader_id}
      error_tuple -> error_tuple
    end
  end

  defp beam_connect(node_name) when is_binary(node_name), do: beam_connect(:"#{node_name}@localhost")

  defp beam_connect(node_address) when is_atom(node_address) do
    Node.connect(node_address)
    node_address
  end

end
