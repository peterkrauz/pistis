defmodule Pistis.Cluster.Manager do
  alias Pistis.Cluster.StateStorage
  alias Pistis.Pod
  alias Pistis.Pod.Raft

  @cluster_size Application.get_env(:pistis, :cluster_size, 5)

  def boot() do
    Pistis.DynamicSupervisor.supervise(Pistis.Cluster.StateStorage)

    pod_cluster = create_pod_cluster()
    :timer.sleep(Pod.boot_delay())

    Raft.start_raft_cluster(pod_cluster)
    |> StateStorage.store()
  end

  defp create_pod_cluster() do
    Range.new(1, @cluster_size)
    |> Enum.map(&Pod.boot_pod/1)
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

  def refresh_cluster_state() do
    {_, n} = leader_node()
    {:ok, refreshed_members, _} = Raft.cluster_members(n)

    catalogued_failures = StateStorage.read().failures
    solved_failures = Enum.filter(catalogued_failures, fn f_node -> f_node in refreshed_members end)
    unsolved_failures = Enum.filter(catalogued_failures, fn f_node -> f_node not in refreshed_members end)

    new_members = Map.get(StateStorage.read(), :members) ++ solved_failures
    StateStorage.store(members: new_members)
    StateStorage.store(failures: unsolved_failures)
  end
end
