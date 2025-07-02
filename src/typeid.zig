const std = @import("std");
const Sha1 = std.crypto.hash.Sha1;

const base32 = @import("base32.zig");
const UUID = @import("uuid.zig");

/// Generate a UUID v5 over `v` from the NULL namespace
pub fn uuid5(v: []const u8) [16]u8 {
    var hasher = Sha1.init(.{});
    hasher.update(&.{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 });
    hasher.update(v);
    var uuid: [16]u8 = undefined;
    @memcpy(&uuid, hasher.finalResult()[0..16]);
    uuid[6] = uuid[6] & 0x0f | 0x50; // version = 5
    uuid[8] = uuid[8] & 0b10111111 | 0b10000000; // variant = 0b10
    return uuid;
}

test uuid5 {
    const python3_uuid5_reference: [16]u8 = .{ 0x56, 0x33, 0xa3, 0xf9, 0x46, 0xf7, 0x50, 0xf5, 0xba, 0x09, 0x76, 0x2e, 0x3f, 0xd9, 0x0b, 0x52 };
    try std.testing.expectEqualSlices(u8, &python3_uuid5_reference, &uuid5("hey"));
}

const max_prefix_len = 63;
const max_suffix_len = 36;

const typeid_suffix_len = 26;

/// Convert a `prefix` and `uuid_str` to a `typeID`
///
/// Expects `uuid_str` to be a string representation of a uuid, such as
///     2afaa681-161e-41be-8891-262cbc032fa4
///
/// Even though the typeID spec specifies UUID v7, this library makes no such
/// assumption. Thus, this library takes a relaxed approach to the
/// specification, to accomodate other types of UUID, such as the deterministic
/// UUID v5.
pub fn from_string(comptime prefix: []const u8, uuid_str: []const u8) ![prefix.len + typeid_suffix_len + 1]u8 {
    return try from(
        prefix,
        try UUID.from(uuid_str),
    );
}

test from_string {
    try std.testing.expectEqualStrings(
        "foo_01h2e8kqvbfwea724h75qc655w",
        &(try from_string("foo", "01889c89-df6b-7f1c-a388-91396ec314bc")),
    );

    try std.testing.expectEqualStrings(
        "foo_7tfjyxwex59k4s4xd4yas5cejn",
        &(try from_string("foo", "fa7cbdde-3ba5-4cc9-9275-a4f2b2563a55")),
    );

    try std.testing.expectEqualStrings(
        "bar_01h2e8kqvbfwea724h75qc655w",
        &(try from_string("bar", "01889c89-df6b-7f1c-a388-91396ec314bc")),
    );
}

/// Convert a `prefix` and a `uuid` to a `typeID`
///
/// Even though the typeID spec specifies UUID v7, this library makes no such
/// assumption. Thus, this library takes a relaxed approach to the
/// specification, to accomodate other types of UUID, such as the deterministic
/// UUID v5.
pub fn from(comptime prefix: []const u8, uuid: [16]u8) ![prefix.len + typeid_suffix_len + 1]u8 {
    if (prefix.len > max_prefix_len) {
        @compileError("Invalid length for prefix");
    }

    if (prefix[0] == '_') {
        @compileError("Prefix cannot start with '_'");
    }

    if (prefix[prefix.len - 1] == '_') {
        @compileError("Prefix cannot end with '_'");
    }

    var buf: [prefix.len + typeid_suffix_len + 1]u8 = undefined;
    @memcpy(&buf, prefix ++ "_" ++ try base32.encode(uuid));

    return buf;
}

test from {
    var foo: [30]u8 = undefined;

    // Add scoping to validate lifetime
    {
        foo = try from("foo", try UUID.from("01889c89-df6b-7f1c-a388-91396ec314bc"));
        try std.testing.expectEqualStrings(
            "foo_01h2e8kqvbfwea724h75qc655w",
            &foo,
        );

        try std.testing.expectEqualStrings(
            "bar_01h2e8kqvbfwea724h75qc655w",
            &(try from("bar", try UUID.from("01889c89-df6b-7f1c-a388-91396ec314bc"))),
        );
    }

    try std.testing.expectEqualStrings(
        "foo_01h2e8kqvbfwea724h75qc655w",
        &foo,
    );
}
