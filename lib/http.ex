defmodule MServer.HTTP do
  def start_link do
    server = Socket.Web.listen! 8080
  end
end
