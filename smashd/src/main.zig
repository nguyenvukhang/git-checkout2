const std = @import("std");

pub fn main() !void {
    var fbuffer: [0x1000]u8 = undefined;
    var readbuf: [0x800]u8 = undefined;
    var fba: std.heap.FixedBufferAllocator = .init(&fbuffer);
    const alloc = fba.allocator();
    // const args: [2][]const u8 = [_][]u8{ "git", "worktree" };
    // const args: [2][]const u8 = .{ "git", "worktree", "list" };
    var git_worktree = std.process.Child.init(&.{ "git", "worktree", "list" }, alloc);
    git_worktree.stdout_behavior = .Pipe;
    try git_worktree.spawn();
    {
        var reader_ = git_worktree.stdout.?.reader(&readbuf);
        var reader = &reader_.interface;
        loop: while (true) {
            const line = reader.takeDelimiterInclusive('\n') catch |e| switch (e) {
                error.EndOfStream => break :loop,
                else => return e,
            };
            std.debug.print("{s}", .{line});
        }
    }
    _ = try git_worktree.wait();

    // Prints to stderr, ignoring potential errors.
    // std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}
