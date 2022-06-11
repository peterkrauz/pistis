defmodule Pistis.Pod.RaftServer do
  alias Pistis.Pod.MachineWrapper
  alias Pistis.Cluster.Manager
  alias Pistis.Cluster.StateStorage

  @raft_cluster_name :pistis

  @spec cluster_name :: :pistis
  @spec start_raft_cluster(keyword(atom)) :: any

  def cluster_name, do: @raft_cluster_name

  def start_raft_cluster(nodes) do
    :ra.start_cluster(:default, cluster_name(), MachineWrapper.machine_spec(), nodes)
    |> collect_cluster_members()
    |> Pistis.Cluster.StateStorage.store()
  end

  def cluster_members() do
    {@raft_cluster_name, pod_address} = Map.get(Pistis.Cluster.StateStorage.read(), :leader)
    :ra.members({cluster_name(), pod_address})
  end

  def cluster_members(pod_address), do: :ra.members({cluster_name(), pod_address})

  defp collect_cluster_members({:ok, started_servers, failed_servers}) do
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
    refresh_cluster_state()
  end

  defp refresh_cluster_state() do
    {_, n} = Manager.leader_node()
    {:ok, refreshed_members, _} = cluster_members(n)

    catalogued_failures = StateStorage.read() |> Map.get(:failures)
    solved_failures = Enum.filter(catalogued_failures, fn f_node -> f_node in refreshed_members end)
    unsolved_failures = Enum.filter(catalogued_failures, fn f_node -> f_node not in refreshed_members end)

    new_members = Map.get(StateStorage.read(), :members) ++ solved_failures
    StateStorage.store(members: new_members)
    StateStorage.store(failures: unsolved_failures)
  end
end
