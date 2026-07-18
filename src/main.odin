package main

import "shared:Toxin_new_pull/Toxin"
import "base:runtime"
import Classes "shared:Toxin_new_pull/GD_Classes"
import GDE "shared:Toxin_new_pull/GDWrapper/gdAPI/gdextension"
import "shared:Toxin_new_pull/GDWrapper/gdAPI"
import GDW "shared:Toxin_new_pull/GDWrapper"
import class "shared:Toxin_new_pull/Toxin/classes"
import "core:math/rand"


import "core:fmt"

WINDOW_SIZE :: 1000
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
MAX_SNAKE_LENGTH :: GRID_WIDTH*GRID_WIDTH

snake: [MAX_SNAKE_LENGTH]Toxin.Vector2i
snake_length: int
root: Classes.Node2D
main_canvas: Toxin.RID
once: bool
game_over: bool
food_pos: Toxin.Vector2i
texture: Classes.Texture2D
texture_rid: Toxin.RID

TICK_RATE:: 0.13
tick_timer: Toxin.float = TICK_RATE

move_direction: Toxin.Vector2i
text_interface: Classes.TextServer
shaped_text: Toxin.RID

step :: proc() {

    scene: Classes.Node2D = Toxin.get_current_scene()
    //create a canvas to draw on only once
    //This doesn't work in the startup callback
    if !once {
        root = Toxin.getRoot()
        canvas_rid: Toxin.RID
        world2d: Classes.World2D
        viewport: Classes.Viewport
        viewport = class.Node_get_viewport(root)
        world2d = class.Viewport_get_world_2d(viewport)
        canvas_rid = class.World2D_get_canvas(world2d)


        zoom:= Toxin.Vector2{f32(WINDOW_SIZE)/CANVAS_SIZE,f32(WINDOW_SIZE)/CANVAS_SIZE}
        class.Node2D_set_scale(scene, &zoom)
        main_canvas= class.RenderingServer_canvas_item_create(Toxin.RenderingServer)
        class.RenderingServer_canvas_item_set_parent(Toxin.RenderingServer, &main_canvas, &canvas_rid)
        once = true
    }
    key:GDW.Key
    key=.KEY_UP
    if class.Input_is_key_pressed(Toxin.Input, &key) {
        move_direction = {0, -1}
    }
    key=.KEY_DOWN
    if class.Input_is_key_pressed(Toxin.Input, &key) {
        move_direction = {0, 1}
    }
    key = .KEY_LEFT
    if class.Input_is_key_pressed(Toxin.Input, &key) {
        move_direction = {-1, 0}
    }
    key=.KEY_RIGHT
    if class.Input_is_key_pressed(Toxin.Input, &key) {
        move_direction = {1, 0}
    }

    perf: Toxin.float
    if game_over {
        key=.KEY_ENTER
        if class.Input_is_key_pressed(Toxin.Input, &key) {
            start()
        }
    } else {
        perf = class.Node_get_process_delta_time(root)
        //Classes.Node_get_process_delta_time->m_call(root, r_ret = &perf)
    }

    tick_timer -= perf

    if tick_timer <= 0 {
        next_part_pos:= snake[0]
        snake[0] += move_direction
        head_pos:= snake[0]
        if head_pos.x < 0 || head_pos.y < 0 || head_pos.x >= GRID_WIDTH || head_pos.y >= GRID_WIDTH {
            game_over = true
        }


        for i in 1..< snake_length {
            cur_pos:= snake[i]
            if cur_pos == head_pos {
                game_over = true
            }
            snake[i] = next_part_pos
            next_part_pos = cur_pos
        }
        if head_pos == food_pos {
            snake_length += 1
            snake[snake_length-1] = next_part_pos
            place_food()
        }
        tick_timer = TICK_RATE + tick_timer
    }
    scale:Toxin.Transform2D={f32(WINDOW_SIZE)/CANVAS_SIZE,0,0,f32(WINDOW_SIZE)/CANVAS_SIZE,0,0}
    //GDW.Transform2D_M_List.scaled(&scale, {&({f32(WINDOW_SIZE)/CANVAS_SIZE,f32(WINDOW_SIZE)/CANVAS_SIZE})}, &scale)
    class.RenderingServer_canvas_item_clear(Toxin.RenderingServer, &main_canvas)
    //Classes.RenderingServer_canvas_item_clear->m_call(Toxin.RenderingServer, {&main_canvas})
    class.RenderingServer_canvas_item_set_transform(Toxin.RenderingServer, &main_canvas, &scale)
    //Classes.RenderingServer_canvas_item_set_transform->m_call(Toxin.RenderingServer, {&main_canvas, &scale})

    antialias:Toxin.Bool=false
    head_color:= Toxin.Color{
        0,255,0,255
    }
    
    food_rect:= Toxin.Rect2{
        f32(food_pos.x)*CELL_SIZE,
        f32(food_pos.y)*CELL_SIZE,
        CELL_SIZE,
        CELL_SIZE,
    }

    food_color:= GDW.Color_RED
    //class.RenderingServer_canvas_item_add_rect(Toxin.RenderingServer, &main_canvas, &food_rect, &food_color, &antialias)
    tile:Toxin.Bool
    transpose:Toxin.Bool
    class.RenderingServer_canvas_item_add_texture_rect(Toxin.RenderingServer, &main_canvas, &food_rect, &texture_rid, &tile, &food_color, &transpose)

    for i in 0..<snake_length {
        head_rect:= Toxin.Rect2{
            f32(snake[i].x)*CELL_SIZE,
            f32(snake[i].y)*CELL_SIZE,
            CELL_SIZE,
            CELL_SIZE,
        }
        class.RenderingServer_canvas_item_add_rect(Toxin.RenderingServer, &main_canvas, &head_rect, &head_color, &antialias)
        //Classes.RenderingServer_canvas_item_add_rect->m_call(Toxin.RenderingServer, {&main_canvas, &head_rect, &head_color, &antialias})
    }
    if game_over {
        pos: Toxin.Vector2 = {00, 20}
        clip: Toxin.float = -1
        modulate: GDW.Color = {255, 255, 255, 255}
        oversampling: GDW.float = -1
        class.TextServer_shaped_text_draw(text_interface, &shaped_text, &main_canvas, &pos, &clip, &clip, &modulate, &oversampling)
        //Classes.TextServer_shaped_text_draw->m_call(text_interface, {&shaped_text, &main_canvas, &pos, &clip, &clip, &modulate, &oversampling})
    }
    
}

place_food :: proc() {
    occupied: [GRID_WIDTH][GRID_WIDTH]bool
    for i in 0..<snake_length {
        occupied[snake[i].x][snake[i].y] = true
    }
    free_cells:= make([dynamic]Toxin.Vector2i)
    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_WIDTH {
            if !occupied[x][y] {
                append(&free_cells, Toxin.Vector2i{i32(x),i32(y)})
            }
        }
    }
    if len(free_cells) >0 {
        random_cell:= rand.int_range(0, len(free_cells))
        food_pos = free_cells[random_cell]
    }
    delete(free_cells)
}

start :: proc() {
    start_head_pos:= Toxin.Vector2i{GRID_WIDTH/2, GRID_WIDTH/2}
    snake[0]=start_head_pos
    snake[1]=start_head_pos - {0,1}
    snake[2]=start_head_pos - {0,2}
    snake_length = 3
    move_direction = {0,1}
    game_over = false
    place_food()
}

