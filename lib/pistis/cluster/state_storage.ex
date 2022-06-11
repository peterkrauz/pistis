defmodule Pistis.Cluster.StateStorage do
  use GenServer
  alias Pistis.Cluster.State, as: ClusterState

  @me __MODULE__

  def start_link(_args), do: GenServer.start_link(@me, %{}, name: @me)

  def init(state), do: {:ok, state}

  def read(), do: GenServer.call(@me, {:read})

  def store({all_members, failures, leader}) do
    members = Enum.filter(all_members, fn m -> m not in failures end)
    new_state = %ClusterState{members: members, failures: failures, leader: leader}
    store_state(new_state)
  end

  def store(members: members) do
    new_state = Map.put(read(), :members, members)
    store_state(new_state)
  end

  def store(failures: failures) do
    new_state = Map.put(read(), :failures, failures)
    store_state(new_state)
  end

  def store(leader: leader) do
    new_state = Map.put(read(), :leader, leader)
    store_state(new_state)
  end

  defp store_state(new_state), do: GenServer.call(@me, {:store, new_state})

  def handle_call({:read}, _, state), do: {:reply, state, state}

  def handle_call({:store, new_state}, _, _), do: {:reply, new_state, new_state}

end
