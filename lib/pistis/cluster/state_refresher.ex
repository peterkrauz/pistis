defmodule Pistis.Cluster.StateRefresher do
  use GenServer
  use Pistis.Core.Journal
  alias Pistis.Cluster.Manager
  alias Pistis.Cluster.StateStorage
  alias Pistis.Pod.Raft

  @me __MODULE__
  @heartbeat 2000

  def boot(), do: Pistis.Core.Supervisor.supervise(@me)

  def start_link(_args \\ []), do: GenServer.start_link(@me, %{}, name: @me)

  def init(state) do
    schedule_work(@heartbeat * 5)
    {:ok, state}
  end

  def handle_info(:work, state) do
    scribe("Refreshing cluster state...")
    refresh_cluster_state()
    schedule_work(@heartbeat)
    {:noreply, state}
  end

  defp refresh_cluster_state() do
    {_, node_address} = Manager.leader_node()
    {:ok, refreshed_members, leader} = Raft.cluster_members(node_address)

    current_state = StateStorage.read()
    catalogued_failures = current_state.failures
    solved_failures = Enum.filter(catalogued_failures, fn f_node -> f_node in refreshed_members end)
    unsolved_failures = Enum.filter(catalogued_failures, fn f_node -> f_node not in refreshed_members end)

    new_members = Map.get(StateStorage.read(), :members) ++ solved_failures

    StateStorage.store(members: new_members)
    StateStorage.store(failures: unsolved_failures)

    unless current_state.leader == leader do
      StateStorage.store(leader: leader)
    end
  end

  defp schedule_work(delay) do
    Process.send_after(self(), :work, delay)
  end
end
