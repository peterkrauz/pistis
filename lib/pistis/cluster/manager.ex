defmodule Pistis.Cluster.Manager do
  @boot_delay 2500
  @raft_cluster_name :pistis

  def start_cluster() do
    cluster_nodes = Range.new(1, 5)
    |> Enum.map(&boot_pod/1)
    |> Enum.map(&Task.await/1)

    Pistis.CentralSupervisor.supervise(Pistis.Cluster.StateStorage)

    :timer.sleep(@boot_delay)
    :ra.start_cluster(:default, @raft_cluster_name, machine_spec(), cluster_nodes)
    |> on_cluster_started()
    |> Pistis.Cluster.StateStorage.set()
  end

  defp on_cluster_started({:ok, started_servers, failed_nodes}) do
    IO.puts(
      "on_cluster_started with #{length(started_servers)} started servers and #{length(failed_nodes)} failed servers."
    )
    started_servers
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

  def get_leader_node() do
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

  defp machine_spec(), do: {:module, Pistis.Pod.Machine, %{}}

  defp raft_server_id(node_address) when is_atom(node_address), do: {@raft_cluster_name, node_address}
end
