defmodule Pistis.Pod.RaftServer do
  @raft_cluster_name :pistis
  @machine_module Application.fetch_env!(:pistis, :machine)

  def cluster_name, do: @raft_cluster_name

  def start_raft_cluster(nodes) do
    :ra.start_cluster(:default, @raft_cluster_name, machine_spec(), nodes)
    |> collect_cluster_members()
    |> Pistis.Cluster.StateStorage.store()
  end

  defp collect_cluster_members({:ok, started_servers, failed_servers}) do
    {_, pod_address} = List.first(started_servers)
    {:ok, members, leader} = :ra.members({@raft_cluster_name, pod_address})
    {members, failed_servers, leader}
  end

  defp machine_spec(), do: {:module, @machine_module, %{}}

  # def dynamic_add({_, pod_address}) do
  #   :ra.add_member(get_leader_node(), raft_server_id(pod_address))
  #   :ra.start_server(
  #     :default,
  #     @raft_cluster_name,
  #     raft_server_id(pod_address),
  #     machine_spec(),
  #     [get_leader_node()]
  #   )
  # end
end
