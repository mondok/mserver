defmodule MServer do
  use Application

  def start(_type, _args) do
    MServer.Supervisor.start_link
  end
end
