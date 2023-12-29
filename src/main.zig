const std = @import("std");

const r = @cImport({
    @cInclude("raylib.h");
});

const Rect = struct {
    position: @Vector(2, f32),
    size: @Vector(2, f32),
};

const UI_OBJECTS_SIZE = 256 * 1024;

const UI_FLAGS = enum {};

const UI = struct {
    const Object = struct {
        id: []const u8,
        position: @Vector(2, f32),
        size: @Vector(2, f32) = .{ 100, 100 },
    };

    objects_stack: struct {
        idx: u32,
        items: [UI_OBJECTS_SIZE]Object,
    },

    hot_object: ?*Object,

    mouse: struct {
        position: @Vector(2, f32),
    },

    frame: u32,

    pub fn init() void {}

    pub fn deInit() void {}

    pub fn beginFrame(self: *@This()) void {
        if (self.objects_stack.idx >= UI_OBJECTS_SIZE) {
            self.objects_stack.idx = 0;
        }
    }

    pub fn endFrame(self: *@This()) void {
        self.objects_stack.idx = 0;
    }

    pub fn getPositionTestObject(self: *@This()) @Vector(2, f32) {
        return self.objects_stack.items[self.objects_stack.idx].position;
    }

    pub fn setPositionTestObject(self: *@This(), position: @Vector(2, f32)) void {
        self.objects_stack.items[self.objects_stack.idx].position = position;
    }

    pub fn getSizeTestObject(self: *@This()) @Vector(2, f32) {
        return self.objects_stack.items[self.objects_stack.idx].size;
    }

    pub fn setSizeTestObject(self: *@This(), size: @Vector(2, f32)) void {
        self.objects_stack.items[self.objects_stack.idx].size = size;
    }

    pub fn drawTestObject(self: *@This(), id: []const u8) void {
        // var buf: [1024]u8 = undefined;
        // const newID = std.fmt.bufPrintZ(&buf, "{d}:{s}\n", .{ self.object_idx, id }) catch @panic("error");
        // std.debug.print("{s}", .{newID});

        self.objects_stack.items[self.objects_stack.idx].id = id;
        self.objects_stack.items[self.objects_stack.idx].size = .{ 100, 100 };
        self.objects_stack.idx += 1;
    }
};

const WINDOW_WIDTH: i32 = 1280;
const WINDOW_HEIGHT: i32 = 720;
const WINDOW_TITLE = "raylib [core] example - basic window";

var ui: UI = undefined;

pub fn is_aabb(a: Rect, b: Rect) bool {
    return a.position[0] + a.size[0] >= b.position[0] and b.position[0] + b.size[0] >= a.position[0] and
        a.position[1] + a.size[1] >= b.position[1] and b.position[1] + b.size[1] >= a.position[0];
}

pub fn is_point_aabb(a: @Vector(2, f32), b: Rect) bool {
    return a[0] >= b.position[0] and
        a[0] <= b.position[0] + b.size[0] and
        a[1] >= b.position[1] and
        a[1] <= b.position[1] + b.size[1];
}

pub fn main() void {
    r.SetConfigFlags(r.FLAG_VSYNC_HINT | r.FLAG_WINDOW_RESIZABLE | r.FLAG_MSAA_4X_HINT | r.FLAG_WINDOW_HIGHDPI);
    r.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_TITLE);
    r.SetTargetFPS(60);

    const testObject = Rect{
        .position = .{ 0, 0 },
        .size = .{ 100, 100 },
    };
    _ = testObject;
    var offset: @Vector(2, f32) = undefined;

    while (!r.WindowShouldClose()) {
        const screenW = r.GetScreenWidth();
        const screenH = r.GetScreenHeight();

        var camera: r.Camera2D = undefined;
        // camera.offset = .{ .x = @as(f32, @floatFromInt(screen_w)) / 2.0, .y = @as(f32, @floatFromInt(screen_h)) / 2.0 };
        camera.rotation = 0.0;
        camera.zoom = 1.0;

        r.ClearBackground(r.RAYWHITE);
        r.BeginDrawing();
        {
            r.BeginMode2D(camera);
            {
                const mousePosition = @Vector(2, f32){
                    r.GetMousePosition().x,
                    r.GetMousePosition().y,
                };
                const mouseDelta = @Vector(2, f32){
                    r.GetMouseDelta().x,
                    r.GetMouseDelta().y,
                };
                _ = mouseDelta;

                // X
                {
                    var pointBegin: r.Vector2 = undefined;
                    pointBegin.y = @as(f32, @floatFromInt(screenH)) / 2;
                    var pointEnd: r.Vector2 = undefined;
                    pointEnd.x = @as(f32, @floatFromInt(screenW));
                    pointEnd.y = @as(f32, @floatFromInt(screenH)) / 2;
                    r.DrawLineV(pointBegin, pointEnd, r.RED);
                }

                // Y
                {
                    var pointBegin: r.Vector2 = undefined;
                    pointBegin.x = @as(f32, @floatFromInt(screenW)) / 2;
                    var pointEnd: r.Vector2 = undefined;
                    pointEnd.x = @as(f32, @floatFromInt(screenW)) / 2;
                    pointEnd.y = @as(f32, @floatFromInt(screenH));
                    r.DrawLineV(pointBegin, pointEnd, r.GREEN);
                }

                ui.beginFrame();

                // ui.setPositionTestObject(.{ 100, 100 });
                ui.drawTestObject("Object 1");

                // ui.setPositionTestObject(.{ 200, 200 });
                ui.drawTestObject("Object 2");

                for (ui.objects_stack.items[0..ui.objects_stack.idx]) |*object| {
                    const b = Rect{ .position = object.position, .size = object.size };
                    if (is_point_aabb(mousePosition, b)) {
                        if (r.IsMouseButtonPressed(r.MOUSE_BUTTON_LEFT)) {
                            ui.hot_object = object;
                            offset[0] = mousePosition[0] - object.position[0];
                            offset[1] = mousePosition[1] - object.position[1];
                        }
                    }

                    r.DrawRectangleV(.{ .x = object.position[0], .y = object.position[1] }, .{ .x = object.size[0], .y = object.size[1] }, r.BLUE);
                    r.DrawText(&object.id[0], @as(i32, @intFromFloat(object.position[0])), @as(i32, @intFromFloat(object.position[1])), 10, r.RAYWHITE);
                }

                if (ui.hot_object) |*object| {
                    var buf: [1024]u8 = undefined;
                    _ = std.fmt.bufPrintZ(&buf, "[{s}] object: {any}\n", .{ object.*.id, object.*.position }) catch @panic("error");
                    object.*.position[0] = mousePosition[0] - offset[0];
                    object.*.position[1] = mousePosition[1] - offset[1];

                    if (r.IsMouseButtonReleased(r.MOUSE_BUTTON_LEFT)) {
                        ui.hot_object = null;
                    }

                    r.DrawText(&buf[0], 10, 10, 10, r.BLACK);
                }

                ui.endFrame();

                // r.DrawFPS(10, 10);
            }
            r.EndMode2D();
        }
        r.EndDrawing();
    }

    r.CloseWindow();
}
