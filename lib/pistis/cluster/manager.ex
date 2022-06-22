defmodule Pistis.Cluster.Manager do
  alias Pistis.Cluster.StateStorage
  alias Pistis.Pod
  alias Pistis.Pod.Raft
  use Pistis.Core.Journal

  @cluster_size max(Application.get_env(:pistis, :cluster_size, 5), 3)
  @native_cluster Application.get_env(:pistis, :native_cluster, false)
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
    case @native_cluster do
      true -> create_cluster()
      false -> connect_to_cluster()
    end
  end

  defp create_cluster() do
    Range.new(1, @cluster_size)
    |> Enum.map(&Pod.create_pod/1)
    |> Enum.map(&Task.await/1)
  end

  defp connect_to_cluster() do
    pistis_nodes(as_raft: false)
    |> Enum.map(&Pod.boot_raft/1)
  end

  def wait(), do: :timer.sleep(@cluster_boot_delay)

  def erlang_connect(pod_address) do
    Node.connect(pod_address)
    pod_address
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

  def erlang_nodes, do: [Node.self() | Node.list()]

  def pistis_nodes(as_raft: false) do
    erlang_nodes() |> Enum.filter(&is_pistis_replica/1)
  end

  def pistis_nodes(as_raft: true) do
    pistis_nodes(as_raft: false) |> Enum.map(&Pistis.Pod.Raft.to_server_id/1)
  end

  def is_pistis_replica(node) do
    Atom.to_string(node) |> String.contains?("pistis")
  end

  def refresh_cluster_state() do
    {_, node_address} = leader_node()
    {:ok, refreshed_members, _} = Raft.cluster_members(node_address)

    catalogued_failures = StateStorage.read().failures
    solved_failures = Enum.filter(catalogued_failures, fn f_node -> f_node in refreshed_members end)
    unsolved_failures = Enum.filter(catalogued_failures, fn f_node -> f_node not in refreshed_members end)

    new_members = Map.get(StateStorage.read(), :members) ++ solved_failures


    scribe("Refreshing cluster state...")

    scribe("Catalogued failures: ")
    Enum.each(catalogued_failures, fn {_, address} -> IO.puts("\t #{Atom.to_string(address)}") end)

    scribe("Solved failures: ")
    Enum.each(solved_failures, fn {_, address} -> IO.puts("\t #{Atom.to_string(address)}") end)

    scribe("Unsolved failures: ")
    Enum.each(unsolved_failures, fn {_, address} -> IO.puts("\t #{Atom.to_string(address)}") end)

    scribe("New members: ")
    Enum.each(new_members, fn {_, address} -> IO.puts("\t #{Atom.to_string(address)}") end)

    StateStorage.store(members: new_members)
    StateStorage.store(failures: unsolved_failures)
  end

  def create_node(pod_index) do
    pod_address = "#{Raft.cluster_name()}_node#{pod_index}_#{node_salt()}@localhost"
    Task.async(fn -> System.shell("iex --sname #{pod_address} -S mix") end) # TODO: Find other way to boot stuff
    String.to_atom(pod_address)
  end

  def node_salt() do
    for _ <- 1..10, into: "", do: <<Enum.random('abcde12345')>>
  end
end
