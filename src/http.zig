const std = @import("std");
const Socket = std.Io.net.Socket;
const Io = std.Io;
const Protocol = std.Io.net.Protocol;

pub const Server = struct {
    addr: Io.net.IpAddress,
    io: Io,

    pub fn init(io: Io) !Server {
        const host = "127.0.0.1";
        const port = 8080;
        const addr = try Io.net.IpAddress.parseIp4(host, port);
        return .{
            .addr = addr,
            .io = io,
        };
    }

    pub fn listen(self: *const @This()) !Io.net.Server {
        return try self.addr.listen(self.io, .{
            .mode = Socket.Mode.stream,
            .protocol = Protocol.tcp,
        });
    }
};

pub fn read_request(io: Io, connection: Io.net.Stream, buffer: []u8) !void {
    var read_buffer: [1024]u8 = undefined;
    var reader = connection.reader(io, &read_buffer);
    const reader_interface = &reader.interface;

    var start_index: usize = 0;
    for (0..5) |_| {
        const len = try read_next_line(reader_interface, buffer, start_index);
        start_index += len;
    }
}

fn read_next_line(reader: *std.Io.Reader, buffer: []u8, start_index: usize) !usize {
    const next_line = try reader.takeDelimiterInclusive('\n');
    @memcpy(
        buffer[start_index..(start_index + next_line.len)],
        next_line[0..],
    );
    return next_line.len;
}

pub fn send_200(conn: std.Io.net.Stream, io: std.Io) !void {
    const message = ("HTTP/1.1 200 OK\nContent-Length: 48" ++ "\nContent-Type: text/html\n" ++ "Connection: Closed\n\n<html><body>" ++ "<h1>Hello, World!</h1></body></html>");
    var stream_writer = conn.writer(io, &.{});
    _ = try stream_writer.interface.write(message);
}
