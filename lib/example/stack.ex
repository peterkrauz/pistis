defmodule Example.Stack do
  alias Pistis.Machine.Request
  alias Pistis.Machine.Response
  @behaviour Pistis.Machine

  @spec initial_state :: []

  @impl Pistis.Machine
  def initial_state(), do: []

  @impl Pistis.Machine
  def process_command(%Request{body: {:push, item}}, state) do
    %Response{response: :ok, state: [item | state]}
  end

  @impl Pistis.Machine
  def process_command(%Request{body: {:pop}}, []), do: %Response{response: :empty_list, state: []}

  @impl Pistis.Machine
  def process_command(%Request{body: {:pop}}, state) do
    [head | tail] = state
    %Response{response: head, state: tail}
  end

  @impl Pistis.Machine
  def process_command(%Request{body: {:peek}}, []), do: %Response{response: :empty_list, state: []}

  @impl Pistis.Machine
  def process_command(%Request{body: {:peek}}, state) do
    [head | _] = state
    %Response{response: head, state: state}
  end

end
