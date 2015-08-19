defmodule MServer.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = MServer.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert MServer.Bucket.get(bucket, "milk") == nil
    MServer.Bucket.put(bucket, "milk", 3)
    assert MServer.Bucket.get(bucket, "milk") == 3
  end

  test "deletes values by key",  %{bucket: bucket} do
    MServer.Bucket.put(bucket, "milk", 3)
    assert MServer.Bucket.get(bucket, "milk") == 3
    MServer.Bucket.delete(bucket, "milk")
    assert MServer.Bucket.get(bucket, "milk") == nil
  end
end
