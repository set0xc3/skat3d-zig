const std = @import("std");

const rlib = @cImport({
    @cInclude("raylib.h");
});

pub fn main() void {
    rlib.InitWindow(800, 450, "raylib [core] example - basic window");

    while (!rlib.WindowShouldClose()) {
        rlib.BeginDrawing();
        rlib.ClearBackground(rlib.RAYWHITE);
        rlib.DrawText("Congrats! You created your first window!", 190, 200, 20, rlib.LIGHTGRAY);
        rlib.EndDrawing();
    }

    rlib.CloseWindow();
}
