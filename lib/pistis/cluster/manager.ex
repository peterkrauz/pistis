defmodule Pistis.Cluster.Manager do
  alias Pistis.Pod.RaftServer, as: Raft

  @cluster_size Application.get_env(:pistis, :cluster_size, 5)
  @node_suffix for _ <- 1..10, into: "", do: <<Enum.random('abc123')>>
  @cluster_boot_delay max(Application.get_env(:pistis, :cluster_boot_delay, 3500), 3500)

  def boot() do
    Pistis.DynamicSupervisor.supervise(Pistis.Cluster.StateStorage)
    nodes = create_cluster_nodes()
    :timer.sleep(@cluster_boot_delay)
    Raft.start_raft_cluster(nodes)
  end

  defp create_cluster_nodes() do
    Range.new(1, @cluster_size)
    |> Enum.map(&boot_pod/1)
    |> Enum.map(&Task.await/1)
  end

  def leader_node() do
    case Pistis.Cluster.StateStorage.read() do
      %Pistis.Cluster.State{leader: leader, members: _, failures: _} -> leader
      _ -> :error
    end
  end

  def any_node() do
    case Pistis.Cluster.StateStorage.read() do
      %Pistis.Cluster.State{leader: _, members: members, failures: _} ->
        index = :rand.uniform(length(members)) - 1
        Enum.at(members, index)
      _ -> :error
    end
  end

  def boot_pod(pod_index) do
    Task.async(fn ->
      start_pod(pod_index)
      |> connect_to_pod()
      |> Raft.to_server_id()
    end)
  end

  defp start_pod(pod_index) do
    pod_address = "#{Raft.cluster_name()}_node_#{@node_suffix}_#{pod_index}@localhost"
    Task.async(fn -> System.shell("iex --sname #{pod_address} -S mix") end) # TODO: This line needs to change
    String.to_atom(pod_address)
  end

  def connect_to_pod(pod_address) do
    :timer.sleep(@cluster_boot_delay)
    Node.connect(pod_address)
    :rpc.call(pod_address, Pistis.Pod, :start, [])
    pod_address
  end
end
