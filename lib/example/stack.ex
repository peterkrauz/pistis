defmodule Example.Stack do
  alias Pistis.Machine.Response
  @behaviour Pistis.Machine

  @spec initial_state :: []
  @spec process_command({:peek} | {:pop} | {:push, any}, any) :: Response.t()

  @impl Pistis.Machine
  def initial_state(), do: []

  @impl Pistis.Machine
  def process_command({:push, item}, state) do
    %Response{response: :ok, state: [item | state]}
  end

  @impl Pistis.Machine
  def process_command({:pop}, []), do: %Response{response: :empty_list, state: []}

  @impl Pistis.Machine
  def process_command({:pop}, state) do
    [head | tail] = state
    %Response{response: head, state: tail}
  end

  @impl Pistis.Machine
  def process_command({:peek}, []), do: %Response{response: :empty_list, state: []}

  @impl Pistis.Machine
  def process_command({:peek}, state) do
    [head | _] = state
    %Response{response: head, state: state}
  end

end
