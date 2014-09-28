defmodule Chat.Server do

  use GenServer

  #Client
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def enter(server, name) do
    GenServer.call(server, {:enter, name})
  end

  def leave(server, name) do
    GenServer.call(server, {:leave, name})
  end

  def say(server, message) do
    GenServer.call(server, {:say, message})
  end

  # Callbacks

  def init(args) do
    { :ok, HashDict.new() }
  end

  def handle_call({:enter, name}, from, users) do
    {pid, reference} = from
    users = HashDict.put(users, name, pid)
    send_all(users, "#{name} has entered")
    { :reply, :ok, users }
  end

  def handle_call({:leave, name}, from, users) do
    { :reply, :ok, HashDict.delete(users, name) }
  end

  def handle_call({:say, message}, from, users) do
    send_all(users, message)
  end

  defp send_all(users, message) do
    Enum.each(Dict.to_list(users), fn { user, pid } ->
      send pid, {:ok , message}
    end)
  end
end

{:ok , pid } = Chat.Server.start_link([])
Chat.Server.enter(pid, 'paulo')

receive do
  { :ok, message } -> IO.puts "RECEIVED: #{message}"
end



