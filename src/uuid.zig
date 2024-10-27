const std = @import("std");

inline fn char_to_byte(c: u8) !u8 {
    switch (c) {
        '0'...'9' => return c - '0',
        'a'...'f' => return c - 'a' + 10,
        'A'...'F' => return c - 'A' + 10,
        else => return error.InvalidCharacter,
    }
}

pub inline fn from(uuid: []const u8) ![16]u8 {
    if (uuid.len != 36) {
        return error.InvalidLength;
    }

    var bytes: [16]u8 = undefined;

    var byteIndex: usize = 0;
    var i: usize = 0;
    while (i < uuid.len) {
        if (uuid[i] == '-') {
            i += 1;
            continue;
        }

        if (i + 1 >= uuid.len) {
            return error.InvalidLength;
        }

        const high = try char_to_byte(uuid[i]);
        const low = try char_to_byte(uuid[i + 1]);

        bytes[byteIndex] = (high << 4) | low;
        byteIndex += 1;
        i += 2;
    }

    return bytes;
}

test "uuid" {
    const uuid = "550e8400-e29b-41d4-a716-446655440000";
    const bytes = try from(uuid);
    const expected = [_]u8{ 0x55, 0x0e, 0x84, 0x00, 0xe2, 0x9b, 0x41, 0xd4, 0xa7, 0x16, 0x44, 0x66, 0x55, 0x44, 0x00, 0x00 };
    try std.testing.expectEqual(expected, bytes);
}

const hex_alphabet = "0123456789abcdef";

inline fn byte_to_hex(byte: u8) []const u8 {
    return &[_]u8{
        hex_alphabet[(byte >> 4) & 0xF],
        hex_alphabet[byte & 0xF],
    };
}

pub fn to(bytes: [16]u8) ![]const u8 {
    var uuid: [36]u8 = undefined;

    var dest_idx: usize = 0;
    inline for (0..16) |i| {
        if (dest_idx == 8 or dest_idx == 13 or dest_idx == 18 or dest_idx == 23) {
            uuid[dest_idx] = '-';
            dest_idx += 1;
        }
        const hex = byte_to_hex(bytes[i]);
        uuid[dest_idx] = hex[0];
        uuid[dest_idx + 1] = hex[1];
        dest_idx += 2;
    }

    return uuid[0..];
}

test "to" {
    const test_bytes: [16]u8 = [_]u8{
        0x55,
        0x0e,
        0x84,
        0x00,
        0xe2,
        0x9b,
        0x41,
        0xd4,
        0xa7,
        0x16,
        0x44,
        0x66,
        0x55,
        0x44,
        0x00,
        0x00,
    };

    try std.testing.expectEqualStrings(
        "550e8400-e29b-41d4-a716-446655440000",
        try to(test_bytes),
    );
}
