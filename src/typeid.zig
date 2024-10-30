const std = @import("std");
const base32 = @import("base32.zig");

pub fn typeid(comptime prefix: []const u8, suffix: []const u8, buf: *[99]u8) !usize {
    if (prefix.len > 63) {
        @compileError("Invalid length for prefix");
    }
    if (suffix.len > 36) {
        return error.InvalidLengthSuffix;
    }
    if (prefix[0] == '_') {
        return error.InvalidCharacter;
    }

    if (prefix[prefix.len-1] == '_') {
        return error.InvalidCharacter;
    }

    const encoded_suffix = (try base32.encode(suffix))[0..];

    var len: usize = 0;
    for (prefix ++ "_" ++ encoded_suffix, 0..) |c, i| {
        buf[i] = c;
        len = i;
    }
    len += 1;
    return len;
}

const max_prefix_length = 63;
const max_suffix_length = 26;
const max_typeid_length = max_prefix_length + max_suffix_length;

pub const Parts = struct {
    prefix: []const u8,
    suffix: []const u8,
};

pub fn parts(id: []const u8) !Parts {
    if (id.len > max_typeid_length) {
        return error.InvalidLength;
    }

    var pos: usize = 0;
    for (id, 0..) |c, i| {
        if (c == '_') {
            pos = i;
        }
    }
    if (pos > 63) {
        @panic("Found '_' in suffix");
    }

    return Parts{
        .prefix = if (pos == 0) "" else id[0..pos],
        .suffix = try base32.decode(id[pos + 1 ..]),
    };
}

test "typeid encoding/decoding" {
    var buf: [99]u8 = undefined;
    var len = try typeid("foo", "01889c89-df6b-7f1c-a388-91396ec314bc", &buf);
    try std.testing.expectEqualStrings(
        "foo_01h2e8kqvbfwea724h75qc655w",
        buf[0..len],
    );
    len = try typeid("foo", "fa7cbdde-3ba5-4cc9-9275-a4f2b2563a55", &buf);
    try std.testing.expectEqualStrings(
        "foo_7tfjyxwex59k4s4xd4yas5cejn",
        buf[0..len],
    );
    len = try typeid("bar", "01889c89-df6b-7f1c-a388-91396ec314bc", &buf);
    try std.testing.expectEqualStrings(
        "bar_01h2e8kqvbfwea724h75qc655w",
        buf[0..len],
    );
    try std.testing.expectError(
        error.InvalidLength,
        typeid("foo", "01889c89-df6b-7f1c-a388-1396ec314bc", &buf),
    );
    try std.testing.expectError(
        error.InvalidCharacter,
        typeid("_foo", "01889c89-df6b-7f1c-a388-1396ec314bc", &buf),
    );
    try std.testing.expectError(
        error.InvalidCharacter,
        typeid("foo_", "01889c89-df6b-7f1c-a388-91396ec314bc", &buf),
    );

    const p = try parts("foo_bar_baz_01h2e8kqvbfwea724h75qc655w");

    try std.testing.expectEqualStrings(
        "foo_bar_baz",
        p.prefix,
    );

    try std.testing.expectEqualStrings(
        "01889c89-df6b-7f1c-a388-91396ec314bc",
        p.suffix,
    );
}
