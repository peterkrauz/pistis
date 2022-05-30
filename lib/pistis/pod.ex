defmodule Pistis.Pod do
  def start() do
    :ra.start()

    # Also start some sort of health checker to
    # supervise this Node's Pistis.Pod.Machine
  end
end
