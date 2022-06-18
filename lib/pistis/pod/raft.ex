defmodule Pistis.Pod.Raft do
  alias Pistis.Cluster.Manager
  alias Pistis.Pod.MachineWrapper

  @raft_cluster_name :pistis

  @spec cluster_name :: :pistis
  @spec start_raft_cluster(keyword(atom)) :: any

  def cluster_name, do: @raft_cluster_name

  def start_raft_cluster([]) do
    raise RuntimeError, message: "No pistis cluster found -- did you forget to configure your network cluster?"
  end

  def start_raft_cluster(nodes) do
    :ra.start_cluster(:default, cluster_name(), MachineWrapper.machine_spec(), nodes)
    |> collect_raft_members()
  end

  def cluster_members() do
    {@raft_cluster_name, pod_address} = Manager.leader_node()
    :ra.members({cluster_name(), pod_address})
  end

  def cluster_members(pod_address), do: :ra.members({cluster_name(), pod_address})

  defp collect_raft_members({:ok, started_servers, failed_servers}) do
    {_, pod_address} = List.first(started_servers)
    {_, members, leader} = cluster_members(pod_address)
    {members, failed_servers, leader}
  end

  def to_server_id(node_address), do: {cluster_name(), node_address}

  def dynamic_add({_, pod_address}) do
    :ra.add_member(Manager.leader_node(), to_server_id(pod_address))
    :ra.start_server(
      :default,
      cluster_name(),
      to_server_id(pod_address),
      MachineWrapper.machine_spec(),
      [Manager.leader_node()]
    )
    Manager.refresh_cluster_state()
  end
end
