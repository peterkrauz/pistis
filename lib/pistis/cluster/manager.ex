defmodule Pistis.Cluster.Manager do
  @boot_delay 2500
  @cluster_size Application.fetch_env!(:pistis, :cluster_size)
  @node_suffix for _ <- 1..10, into: "", do: <<Enum.random('0123456789abcdef')>>

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
    case Pistis.Cluster.StateStorage.read() do
      %Pistis.Cluster.State{leader: leader, members: _, failures: _} -> leader
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
    Task.async(fn -> System.shell("iex --sname #{pod_address} -S mix") end)
    String.to_atom(pod_address)
  end

  def connect_to_pod(pod_address) do
    :timer.sleep(@boot_delay)
    Node.connect(pod_address)
    :rpc.call(pod_address, Pistis.Pod, :start, [])
    pod_address
  end
end
