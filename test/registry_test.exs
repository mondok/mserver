defmodule MServer.RegistryTest do
  use ExUnit.Case, async: true

  defmodule Forwarder do
    use GenEvent

    def handle_event(event, parent) do
      send parent, event
      {:ok, parent}
    end
  end

  setup do
    {:ok, manager} = GenEvent.start_link
    {:ok, registry} = MServer.Registry.start_link(manager)

    GenEvent.add_mon_handler(manager, Forwarder, self())
    {:ok, registry: registry}
  end

  test "sends events on create and crash", %{registry: registry} do
    MServer.Registry.create(registry, "shopping")
    {:ok, bucket} = MServer.Registry.lookup(registry, "shopping")
    assert_receive {:create, "shopping", ^bucket}

    Agent.stop(bucket)
    assert_receive {:exit, "shopping", ^bucket}
  end

  test "removes bucket on crash", %{registry: registry} do
    MServ.Registry.create(registry, "shopping")
    {:ok, bucket} = MServ.Registry.lookup(registry, "shopping")

    # Kill the bucket and wait for the notification
    Process.exit(bucket, :shutdown)
    assert_receive {:exit, "shopping", ^bucket}
    assert MServ.Registry.lookup(registry, "shopping") == :error
  end

  test "spawns buckets", %{registry: registry} do
    assert MServer.Registry.lookup(registry, "shopping") == :error

    MServer.Registry.create(registry, "shopping")
    assert {:ok, bucket} = MServer.Registry.lookup(registry, "shopping")

    MServer.Bucket.put(bucket, "milk", 1)
    assert MServer.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    MServer.Registry.create(registry, "shopping")
    {:ok, bucket} = MServer.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)
    assert MServer.Registry.lookup(registry, "shopping") == :error
  end
end
