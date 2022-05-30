defmodule Pistis.Machine do
  defmodule Response do
    defstruct [:response, :state]
    @type t() :: %__MODULE__{response: any(), state: any()}
  end

  @type machine_state :: any()
  @callback initial_state() :: machine_state()
  @callback process_command(tuple(), machine_state()) :: Response.t()
end
