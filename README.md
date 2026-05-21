# TypeID implementation for Zig

## Usage

```zig
const typeid = @import("zig-typeid");
```

### From a UUID string

Convert a type prefix and a UUID string into a TypeID:

```zig
const id = try typeid.from_string(allocator, "user", "1ae8e766-62b0-5c91-9d34-58eb0f67f353");
// => "user_0tx3kpcrngbj8std2rxc7pfwtk"
```

### From UUID bytes

Convert a type prefix and raw UUID bytes into a TypeID:

```zig
const id = typeid.from(allocator, "user", uuid_bytes) catch @panic("oom");
// => "user_0tx3kpcrngbj8std2rxc7pfwtk"
```

### Deterministic IDs with UUID v5

Generate a deterministic TypeID using UUID v5

```zig
const uuid = typeid.uuid5("some-stable-input");
// => { 0x1a, 0xe8, 0xe7, 0x66, 0x62, 0xb0, 0x5c, 0x91, 0x9d, 0x34, 0x58, 0xeb, 0x0f, 0x67, 0xf3, 0x53 }
const id = try typeid.from(allocator, "user", uuid);
// => "user_0tx3kpcrngbj8std2rxc7pfwtk"
```

### Extract the UUID from a TypeID

Convert a TypeID to its UUID string:

```zig
const uuid = try typeid.to_uuid("user_0tx3kpcrngbj8std2rxc7pfwtk");
// => "1ae8e766-62b0-5c91-9d34-58eb0f67f353"
```

Also works without a prefix:

```zig
const uuid = try typeid.to_uuid("0tx3kpcrngbj8std2rxc7pfwtk");
// => "1ae8e766-62b0-5c91-9d34-58eb0f67f353"
```
