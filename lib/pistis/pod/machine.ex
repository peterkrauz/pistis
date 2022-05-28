defmodule Pistis.Pod.Machine do
  @behaviour :ra_machine

  @side_effects []

  @spec init(any) :: map()
  @spec apply(any, {:data} | {:get, any} | {:put, any, any}, map) :: {map, any, []}

  @impl :ra_machine
  def init(_config), do: %{}

  @impl :ra_machine
  def apply(_command_metadata, {:get, key}, state) do
    {state, Map.get(state, key), @side_effects}
  end

  @impl :ra_machine
  def apply(_command_metadata, {:put, key, value}, state) do
    {Map.put(state, key, value), :ok, @side_effects}
  end

  @impl :ra_machine
  def apply(_command_metadata, {:data}, state) do
    data = Enum.zip(Map.keys(state), Map.values(state))
    {state, data, @side_effects}
  end
end
