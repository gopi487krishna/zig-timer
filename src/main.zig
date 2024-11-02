const std = @import("std");
const expect = std.testing.expect;
const timer = @import("./root.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage : zig-timer-waybar <duration>\n", .{});
        std.process.abort();
    }

    // Second argument represents the amount of time(in seconds)
    const seconds = try std.fmt.parseInt(u64, args[1], 10);
    try timer.validateSeconds(seconds);
    try timer.runTimer(seconds);
}
