//usr/bin/env zig run "$0" -- "$@"; exit

const std = @import("std");

const MAX_CODE_POINT = 0x10FFFF;

const KnownFile = enum {
    @"DerivedName.txt",
    @"DerivedGeneralCategory.txt",
    @"DerivedCombiningClass.txt",
    @"DerivedBidiClass.txt",
    @"DerivedDecompositionType.txt",
    @"UnicodeData.txt",

    fn SortByCodePoint(comptime T: type) type {
        return struct {
            fn lessThan(_: void, a: T, b: T) bool {
                return a.code_point < b.code_point;
            }
        };
    }

    fn Parser(comptime self: KnownFile) type {
        return switch (self) {
            .@"DerivedName.txt" => struct {
                const Iterator = NonUnicodeDataTxtFileIterator;

                const Property = struct {
                    code_point: u21,
                    Name: ?[]const u8,
                };

                fn parse(arena: *std.heap.ArenaAllocator, line: Line) anyerror!Property {
                    return switch (line.kind) {
                        .single => Property{
                            .code_point = line.code_point,
                            .Name = try arena.allocator().dupe(u8, try extractField(1, line.line)),
                        },
                        .range => Property{
                            .code_point = line.code_point,
                            .Name = try std.mem.replaceOwned(u8, arena.allocator(), try extractField(1, line.line), "*", try std.fmt.allocPrint(arena.allocator(), "{X:04}", .{line.code_point})),
                        },
                    };
                }

                fn filler(_: *std.heap.ArenaAllocator, code_point: u21) !Property {
                    return Property{
                        .code_point = code_point,
                        .Name = null,
                    };
                }
            },
            .@"DerivedGeneralCategory.txt" => struct {
                const Iterator = NonUnicodeDataTxtFileIterator;

                const PropertyValue = enum {
                    Lu,
                    Ll,
                    Lt,
                    Lm,
                    Lo,
                    Mn,
                    Mc,
                    Me,
                    Nd,
                    Nl,
                    No,
                    Pc,
                    Pd,
                    Ps,
                    Pe,
                    Pi,
                    Pf,
                    Po,
                    Sm,
                    Sc,
                    Sk,
                    So,
                    Zs,
                    Zl,
                    Zp,
                    Cc,
                    Cf,
                    Cs,
                    Co,
                    Cn,
                };

                const Property = struct {
                    code_point: u21,
                    General_Category: PropertyValue,
                };

                fn parse(_: *std.heap.ArenaAllocator, line: Line) anyerror!Property {
                    const value = std.meta.stringToEnum(PropertyValue, try extractField(1, line.line)) orelse return error.InvalidPropertyValue;
                    return Property{
                        .code_point = line.code_point,
                        .General_Category = value,
                    };
                }

                fn filler(_: *std.heap.ArenaAllocator, _: u21) !Property {
                    unreachable;
                }
            },
            .@"DerivedCombiningClass.txt" => struct {
                const Iterator = NonUnicodeDataTxtFileIterator;

                const PropertyValue = blk: {
                    const len = std.math.maxInt(u8);
                    var field_names: [len][]const u8 = undefined;
                    var field_values: [len]u8 = undefined;
                    for (0..len) |idx| {
                        @setEvalBranchQuota(50000);
                        field_names[idx] = switch (idx) {
                            0 => "Not_Reordered",
                            1 => "Overlay",
                            6 => "Han_Reading",
                            7 => "Nukta",
                            8 => "Kana_Voicing",
                            9 => "Virama",
                            200 => "Attached_Below_Left",
                            202 => "Attached_Below",
                            214 => "Attached_Above",
                            216 => "Attached_Above_Right",
                            218 => "Below_Left",
                            220 => "Below",
                            222 => "Below_Right",
                            224 => "Left",
                            226 => "Right",
                            228 => "Above_Left",
                            230 => "Above",
                            232 => "Above_Right",
                            233 => "Double_Below",
                            234 => "Double_Above",
                            240 => "Iota_Subscript",
                            else => std.fmt.comptimePrint("Ccc{d}", .{idx}),
                        };
                        field_values[idx] = idx;
                    }
                    break :blk @Enum(u8, std.builtin.Type.Enum.Mode.exhaustive, &field_names, &field_values);
                };

                const Property = struct {
                    code_point: u21,
                    Canonical_Combining_Class: u8,
                };

                fn parse(_: *std.heap.ArenaAllocator, line: Line) anyerror!Property {
                    const field1 = try extractField(1, line.line);
                    const value = try std.fmt.parseInt(u8, field1, 10);
                    _ = std.enums.fromInt(PropertyValue, value) orelse return error.InvalidCombiningClassValue;
                    return Property{
                        .code_point = line.code_point,
                        .Canonical_Combining_Class = value,
                    };
                }

                fn filler(_: *std.heap.ArenaAllocator, code_point: u21) !Property {
                    return Property{
                        .code_point = code_point,
                        .Canonical_Combining_Class = 0,
                    };
                }
            },
            .@"DerivedBidiClass.txt" => struct {
                const Iterator = NonUnicodeDataTxtFileIterator;

                const PropertyValue = enum {
                    L,
                    R,
                    AL,
                    EN,
                    ES,
                    ET,
                    AN,
                    CS,
                    NSM,
                    BN,
                    B,
                    S,
                    WS,
                    ON,
                    LRE,
                    LRO,
                    RLE,
                    RLO,
                    PDF,
                    LRI,
                    RLI,
                    FSI,
                    PDI,
                };
                const Property = struct {
                    code_point: u21,
                    Bidi_Class: PropertyValue,
                };

                fn parse(_: *std.heap.ArenaAllocator, line: Line) anyerror!Property {
                    const value = std.meta.stringToEnum(PropertyValue, try extractField(1, line.line)) orelse return error.InvalidBidiClassValue;
                    return Property{
                        .code_point = line.code_point,
                        .Bidi_Class = value,
                    };
                }

                fn filler(_: *std.heap.ArenaAllocator, code_point: u21) !Property {
                    const ranges = [_]struct { u21, u21, PropertyValue }{
                        .{ 0x0590, 0x05FF, .R },
                        .{ 0x0600, 0x07BF, .AL },
                        .{ 0x07C0, 0x085F, .R },
                        .{ 0x0860, 0x08FF, .AL },
                        .{ 0x20A0, 0x20CF, .ET },
                        .{ 0xFB1D, 0xFB4F, .R },
                        .{ 0xFB50, 0xFDCD, .AL },
                        .{ 0xFDF0, 0xFDFF, .AL },
                        .{ 0xFE70, 0xFEFF, .AL },
                        .{ 0x10800, 0x10CFF, .R },
                        .{ 0x10D00, 0x10D3F, .AL },
                        .{ 0x10D40, 0x10EBF, .R },
                        .{ 0x10EC0, 0x10EFF, .AL },
                        .{ 0x10F00, 0x10F2F, .R },
                        .{ 0x10F30, 0x10F6F, .AL },
                        .{ 0x10F70, 0x10FFF, .R },
                        .{ 0x1E800, 0x1EC6F, .R },
                        .{ 0x1EC70, 0x1ECBF, .AL },
                        .{ 0x1ECC0, 0x1ECFF, .R },
                        .{ 0x1ED00, 0x1ED4F, .AL },
                        .{ 0x1ED50, 0x1EDFF, .R },
                        .{ 0x1EE00, 0x1EEFF, .AL },
                        .{ 0x1EF00, 0x1EFFF, .R },
                        .{ 0x0000, 0x10FFFF, .L },
                    };
                    inline for (ranges) |range| {
                        if (code_point >= range.@"0" and code_point <= range.@"1") {
                            return Property{
                                .code_point = code_point,
                                .Bidi_Class = range.@"2",
                            };
                        }
                    }
                    unreachable;
                }
            },

            .@"DerivedDecompositionType.txt" => struct {
                const Iterator = NonUnicodeDataTxtFileIterator;

                const PropertyValue = enum {
                    None,
                    Canonical,
                    Compat,
                    Circle,
                    Final,
                    Font,
                    Fraction,
                    Initial,
                    Isolated,
                    Medial,
                    Narrow,
                    Nobreak,
                    Small,
                    Square,
                    Sub,
                    Super,
                    Vertical,
                    Wide,
                };

                const Property = struct {
                    code_point: u21,
                    Decomposition_Type: PropertyValue,
                };

                fn parse(_: *std.heap.ArenaAllocator, line: Line) anyerror!Property {
                    const value = std.meta.stringToEnum(PropertyValue, try extractField(1, line.line)) orelse return error.InvalidDecompositionTypeValue;
                    return Property{
                        .code_point = line.code_point,
                        .Decomposition_Type = value,
                    };
                }

                fn filler(_: *std.heap.ArenaAllocator, code_point: u21) !Property {
                    return Property{
                        .code_point = code_point,
                        .Decomposition_Type = .None,
                    };
                }
            },

            .@"UnicodeData.txt" => struct {
                const Iterator = UnicodeDataTxtFileIterator;

                const Property = struct {
                    code_point: u21,
                    Decomposition_Mapping: []const u21,
                };

                fn parse(arena: *std.heap.ArenaAllocator, line: Line) anyerror!Property {
                    var codePoints = std.ArrayList(u21).empty;

                    const field = try extractField(5, line.line);
                    if (field.len == 0) {
                        try codePoints.append(arena.allocator(), line.code_point);
                    } else {
                        var split = std.mem.splitScalar(u8, field, ' ');
                        while (split.next()) |part| {
                            // Skip the tag.
                            if (std.mem.startsWith(u8, part, "<") and std.mem.endsWith(u8, part, ">")) {
                                continue;
                            }

                            const code_point = try std.fmt.parseInt(u21, part, 16);
                            try codePoints.append(arena.allocator(), code_point);
                        }
                    }

                    const codePointsSlice = try codePoints.toOwnedSlice(arena.allocator());
                    std.debug.assert(codePointsSlice.len > 0);

                    return Property{
                        .code_point = line.code_point,
                        .Decomposition_Mapping = codePointsSlice,
                    };
                }

                fn filler(arena: *std.heap.ArenaAllocator, code_point: u21) !Property {
                    const codePointsSlice = try arena.allocator().dupe(u21, &[_]u21{code_point});
                    std.debug.assert(codePointsSlice.len > 0);
                    return Property{
                        .code_point = code_point,
                        .Decomposition_Mapping = codePointsSlice,
                    };
                }
            },
        };
    }

    fn fillMissing(
        comptime self: KnownFile,
        arena: *std.heap.ArenaAllocator,
        properties: []const KnownFile.Parser(self).Property,
    ) error{OutOfMemory}![]KnownFile.Parser(self).Property {
        const parser = self.Parser();
        var idx: usize = 0;
        var code_point: u21 = 0;
        var out = try std.ArrayList(parser.Property).initCapacity(arena.allocator(), MAX_CODE_POINT + 1);

        while (code_point <= MAX_CODE_POINT and idx < properties.len) : (code_point += 1) {
            if (code_point < properties[idx].code_point) {
                const t = try parser.filler(arena, code_point);
                try out.append(arena.allocator(), t);
            } else {
                try out.append(arena.allocator(), properties[idx]);
                idx += 1;
            }
        }

        while (code_point <= MAX_CODE_POINT) : (code_point += 1) {
            const t = try parser.filler(arena, code_point);
            try out.append(arena.allocator(), t);
        }

        return try out.toOwnedSlice(arena.allocator());
    }

    fn processFile(
        comptime self: KnownFile,
        arena: *std.heap.ArenaAllocator,
        reader_interface: *std.Io.Reader,
        stdout_interface: *std.Io.Writer,
    ) !void {
        const parser = self.Parser();

        var arrayListProperties = std.ArrayList(parser.Property).empty;

        var iterator = parser.Iterator{ .reader_interface = reader_interface };

        while (try iterator.next()) |line| try arrayListProperties.append(arena.allocator(), try parser.parse(arena, line));

        const listedProperties = try arrayListProperties.toOwnedSlice(arena.allocator());
        std.sort.block(parser.Property, listedProperties, {}, SortByCodePoint(parser.Property).lessThan);

        const properties = try self.fillMissing(arena, listedProperties);

        for (properties) |property| {
            stdout_interface.print("{f}\n", .{std.json.fmt(property, .{})}) catch |err| switch (err) {
                error.WriteFailed => break,
            };
        }
    }
};

const Field0 = union(enum) {
    single: u21,
    range: struct { u21, u21 },
};

const Line = struct {
    code_point: u21,
    line: []const u8,
    kind: enum {
        single,
        range,
    },
};

fn trimComment(line_with_comment: []const u8) []const u8 {
    const line = if (std.mem.findScalar(u8, line_with_comment, '#')) |comment_index| line_with_comment[0..comment_index] else line_with_comment;
    return line;
}

fn extractField0(line_with_comment: []const u8) !?Field0 {
    const line = trimComment(line_with_comment);
    if (line.len == 0) {
        return null;
    }
    if (std.mem.findScalar(u8, line, ';')) |semicolon_index| {
        const field0 = std.mem.trim(u8, line[0..semicolon_index], " ");
        if (std.mem.find(u8, field0, "..")) |range_index| {
            const start_code_point = try std.fmt.parseInt(u21, field0[0..range_index], 16);
            const end_code_point = try std.fmt.parseInt(u21, field0[range_index + 2 ..], 16);
            return .{ .range = .{ start_code_point, end_code_point } };
        } else {
            const code_point = try std.fmt.parseInt(u21, field0, 16);
            return .{ .single = code_point };
        }
    } else {
        return error.InvalidLine;
    }
}

fn extractField(field: comptime_int, line_with_comment: []const u8) ![]const u8 {
    const line = trimComment(line_with_comment);
    var split = std.mem.splitScalar(u8, line, ';');
    var idx: usize = 0;
    while (split.next()) |part| : (idx += 1) {
        if (idx == field) {
            const value = std.mem.trim(u8, part, " ");
            return value;
        }
    }
    return error.FieldNotFound;
}

const UnicodeDataTxtFileIterator = struct {
    reader_interface: *std.Io.Reader,
    state: State = .init,
    const State = union(enum) {
        init: void,
        range_first: struct {
            first_code_point: u21,
            first_line: []const u8,
        },
        range: struct {
            last_code_point: u21,
            loop_code_point: u21,
            first_line: []const u8,
            last_line: []const u8,
        },
    };

    fn next(self: *@This()) !?Line {
        state_machine: while (true) {
            switch (self.state) {
                .init => {
                    if (try self.reader_interface.takeDelimiter('\n')) |line_with_comment| {
                        if (try extractField0(line_with_comment)) |field0| {
                            switch (field0) {
                                .single => |code_point| {
                                    const field1 = try extractField(1, line_with_comment);
                                    if (std.mem.startsWith(u8, field1, "<") and std.mem.endsWith(u8, field1, ", First>")) {
                                        self.state = .{ .range_first = .{ .first_code_point = code_point, .first_line = line_with_comment } };
                                        continue :state_machine;
                                    }

                                    return Line{ .code_point = code_point, .line = line_with_comment, .kind = .single };
                                },
                                // The range notation `X..Y` should never appear in `UnicodeData.txt`.
                                .range => unreachable,
                            }
                        } else {
                            continue :state_machine;
                        }
                    } else {
                        return null;
                    }
                },
                .range_first => |range_first| {
                    if (try self.reader_interface.takeDelimiter('\n')) |line_with_comment| {
                        if (try extractField0(line_with_comment)) |field0| {
                            switch (field0) {
                                .single => |code_point| {
                                    const field1 = try extractField(1, line_with_comment);
                                    if (std.mem.startsWith(u8, field1, "<") and std.mem.endsWith(u8, field1, ", Last>")) {
                                        self.state = .{ .range = .{
                                            .last_code_point = code_point,
                                            .loop_code_point = range_first.first_code_point,
                                            .first_line = range_first.first_line,
                                            .last_line = line_with_comment,
                                        } };
                                        continue :state_machine;
                                    }

                                    return error.ExpectedRangeSecondLine;
                                },
                                // The range notation `X..Y` should never appear in `UnicodeData.txt`.
                                .range => unreachable,
                            }
                        } else {
                            // This should not happen as `UnicodeData.txt` does not contain empty lines.
                            continue :state_machine;
                        }
                    } else {
                        return error.ExpectedRangeSecondLine;
                    }
                },
                .range => |range| {
                    if (range.loop_code_point <= range.last_code_point) {
                        var new_range = range;
                        new_range.loop_code_point += 1;
                        self.state = .{ .range = new_range };
                        return Line{
                            .code_point = range.loop_code_point,
                            // Either first_line or last_line is fine.
                            .line = range.first_line,
                            .kind = .range,
                        };
                    } else {
                        self.state = .init;
                        continue :state_machine;
                    }
                },
            }
        }
    }
};

// Iterate files that use the `X..Y` notation to indicate ranges.
const NonUnicodeDataTxtFileIterator = struct {
    reader_interface: *std.Io.Reader,
    state: State = .init,
    const State = union(enum) {
        init: void,
        range: struct {
            last_code_point: u21,
            loop_code_point: u21,
            line: []const u8,
        },
    };

    fn next(self: *@This()) !?Line {
        state_machine: while (true) {
            switch (self.state) {
                .init => {
                    if (try self.reader_interface.takeDelimiter('\n')) |line_with_comment| {
                        if (try extractField0(line_with_comment)) |field0| {
                            switch (field0) {
                                .single => |code_point| {
                                    return Line{
                                        .code_point = code_point,
                                        .line = line_with_comment,
                                        .kind = .single,
                                    };
                                },
                                .range => |range| {
                                    self.state = .{ .range = .{
                                        .last_code_point = range.@"1",
                                        .loop_code_point = range.@"0",
                                        .line = line_with_comment,
                                    } };
                                    continue :state_machine;
                                },
                            }
                        } else {
                            continue :state_machine;
                        }
                    } else {
                        return null;
                    }
                },
                .range => |range| {
                    if (range.loop_code_point <= range.last_code_point) {
                        var new_range = range;
                        new_range.loop_code_point += 1;
                        self.state = .{ .range = new_range };
                        return Line{
                            .code_point = range.loop_code_point,
                            .line = range.line,
                            .kind = .range,
                        };
                    } else {
                        self.state = .init;
                        continue :state_machine;
                    }
                },
            }
        }
    }
};

pub fn main(init: std.process.Init) !void {
    var buffer: [1024]u8 = @splat(0);
    var stdout = std.Io.File.stdout();
    var stdout_writer = stdout.writer(init.io, &buffer);
    var stdout_interface = &stdout_writer.interface;

    const args = try init.minimal.args.toSlice(init.arena.allocator());

    const absolutePath = args[1];
    const basename = std.fs.path.basename(absolutePath);
    const known_file = std.meta.stringToEnum(KnownFile, basename) orelse return error.Unknownfile;

    const file = try std.Io.Dir.openFileAbsolute(init.io, absolutePath, .{});
    defer file.close(init.io);
    var reader_buffer: [1024]u8 = @splat(0);
    var reader = std.Io.File.reader(file, init.io, &reader_buffer);
    const reader_interface = &reader.interface;

    switch (known_file) {
        inline else => |comptime_known_file| try comptime_known_file.processFile(init.arena, reader_interface, stdout_interface),
    }

    stdout_interface.flush() catch |err| switch (err) {
        error.WriteFailed => {},
    };
}
