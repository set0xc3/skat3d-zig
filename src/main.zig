// UI
// TODO: состояние мыши?
// TODO: массив объектов.
// TODO: рисовать объект.
//          - position
//          - size
//          - color
// TODO: id объекта.
// TODO: текущий объект.
// TODO: горячий объект.
// TODO: фиксировать нажатие по объекту

const std = @import("std");

const r = @cImport({
    @cInclude("raylib.h");
});

const Rect = struct {
    position: @Vector(2, f32),
    size: @Vector(2, f32),
};

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

const UI = struct {
    const Object = struct {
        id: []const u8,
        position: @Vector(2, f32),
        size: @Vector(2, f32) = .{ 1, 1 },
    };

    objects: [1000]Object,
    object_idx: u32,

    hot_object: ?*Object,

    mouse: struct {
        position: @Vector(2, f32),
    },

    pub fn init() void {}

    pub fn deInit() void {}

    pub fn beginFrame(self: *@This()) void {
        if (self.object_idx >= 1000) {
            self.object_idx = 0;
        }
    }

    pub fn endFrame(self: *@This()) void {
        self.object_idx = 0;
    }

    pub fn drawTestObject(self: *@This(), id: []const u8, position: @Vector(2, f32), size: @Vector(2, f32)) void {
        // var buf: [1024]u8 = undefined;
        // const newID = std.fmt.bufPrintZ(&buf, "{d}:{s}\n", .{ self.object_idx, id }) catch @panic("error");
        // std.debug.print("{s}", .{newID});

        self.objects[self.object_idx].id = id;
        self.objects[self.object_idx].position = position;
        self.objects[self.object_idx].size = size;
        self.object_idx += 1;
    }
};

const WINDOW_WIDTH: i32 = 1280;
const WINDOW_HEIGHT: i32 = 720;
const WINDOW_TITLE = "raylib [core] example - basic window";

var ui: UI = undefined;

pub fn main() void {
    r.SetConfigFlags(r.FLAG_VSYNC_HINT | r.FLAG_WINDOW_RESIZABLE | r.FLAG_MSAA_4X_HINT | r.FLAG_WINDOW_HIGHDPI);
    r.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_TITLE);
    r.SetTargetFPS(60);

    while (!r.WindowShouldClose()) {
        const screen_w = r.GetScreenWidth();
        const screen_h = r.GetScreenHeight();

        var camera: r.Camera2D = undefined;
        // camera.offset = .{ .x = @as(f32, @floatFromInt(screen_w)) / 2.0, .y = @as(f32, @floatFromInt(screen_h)) / 2.0 };
        camera.rotation = 0.0;
        camera.zoom = 1.0;

        const offset: @Vector(2, f32) = undefined;
        _ = offset;
        const testObjectPosition = @Vector(2, f32){ 400, 300 };
        const testObjectSize = @Vector(2, f32){ 100, 100 };

        r.ClearBackground(r.RAYWHITE);
        r.BeginDrawing();
        {
            r.BeginMode2D(camera);
            {
                var mouse_position: @Vector(2, f32) = undefined;
                mouse_position[0] = r.GetMousePosition().x;
                mouse_position[1] = r.GetMousePosition().y;

                // X
                {
                    var point_begin: r.Vector2 = undefined;
                    point_begin.y = @as(f32, @floatFromInt(screen_h)) / 2;
                    var point_end: r.Vector2 = undefined;
                    point_end.x = @as(f32, @floatFromInt(screen_w));
                    point_end.y = @as(f32, @floatFromInt(screen_h)) / 2;
                    r.DrawLineV(point_begin, point_end, r.RED);
                }

                // Y
                {
                    var point_begin: r.Vector2 = undefined;
                    point_begin.x = @as(f32, @floatFromInt(screen_w)) / 2;
                    var point_end: r.Vector2 = undefined;
                    point_end.x = @as(f32, @floatFromInt(screen_w)) / 2;
                    point_end.y = @as(f32, @floatFromInt(screen_h));
                    r.DrawLineV(point_begin, point_end, r.GREEN);
                }

                ui.beginFrame();
                ui.drawTestObject("Object 1", testObjectPosition, testObjectSize);

                if (ui.hot_object) |*object| {
                    var buf: [1024]u8 = undefined;
                    _ = std.fmt.bufPrintZ(&buf, "object: {any}\n", .{object}) catch @panic("error");
                    r.DrawText(&buf[0], 10, 10, 10, r.BLACK);

                    if (r.IsMouseButtonDown(r.MOUSE_BUTTON_LEFT)) {}

                    if (r.IsMouseButtonReleased(r.MOUSE_BUTTON_LEFT)) {
                        ui.hot_object = null;
                    }
                }

                for (ui.objects[0..ui.object_idx]) |*object| {
                    const b = Rect{ .position = object.position, .size = object.size };
                    if (is_point_aabb(mouse_position, b)) {
                        if (r.IsMouseButtonPressed(r.MOUSE_BUTTON_LEFT)) {
                            ui.hot_object = object;
                        }
                    }

                    r.DrawRectangleV(.{ .x = object.position[0], .y = object.position[1] }, .{ .x = object.size[0], .y = object.size[1] }, r.BLUE);
                    r.DrawText(&object.id[0], @as(i32, @intFromFloat(object.position[0])), @as(i32, @intFromFloat(object.position[1])), 10, r.RAYWHITE);
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
