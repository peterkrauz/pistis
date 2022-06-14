defmodule Pistis.Cluster.Manager do
  alias Pistis.Cluster.StateStorage
  alias Pistis.Pod
  alias Pistis.Pod.Raft

  @cluster_size Application.get_env(:pistis, :cluster_size, 5)
  @node_suffix for _ <- 1..10, into: "", do: <<Enum.random('abc123')>>
  @native_cluster Application.get_env(:pistis, :native_cluster, false) # TODO: Tweak this when testing

  def boot() do
    Pistis.DynamicSupervisor.supervise(Pistis.Cluster.StateStorage)

    cluster = case @native_cluster do
      true -> create_cluster()
      false -> connect_to_cluster()
    end

    :timer.sleep(Pod.boot_delay())
    cluster
    |> Raft.start_raft_cluster()
    |> StateStorage.store()
  end

  defp create_cluster() do
    Range.new(1, @cluster_size)
    |> Enum.map(&Pod.create_pod/1)
    |> Enum.map(&Task.await/1)
  end

  defp connect_to_cluster() do
    # TODO: Connect to Erlang nodes with :pistis_node_<number> where number in [0 .. @cluster_size]
    Range.new(1, @cluster_size)
    |> Enum.map(&Pod.connect_to_pod/1)
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

  def create_node(pod_index) do
    pod_address = "#{Raft.cluster_name()}_node_#{@node_suffix}_#{pod_index}@localhost"
    Task.async(fn -> System.shell("iex --sname #{pod_address} -S mix") end) # TODO: Find other way to boot stuff
    String.to_atom(pod_address)
  end
end
