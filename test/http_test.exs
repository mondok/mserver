defmodule MServer.HTTPTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, server} = MServer.HTTP.start_link
    {:ok, server: server}
  end

  # test "can connect to client", %{server: server} do
  #
  # end
  #
  # test "stores values by key", %{bucket: bucket} do
  #   assert MServer.Bucket.get(bucket, "milk") == nil
  #   MServer.Bucket.put(bucket, "milk", 3)
  #   assert MServer.Bucket.get(bucket, "milk") == 3
  # end
  #
  # test "deletes values by key",  %{bucket: bucket} do
  #   MServer.Bucket.put(bucket, "milk", 3)
  #   assert MServer.Bucket.get(bucket, "milk") == 3
  #   MServer.Bucket.delete(bucket, "milk")
  #   assert MServer.Bucket.get(bucket, "milk") == nil
  # end
end
