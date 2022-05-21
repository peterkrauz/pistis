defmodule Pistis.Cluster.Manager do
  @boot_delay 2500
  @raft_cluster_name :pistis

  def start_cluster() do
    cluster_nodes = Range.new(1, 5)
    |> Enum.map(fn pod_index -> Task.async(fn -> boot_pod(pod_index) end) end)
    |> Enum.map(&Task.await/1)

    :timer.sleep(@boot_delay)
    :ra.start_cluster(:default, @raft_cluster_name, machine_spec(), cluster_nodes)
  end

  def boot_pod(pod_index) do
    start_pod(pod_index)
    |> connect_to_pod()
    |> raft_server_id()
  end

  defp start_pod(pod_index) do
    pod_address = "#{@raft_cluster_name}_node_#{pod_index}@localhost"
    Task.async(fn -> System.shell("iex --sname #{pod_address} -S mix") end)
    String.to_atom(pod_address)
  end

  def connect_to_pod(pod_address) do
    :timer.sleep(@boot_delay)
    Node.connect(pod_address)
    :rpc.call(pod_address, Pistis.Pod, :start, [])
    pod_address
  end

  def members(), do: :ra.members(@raft_cluster_name)

  defp machine_spec(), do: {:module, Pistis.Pod.Machine, %{}}

  defp raft_server_id(node_address) when is_atom(node_address), do: {@raft_cluster_name, node_address}
  defp raft_server_id(node_address) when is_binary(node_address), do: {@raft_cluster_name, :"#{node_address}@localhost"}
end
