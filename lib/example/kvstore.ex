defmodule Example.KVStore do
  @behaviour Pistis.Machine

  @spec initial_state :: %{}
  @spec process_command({:data} | {:get, any} | {:put, any, any}, map) :: {any, map}

  @impl Pistis.Machine
  def initial_state(), do: %{}

  @impl Pistis.Machine
  def process_command({:get, key}, current_state) do
    {Map.get(current_state, key), current_state}
  end

  @impl Pistis.Machine
  def process_command({:put, key, value}, current_state) do
    {:ok, Map.put(current_state, key, value)}
  end

  @impl Pistis.Machine
  def process_command({:data}, current_state) do
    response = Enum.zip(Map.keys(current_state), Map.values(current_state))
    {response, current_state}
  end
end
