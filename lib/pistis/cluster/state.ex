defmodule Pistis.Cluster.State do
  defstruct [:leader, :members, :failures]

  @type raft_member :: tuple()
  @type t :: %__MODULE__{
    leader: raft_member(),
    members: list(raft_member()),
    failures: list(raft_member()),
  }
end
