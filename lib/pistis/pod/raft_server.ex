defmodule Pistis.Pod.RaftServer do
  @raft_cluster_name :pistis
  @machine_module Application.fetch_env!(:pistis, :machine)

  def cluster_name, do: @raft_cluster_name

  def start_raft_cluster(nodes) do
    :ra.start_cluster(:default, @raft_cluster_name, machine_spec(), nodes)
    |> on_cluster_started()
    |> Pistis.Cluster.StateStorage.set()
  end

  defp on_cluster_started({:ok, started_servers, _}) do
    {_, pod_address} = List.first(started_servers)
    :ra.members({@raft_cluster_name, pod_address})
  end

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

  defp machine_spec(), do: {:module, @machine_module, %{}}
end
