defmodule Pistis.Cluster.StateStorage do
  use GenServer
  alias Pistis.Cluster.State, as: ClusterState

  @me __MODULE__

  def start_link(_args), do: GenServer.start_link(@me, %{}, name: @me)

  def init(state), do: {:ok, state}

  def read(), do: GenServer.call(@me, {:read})

  def store({all_members, failures, leader}) do
    members = Enum.filter(all_members, fn m -> m not in failures end)
    GenServer.call(@me, {:store, %ClusterState{members: members, leader: leader, failures: failures}})
  end

  def handle_call({:read}, _, state), do: {:reply, state, state}

  def handle_call({:store, new_state}, _, _), do: {:reply, new_state, new_state}

end
