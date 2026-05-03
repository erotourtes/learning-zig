//! https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html
const std = @import("std");
const Io = std.Io;
const expect = std.testing.expect;

const http = @import("http.zig");

const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    _ = init; // autofix

    // learning1();
    // try learning2();
    // try learning3();
    // try learnings4(init.io);
    // learnings5();
    // try learnings6(init.io);
    // try learnings7();
    // try learnings8();
    // try learnings9();
    // try learnings10(init.io);
    try learnings_io();
}

///
/// “Focus on debugging your application rather than debugging your programming language knowledge”.
///
fn learning1() void {
    // build.zig.zon is similar to package.json
    // build.zig is a replacement for build systems like Make

    // three types of comments
    // // - ignored by the compiler
    // /// - documentation comment, used to generate API docs
    // //! - documentation comment, used to generate API docs for the current file

    const message = "Hello, world!";
    // message = "reassigning";
    var mutableMessage: []const u8 = "Hello, world!";
    mutableMessage = "zig programming is fun!";
    print("{s} {s}\n", .{ message, mutableMessage });

    // // Not working, must give a type
    // var a = 10;
    // a += 5;
    // print("a = {}\n", .{a});

    // undefined might throw an error if used before assigned
    var a: i32 = undefined;
    a = 10;
    print("a = {}\n", .{a});

    // everything must have a value
    const b: i32 = 0;
    _ = b;
    // b is already discarded
    // print("{}", .{b});

    // Primitives
    // u8, u16, u32, u64, u128
    // i8, i16, i32, i64, i128
    // f16, f32, f64, f128
    // bool
    // C ABI c_long, c_char, etc.
    // isize, usize

    _ = [4]i32{ 1, 2, 3, 4 };
    var arr = [_]i32{ 1, 2, 3, 4 };
    print("arr[0] = {}\n", .{arr[0]});

    const slice = arr[1..3];
    // const slice = arr[1..];
    // const slice = arr[1..arr.len];
    slice[0] = 9999;
    print("arr[0] = {}\narr[1] = {}\n", .{ arr[0], arr[1] });

    // error: index out of bounds
    // arr[arr.len + 3] = 10;

    const neg_arr = [_]i32{ -1, -2, -3, -4 };
    const sum_arr = arr ++ neg_arr;
    print("sum_arr = {any}\n", .{sum_arr});

    const mult_arr = arr ** 2;
    print("mult_arr = {any}\n", .{mult_arr});

    const scoped_variable = named_one: {
        print("inside named scope\n", .{});
        const x: i32 = 10;
        break :named_one x;
    };
    print("after named scope {}\n", .{scoped_variable});

    const str1 = "Hello";
    const str2 = [_]u8{ 0x48, 0x65, 0x6c, 0x6c, 0x6f };
    print("str1 = {s}\nstr2 = {s}\n", .{ str1, str2 });

    // Sentinel-terminated arrays
    // they embed the length of the array in the data itself
    // so `Hello` is represented as
    // `['H', 'e', 'l', 'l', 'o', 0]`, where
    // `0` is the sentinel value
    const str3 = "Hello";
    _ = str3;
    // error: index 6 outside array of length 5 +1 (sentinel)
    // print("{s}\n", .{str3[6]});

    const str4: []const u8 = "Hello, world!";
    // error: must []const u8
    // const str5: []u8 = "Hello, world!";

    const str5 = "Hello, world!";
    if (std.mem.eql(u8, str4, str5)) {
        // equal
        print("str4 and str5 are equal\n", .{});
    } else {
        print("str4 and str5 are not equal\n", .{});
    }
}

fn learning2() !void {
    if (true) {
        print("true\n", .{});
    }

    _ = switch (true) {
        true => "true\n",
        else => @panic("woops"),
    };

    const level = switch (10) {
        0...25 => "low\n",
        26...75 => "medium\n",
        'a'...'z' => "character\n",
        else => @panic("woops"),
    };
    print("level = {s}\n", .{level});

    print("before defer\n", .{});
    {
        print("inside before defer\n", .{});
        // executes when the scope is exited
        defer {
            print("end\n", .{});
        }
        print("inside after defer\n", .{});
    }
    print("after defer\n", .{});

    defer print("defer 1\n", .{});
    defer print("defer 2\n", .{});

    // errdefer print("error happend", .{});
    // return error.MyError;

    const arr = [_]i32{ 10, 20, 30 };
    for (arr, 0..) |item, index| {
        print("arr={}, i={}\n", .{ item, index });
    }

    var i: i32 = 0;
    while (i < 3) : (i += 1) {
        print("i = {}\n", .{i});
    }

    const swap = struct {
        fn call(a: *i32, b: *i32) void {
            const temp = a.*;
            a.* = b.*;
            b.* = temp;
        }
    }.call;
    var x: i32 = 10;
    var y: i32 = 20;
    swap(&x, &y);
    print("x={}, y={}\n", .{ x, y });

    const MyStruct = struct {
        a: i32,
        b: i32,
    };
    var my_struct = MyStruct{ .a = 10, .b = 20 };
    const modify_struct = struct {
        // copied
        // fn call(s: MyStruct) void {
        // ----
        fn call(s: *MyStruct) void {
            s.a += 1;
            s.b += 1;
        }
    }.call;
    modify_struct(&my_struct);
    print("my_struct.a={}, my_struct.b={}\n", .{ my_struct.a, my_struct.b });
    // However, if the input object have a more complex data type,
    // for example, it might be a struct instance, or an array, or an union value, etc.,
    // in cases like that, the zig compiler will take the liberty
    // of deciding for you which strategy is best.
    // Thus, the zig compiler will pass your object to
    // the function either by value, or by reference.
    // The compiler will always choose the strategy that
    // is faster for you.
    // This optimization that you get for free is possible
    // only because function arguments are immutable in Zig.

    const MyStruct2 = struct {
        a: i32,
        b: i32,

        fn init(a: i32, b: i32) @This() {
            return .{ .a = a, .b = b };
        }

        fn mutate(self: *@This()) void {
            self.a += 1;
            self.b += 1;
        }
    };
    const my_struct2 = MyStruct2.init(10, 20);
    print("my_struct2={any}\n", .{my_struct2});
    // Error -> this method mutates the struct
    // my_struct2.mutate();
    var my_struct3 = MyStruct2.init(10, 20);
    my_struct3.mutate();
    print("my_struct3={any}\n", .{my_struct3});

    {
        const a: i32 = 10;
        const b = @as(f32, a);
        print("b = {}\n", .{@TypeOf(b)});
    }
}

fn learning3() !void {
    // const func = struct {
    //     fn call(a: i32, b: i32) *i32 {
    //         const result: i32 = a + b;
    //         return *result;
    //     }
    // }.call;
    // const result = func(10, 20);
    // const result_i32: i32 = *result;
    // print("result = {}\n", .{result_i32});

    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = try allocator.alloc(u8, 10);
    defer allocator.free(input);
    print("allocated_arr={any}\n", .{input});

    @memset(input[0..], 0);
    print("allocated_arr={any}\n", .{input});

    const User = struct {
        name: []const u8,
        age: i32,
    };
    const user = try allocator.create(User);
    defer allocator.destroy(user);
    user.* = User{ .name = "Alice", .age = 30 };
    print("user={any}\n", .{user});
}

fn learnings4(io: Io) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_writer.interface;
    try stdout.print("Hello world\n", .{});
    try stdout.flush();
}

fn learnings5() void {
    var num: i32 = 10;
    const pointer = &num;
    print("num = {}, pointer = {}\n", .{ num, pointer.* });

    const User = struct {
        name: []const u8,
        age: i32,

        fn print(self: *const @This()) void {
            std.debug.print("name = {s}, age = {}\n", .{ self.name, self.age });
        }
    };
    const user = User{ .age = 10, .name = "Alice" };
    user.print();

    const user_ptr = &user;
    user_ptr.print();
    user_ptr.*.print();

    var arr = [_]i32{ 1, 2, 3, 4 };
    // *[4]i32 - pointer to whole array, knows len, no pointer arithmetic
    var arr_ptr = &arr;
    print("arr_ptr.len={}\n", .{arr_ptr.len});
    arr_ptr[0] = 9999;
    // not supported
    // arr_ptr += 1;

    // []i32 - slice: pointer + len
    // [*]i32 - pointer to many i32s, no len, supports pointer arithmetic
    var arr_ptr2: [*]i32 = &arr;
    // not supported
    // print("arr_ptr2.len={}\n", .{arr_ptr2.len});
    arr_ptr2 += 1;
    print("arr_ptr2[0] = {}\n", .{arr_ptr2[0]});

    var num2: ?i32 = 10;
    num2 = null;
    // optional pointer to the optional integer
    const num2_ptr: ?*?i32 = &num2;

    if (num2_ptr) |num2_not_null| {
        print("not null = {}\n", .{num2_not_null});
    }

    const num3 = num2 orelse 20;
    _ = num3; // autofix

    // print("will panic on unwrap {}\n", .{num2.?});
}

fn learnings6(io: std.Io) !void {
    const server = try http.Server.init(io);
    var listener = try server.listen();
    const connection = try listener.accept(io);
    defer connection.close(io);

    var buffer: [1024]u8 = undefined;
    @memset(buffer[0..], 0);
    try http.read_request(io, connection, &buffer);
    print("request = {s}\n", .{buffer});

    try http.send_200(connection, io);
}

test "should sum values" {
    // zig test ./src/main.zig
    const a: u8 = 10;
    const b: u8 = 5;
    try expect(a + b == 15);
}

fn learnings7() !void {
    // https://ziglang.org/documentation/master/#toc-catch
    const MyErrors = error{MyError};
    const func = struct {
        fn call() MyErrors!i32 {
            if (false) {
                return MyErrors.MyError;
            }
            return 42;
        }
        fn call2() error{NewError}!void {}
    }.call;
    _ = try func();
    {
        const res = func() catch |err| blk: {
            print("error = {any}\n", .{err});
            break :blk 42;
        };
        _ = res; // autofix
    }
    {
        const res = func() catch |err| {
            print("error = {any}\n", .{err});
            return err;
        };
        _ = res; // autofix
    }

    const res: MyErrors!i32 = brk: {
        // doesn't not run
        // unless error is **returned** from the block
        // break :brk MyErrors.MyError won't trigger
        errdefer print("error happened\n", .{});

        if (false) {
            return MyErrors.MyError;
        } else {
            break :brk MyErrors.MyError;
        }
    };
    print("res = {any}\n", .{res});
    // try res;

    const Union = union {
        A: i32,
        B: []const u8,
    };

    const union_var = Union{
        .A = 10,
    };
    _ = union_var; // autofix

    // could be used in switch statements
    const TaggedUnion = union(enum) {
        A: i32,
        B: []const u8,
    };
    const tagged_union_var = TaggedUnion{
        .A = 10,
    };
    _ = tagged_union_var; // autofix
}

fn learnings8() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    var array_list = try std.ArrayList(i32).initCapacity(allocator, 10);
    defer array_list.deinit(allocator);
    try array_list.append(allocator, 10);

    var hash_map = std.hash_map.AutoHashMap(i32, i32).init(allocator);
    defer hash_map.deinit();
    try hash_map.put(24, 32);

    var buffer: [1024]u8 = undefined;
    buffer[0] = 150;
    print("buffer = {}", .{buffer[0]});
}

fn learnings9() !void {
    const random_value = comptime brk: {
        break :brk 42;
    };
    print("random_value = {}", .{random_value});
}

fn learnings10(io: std.Io) !void {
    _ = io; // autofix
    const function = struct {
        fn call(value: i32) void {
            print("calling function with {}\n", .{value});
        }
    }.call;
    const thread = try std.Thread.spawn(.{}, function, .{42});
    thread.join();
    print("end", .{});
}

fn learnings_io() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    defer std.debug.assert(debug_allocator.deinit() == .ok);
    const allocator = debug_allocator.allocator();

    var threaded_io: std.Io.Threaded = .init(allocator, .{});
    defer threaded_io.deinit();

    const function = struct {
        fn call(value: i32) i32 {
            print("calling function with {}\n", .{value});
            return value;
        }
    }.call;
    const io = threaded_io.io();
    var job1 = try std.Io.concurrent(io, function, .{42});
    const result1 = job1.await(io);
    print("result = {}\n", .{result1});

    const allocated = try allocator.alloc(u8, 10);
    defer allocator.free(allocated);
    // allocator.free(allocated);

    var res1 = std.Io.async(io, function, .{42});
    var res2 = std.Io.async(io, function, .{42});

    _ = res2.await(io);
    try io.sleep(.fromSeconds(2), .awake);
    print("end", .{});
    try io.sleep(.fromSeconds(2), .awake);
    _ = res1.await(io);
}
