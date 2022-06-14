defmodule Pistis.Machine do
  alias Pistis.Machine.Request
  alias Pistis.Machine.Response

  @type machine_state :: any()
  @callback initial_state() :: machine_state()
  @callback process_command(Request.t(), machine_state()) :: Response.t()
end
