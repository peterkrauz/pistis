defmodule Pistis.Cluster.Manager do
  @boot_delay 2500
  @cluster_size Application.fetch_env!(:pistis, :cluster_size)

  alias Pistis.CentralSupervisor
  alias Pistis.Pod.RaftServer, as: Raft

  def start_cluster() do
    CentralSupervisor.supervise(Pistis.Cluster.StateStorage)
    nodes = create_cluster_nodes()
    :timer.sleep(@boot_delay)
    Raft.start_raft_cluster(nodes)
  end

  defp create_cluster_nodes() do
    Range.new(1, @cluster_size)
    |> Enum.map(&boot_pod/1)
    |> Enum.map(&Task.await/1)
  end

  def leader_node() do
    Pistis.Cluster.StateStorage.read().leader
  end

  def boot_pod(pod_index) do
    Task.async(fn ->
      start_pod(pod_index)
      |> connect_to_pod()
      |> raft_server_id()
    end)
  end

  defp start_pod(pod_index) do
    pod_address = "#{Raft.cluster_name()}_node_#{pod_index}@localhost"
    Task.async(fn -> System.shell("iex --sname #{pod_address} -S mix") end)
    String.to_atom(pod_address)
  end

  def connect_to_pod(pod_address) do
    :timer.sleep(@boot_delay)
    Node.connect(pod_address)
    :rpc.call(pod_address, Pistis.Pod, :start, [])
    pod_address
  end

  defp raft_server_id(node_address), do: {Raft.cluster_name(), node_address}
end
