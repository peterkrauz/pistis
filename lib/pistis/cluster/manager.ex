defmodule Pistis.Cluster.Manager do
  @boot_delay 2500
  @raft_cluster_name :pistis
  @machine_module Application.fetch_env!(:pistis, :machine)
  @cluster_size Application.fetch_env!(:pistis, :cluster_size)

  def start_cluster() do
    Pistis.CentralSupervisor.supervise(Pistis.Cluster.StateStorage)
    nodes = create_cluster_nodes()
    :timer.sleep(@boot_delay)
    start_raft_cluster(nodes)
  end

  defp create_cluster_nodes() do
    Range.new(1, @cluster_size)
    |> Enum.map(&boot_pod/1)
    |> Enum.map(&Task.await/1)
  end

  defp start_raft_cluster(nodes) do
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

  def leader_node() do
    Pistis.Cluster.StateStorage.get() |> Map.get(:leader)
  end

  def boot_pod(pod_index) do
    Task.async(fn ->
      start_pod(pod_index)
      |> connect_to_pod()
      |> raft_server_id()
    end)
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

  defp machine_spec(), do: {:module, @machine_module, %{}}

  defp raft_server_id(node_address) when is_atom(node_address), do: {@raft_cluster_name, node_address}
end
