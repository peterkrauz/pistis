defmodule Example.KVStore do
  alias Pistis.Request
  alias Pistis.Response
  @behaviour Pistis.Machine

  @spec initial_state :: %{}

  @impl Pistis.Machine
  def initial_state(), do: %{}

  @impl Pistis.Machine
  def process_command(%Request{body: {:get, key}}, current_state) do
    %Response{response: Map.get(current_state, key), state: current_state}
  end

  @impl Pistis.Machine
  def process_command(%Request{body: {:put, key, value}}, current_state) do
    %Response{response: :ok, state: Map.put(current_state, key, value)}
  end

  @impl Pistis.Machine
  def process_command(%Request{body: {:data}}, current_state) do
    response = Enum.zip(Map.keys(current_state), Map.values(current_state))
    %Response{response: response, state: current_state}
  end
end
