const std = @import("std");

const uuid = @import("uuid.zig");

const alphabet = "0123456789abcdefghjkmnpqrstvwxyz";

pub fn encode(s: [16]u8) [26]u8 {
    var dst: [26]u8 = undefined;
    // 10 byte timestamp
    dst[0] = alphabet[(s[0] & 224) >> 5];
    dst[1] = alphabet[s[0] & 31];
    dst[2] = alphabet[(s[1] & 248) >> 3];
    dst[3] = alphabet[((s[1] & 7) << 2) | ((s[2] & 192) >> 6)];
    dst[4] = alphabet[(s[2] & 62) >> 1];
    dst[5] = alphabet[((s[2] & 1) << 4) | ((s[3] & 240) >> 4)];
    dst[6] = alphabet[((s[3] & 15) << 1) | ((s[4] & 128) >> 7)];
    dst[7] = alphabet[(s[4] & 124) >> 2];
    dst[8] = alphabet[((s[4] & 3) << 3) | ((s[5] & 224) >> 5)];
    dst[9] = alphabet[s[5] & 31];

    // 16 bytes of entropy
    dst[10] = alphabet[(s[6] & 248) >> 3];
    dst[11] = alphabet[((s[6] & 7) << 2) | ((s[7] & 192) >> 6)];
    dst[12] = alphabet[(s[7] & 62) >> 1];
    dst[13] = alphabet[((s[7] & 1) << 4) | ((s[8] & 240) >> 4)];
    dst[14] = alphabet[((s[8] & 15) << 1) | ((s[9] & 128) >> 7)];
    dst[15] = alphabet[(s[9] & 124) >> 2];
    dst[16] = alphabet[((s[9] & 3) << 3) | ((s[10] & 224) >> 5)];
    dst[17] = alphabet[s[10] & 31];
    dst[18] = alphabet[(s[11] & 248) >> 3];
    dst[19] = alphabet[((s[11] & 7) << 2) | ((s[12] & 192) >> 6)];
    dst[20] = alphabet[(s[12] & 62) >> 1];
    dst[21] = alphabet[((s[12] & 1) << 4) | ((s[13] & 240) >> 4)];
    dst[22] = alphabet[((s[13] & 15) << 1) | ((s[14] & 128) >> 7)];
    dst[23] = alphabet[(s[14] & 124) >> 2];
    dst[24] = alphabet[((s[14] & 3) << 3) | ((s[15] & 224) >> 5)];
    dst[25] = alphabet[s[15] & 31];

    return dst;
}

fn from_str(s: []const u8) ![26]u8 {
    const src: [16]u8 = try uuid.from(s);
    return encode(src);
}

test "encode" {
    try std.testing.expectEqualStrings(
        "7tfjyxwex59k4s4xd4yas5cejn",
        (try from_str("fa7cbdde-3ba5-4cc9-9275-a4f2b2563a55"))[0..],
    );

    try std.testing.expectEqualStrings(
        "01h2e8kqvbfwea724h75qc655w",
        (try from_str("01889c89-df6b-7f1c-a388-91396ec314bc"))[0..],
    );

    try std.testing.expectEqualStrings(
        "00000000000000000000000000",
        (try from_str("00000000-0000-0000-0000-000000000000"))[0..],
    );
    try std.testing.expectEqualStrings(
        "00000000000000000000000001",
        (try from_str("00000000-0000-0000-0000-000000000001"))[0..],
    );
    try std.testing.expectEqualStrings(
        "0000000000000000000000000a",
        (try from_str("00000000-0000-0000-0000-00000000000a"))[0..],
    );
    try std.testing.expectEqualStrings(
        "0000000000000000000000000g",
        (try from_str("00000000-0000-0000-0000-000000000010"))[0..],
    );
    try std.testing.expectEqualStrings(
        "7zzzzzzzzzzzzzzzzzzzzzzzzz",
        (try from_str("ffffffff-ffff-ffff-ffff-ffffffffffff"))[0..],
    );
    try std.testing.expectEqualStrings(
        "7zzzzzzzzzzzzzzzzzzzzzzzzz",
        (try from_str("ffffffff-ffff-ffff-ffff-ffffffffffff"))[0..],
    );
    try std.testing.expectEqualStrings(
        "0123456789abcdefghjkmnpqrs",
        (try from_str("0110c853-1d09-52d8-d73e-1194e95b5f19"))[0..],
    );
    try std.testing.expectEqualStrings(
        "01h455vb4pex5vsknk084sn02q",
        (try from_str("01890a5d-ac96-774b-bcce-b302099a8057"))[0..],
    );
}

// Byte to index table for O(1) lookups when unmarshaling.
// We use 0xFF as sentinel value for invalid indexes.
const dec = [_]u8{
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x01,
    0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0A, 0x0B, 0x0C,
    0x0D, 0x0E, 0x0F, 0x10, 0x11, 0xFF, 0x12, 0x13, 0xFF, 0x14,
    0x15, 0xFF, 0x16, 0x17, 0x18, 0x19, 0x1A, 0xFF, 0x1B, 0x1C,
    0x1D, 0x1E, 0x1F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
};

pub fn decode(s: []const u8) ![]const u8 {
    if (s.len != 26) {
        return error.InvalidLength;
    }

    // Because this is a modified base32 we allow ourselves the luxury of
    // erroring early if needed. The spec states this is an overflow, and that
    // this is the check to do, so we oblige.
    if (s[0] > '7') {
        return error.Overflow;
    }

    // Check if all the characters are part of the expected base32 character set.
    if (dec[s[0]] == 0xFF or
        dec[s[1]] == 0xFF or
        dec[s[2]] == 0xFF or
        dec[s[3]] == 0xFF or
        dec[s[4]] == 0xFF or
        dec[s[5]] == 0xFF or
        dec[s[6]] == 0xFF or
        dec[s[7]] == 0xFF or
        dec[s[8]] == 0xFF or
        dec[s[9]] == 0xFF or
        dec[s[10]] == 0xFF or
        dec[s[11]] == 0xFF or
        dec[s[12]] == 0xFF or
        dec[s[13]] == 0xFF or
        dec[s[14]] == 0xFF or
        dec[s[15]] == 0xFF or
        dec[s[16]] == 0xFF or
        dec[s[17]] == 0xFF or
        dec[s[18]] == 0xFF or
        dec[s[19]] == 0xFF or
        dec[s[20]] == 0xFF or
        dec[s[21]] == 0xFF or
        dec[s[22]] == 0xFF or
        dec[s[23]] == 0xFF or
        dec[s[24]] == 0xFF or
        dec[s[25]] == 0xFF)
    {
        return error.InvalidCharacter;
    }

    var dest: [16]u8 = undefined;

    // 6 bytes timestamp (48 bits)
    dest[0] = (dec[s[0]] << 5) | dec[s[1]];
    dest[1] = (dec[s[2]] << 3) | (dec[s[3]] >> 2);
    dest[2] = (dec[s[3]] << 6) | (dec[s[4]] << 1) | (dec[s[5]] >> 4);
    dest[3] = (dec[s[5]] << 4) | (dec[s[6]] >> 1);
    dest[4] = (dec[s[6]] << 7) | (dec[s[7]] << 2) | (dec[s[8]] >> 3);
    dest[5] = (dec[s[8]] << 5) | dec[s[9]];

    // 10 bytes of entropy (80 bits)
    dest[6] = (dec[s[10]] << 3) | (dec[s[11]] >> 2); // First 4 bits are the version
    dest[7] = (dec[s[11]] << 6) | (dec[s[12]] << 1) | (dec[s[13]] >> 4);
    dest[8] = (dec[s[13]] << 4) | (dec[s[14]] >> 1); // First 2 bits are the variant
    dest[9] = (dec[s[14]] << 7) | (dec[s[15]] << 2) | (dec[s[16]] >> 3);
    dest[10] = (dec[s[16]] << 5) | dec[s[17]];
    dest[11] = (dec[s[18]] << 3) | dec[s[19]] >> 2;
    dest[12] = (dec[s[19]] << 6) | (dec[s[20]] << 1) | (dec[s[21]] >> 4);
    dest[13] = (dec[s[21]] << 4) | (dec[s[22]] >> 1);
    dest[14] = (dec[s[22]] << 7) | (dec[s[23]] << 2) | (dec[s[24]] >> 3);
    dest[15] = (dec[s[24]] << 5) | dec[s[25]];

    return uuid.to(dest);
}

test "decode" {
    try std.testing.expectEqualStrings(
        "01889c89-df6b-7f1c-a388-91396ec314bc",
        try decode("01h2e8kqvbfwea724h75qc655w"),
    );

    try std.testing.expectEqualStrings(
        "fa7cbdde-3ba5-4cc9-9275-a4f2b2563a55",
        try decode("7tfjyxwex59k4s4xd4yas5cejn"),
    );

    try std.testing.expectError(
        error.InvalidLength,
        decode("123456789012345678901234567"),
    );

    try std.testing.expectError(
        error.Overflow,
        decode("8zzzzzzzzzzzzzzzzzzzzzzzzz"),
    );

    try std.testing.expectError(
        error.InvalidLength,
        decode("1234567890123456789012345"),
    );

    try std.testing.expectError(
        error.InvalidCharacter,
        decode("1234567890123456789012345 "),
    );
    try std.testing.expectError(
        error.InvalidCharacter,
        decode("123456789-123456789-123456"),
    );
}
