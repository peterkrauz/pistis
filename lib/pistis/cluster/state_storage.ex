defmodule Pistis.Cluster.StateStorage do
  use GenServer

  @me __MODULE__

  def start_link(_args) do
    GenServer.start_link(@me, [], name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def get(), do: GenServer.call(@me, {:get})

  def set({:ok, members, leader}) do
    GenServer.call(@me, {:set, %{members: members, leader: leader}})
  end

  def handle_call({:get}, _, state) do
    {:reply, state, state}
  end

  def handle_call({:set, new_state}, _, _) do
    {:reply, new_state, new_state}
  end

end
