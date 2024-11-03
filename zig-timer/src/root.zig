const std = @import("std");
const expect = std.testing.expect;

pub const HMS = struct { hours: u8, minutes: u8, seconds: u8 };
pub const TimeError = error{ InvalidHour, InvalidMinutes, InvalidSeconds, TotalSecondsExceeded };

const MAX_ALLOWED_TOTAL_SECONDS = 23 * 3600 + 60 * 60;

// Prints the remaining time after every second
pub fn runTimer(duration: u64) !void {
    const delay_interval = std.time.ns_per_s;
    const stdout = std.io.getStdOut().writer();
    var timer = try std.time.Timer.start();
    const start = timer.read();
    var remaining_seconds: u64 = std.math.maxInt(u64);
    while (remaining_seconds != 0) {
        std.time.sleep(delay_interval);
        const now = timer.read();
        const elapsed = (now - start) / std.time.ns_per_s;
        remaining_seconds = duration - elapsed;
        const hms = try convertSecondsToHMS(remaining_seconds);
        try stdout.print("{}:{}:{}\n", hms);
    }
}

fn convertSecondsToHMS(total_seconds: u64) !HMS {
    try validateSeconds(total_seconds);
    const hours = total_seconds / 3600;
    const minutes = (total_seconds % 3600) / 60;
    const seconds = (total_seconds % 60);

    return .{ .hours = @intCast(hours), .minutes = @intCast(minutes), .seconds = @intCast(seconds) };
}

fn convertHMSToSeconds(hms: HMS) !u64 {
    try validateHMS(hms);
    const hour_seconds = hms.hours * @as(u64, std.time.s_per_hour);
    const min_seconds = hms.minutes * @as(u64, std.time.s_per_min);

    const total_seconds = hour_seconds + min_seconds + hms.seconds;

    if (total_seconds > MAX_ALLOWED_TOTAL_SECONDS) {
        return TimeError.TotalSecondsExceeded;
    } else {
        return total_seconds;
    }
}

pub fn validateSeconds(seconds: u64) !void {
    if (seconds > MAX_ALLOWED_TOTAL_SECONDS)
        return TimeError.TotalSecondsExceeded;
}

pub fn validateHMS(hms: HMS) !void {
    if (hms.hours > 23)
        return TimeError.InvalidHour;
    if (hms.minutes > 60)
        return TimeError.InvalidMinutes;
    if (hms.seconds > 60)
        return TimeError.InvalidSeconds;
}

test "convertSecondsToHMS" {
    // 3661 seconds : 1H:1M:1S
    const converted = try convertSecondsToHMS(3661);
    try expect(converted.hours == 1);
    try expect(converted.hours == 1);
    try expect(converted.seconds == 1);
}

test "convertHMSToSeconds" {
    const hms: HMS = .{
        .hours = 1,
        .minutes = 1,
        .seconds = 1,
    };
    const converted = try convertHMSToSeconds(hms);
    try expect(converted == 3661);
}

test "convertHMSToSeconds_Invalid" {
    const hms: HMS = .{
        .hours = 23,
        .minutes = 60,
        .seconds = 1,
    };
    try std.testing.expectError(TimeError.TotalSecondsExceeded, convertHMSToSeconds(hms));
}
