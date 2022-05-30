defmodule Example.KVStore do
  alias Pistis.Machine.Response
  @behaviour Pistis.Machine

  @spec initial_state :: %{}
  @spec process_command({:data} | {:get, any} | {:put, any, any}, map) :: %Response{response: any, state: map}

  @impl Pistis.Machine
  def initial_state(), do: %{}

  @impl Pistis.Machine
  def process_command({:get, key}, current_state) do
    %Response{response: Map.get(current_state, key), state: current_state}
  end

  @impl Pistis.Machine
  def process_command({:put, key, value}, current_state) do
    %Response{response: :ok, state: Map.put(current_state, key, value)}
  end

  @impl Pistis.Machine
  def process_command({:data}, current_state) do
    response = Enum.zip(Map.keys(current_state), Map.values(current_state))
    %Response{response: response, state: current_state}
  end
end
