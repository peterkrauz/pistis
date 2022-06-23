defmodule Pistis.Cluster.Manager do
  alias Pistis.Cluster.StateStorage
  alias Pistis.Pod
  alias Pistis.Pod.Raft
  use Pistis.Core.Journal

  @known_hosts Application.get_env(:pistis, :known_hosts, [])
  @cluster_size max(Application.get_env(:pistis, :cluster_size, 3), 3)
  @cluster_boot_delay max(Application.get_env(:pistis, :cluster_boot_delay, 4000), 4000)

  def boot() do
    Pistis.Core.Supervisor.supervise(Pistis.Cluster.StateStorage)

    cluster = get_or_create_cluster()
    wait()

    cluster
    |> Raft.start_raft_cluster()
    |> StateStorage.store()
  end

  defp get_or_create_cluster() do
    if nodes_to_spawn_count() > 0 do
      scribe("Spawning #{nodes_to_spawn_count()} additional nodes")
      Pistis.Cluster.Spawner.spawn_nodes(nodes_to_spawn_count())
      wait()
    end

    connect_to_cluster()
  end

  defp nodes_to_spawn_count(), do: @cluster_size - length(@known_hosts)

  defp connect_to_cluster() do
    pistis_nodes() |> Enum.map(&Pod.boot_raft/1)
  end

  def wait(), do: :timer.sleep(@cluster_boot_delay)

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

  def pistis_nodes(), do: pistis_nodes(as_raft: false)

  def pistis_nodes(as_raft: true) do
    pistis_nodes() |> Enum.map(&Pistis.Pod.Raft.to_server_id/1)
  end

  def pistis_nodes(as_raft: false) do
    base_pistis_nodes = erlang_nodes() |> Enum.filter(&is_pistis_replica/1)
    (@known_hosts ++ base_pistis_nodes)
    |> MapSet.new()
    |> MapSet.to_list()
  end

  defp erlang_nodes, do: [Node.self() | Node.list()]

  def is_pistis_replica(node_name) do
    Atom.to_string(node_name) |> String.contains?("pistis_node")
  end
end
