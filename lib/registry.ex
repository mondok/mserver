defmodule MServer.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(event_manager, buckets, opts \\ []) do
    GenServer.start_link(__MODULE__, {event_manager, buckets}, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` in case a bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ## Server callbacks

  def init({events, buckets}) do
    names = HashDict.new
    refs  = HashDict.new
    # 2. Store the buckets supervisor in the state
    {:ok, %{names: names, refs: refs, events: events, buckets: buckets}}
  end

  def handle_call({:lookup, name}, _from, state) do
    {:reply, HashDict.fetch(state.names, name), state}
  end

  def handle_cast({:create, name}, state) do
    if HashDict.get(state.names, name) do
      {:noreply, state}
    else
      # 3. Use the buckets supervisor instead of starting buckets directly
      {:ok, pid} = MServer.Bucket.Supervisor.start_bucket(state.buckets)
      ref = Process.monitor(pid)
      refs = HashDict.put(state.refs, ref, name)
      names = HashDict.put(state.names, name, pid)
      GenEvent.sync_notify(state.events, {:create, name, pid})
      {:noreply, %{state | names: names, refs: refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    {name, refs} = HashDict.pop(state.refs, ref)
    names = HashDict.delete(state.names, name)
    # 4. Push a notification to the event manager on exit
    GenEvent.sync_notify(state.events, {:exit, name, pid})
    {:noreply, %{state | names: names, refs: refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
