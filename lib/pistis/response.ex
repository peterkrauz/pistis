defmodule Pistis.Response do
  defstruct [:response, :state]
  @type t() :: %__MODULE__{response: any(), state: any()}
end
