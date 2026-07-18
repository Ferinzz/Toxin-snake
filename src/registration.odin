package main

import "shared:Toxin_new_pull/GDWrapper/gdAPI"
import "shared:Toxin_new_pull/Toxin"
import "base:runtime"
import Classes "shared:Toxin_new_pull/GD_Classes"
import GDE "shared:Toxin_new_pull/GDWrapper/gdAPI/gdextension"
import GDW "shared:Toxin_new_pull/GDWrapper"
import class "shared:Toxin_new_pull/Toxin/classes"


@export
godot_entry_init :: proc "c" (p_get_proc_address: GDE.InterfaceGetProcAddress, p_library: GDE.ClassDB, initialization: ^GDE.Initialization) -> b8 {
    context = runtime.default_context()
    return Toxin.toxin_entry(p_get_proc_address, p_library, initialization, &core_setup)
}

//@(rodata)
core_setup: Toxin.inits_deinits= {
    nil,
    core_init,
    servers_init,
    scene_init,
    editor_init,
    core_deinit,
    servers_deinit,
    scene_deinit,
    editor_deinit,
    {},
}
core_init :: proc "c" (userdata: rawptr) {
    context = runtime.default_context()

    Toxin.register_mainloop_callbacks({main_loop_startup, main_loop_shutdown, MainLoopFrameCallback, })
}

servers_init :: proc "c" (userdata: rawptr) {

}

scene_init :: proc "c" (userdata: rawptr) {
    context = runtime.default_context()
}
editor_init :: proc "c" (userdata: rawptr) {

}
core_deinit :: proc "c" (userdata: rawptr) {

}
servers_deinit :: proc "c" (userdata: rawptr) {

}
scene_deinit :: proc "c" (userdata: rawptr) {
    context = runtime.default_context()
}
editor_deinit :: proc "c" (userdata: rawptr) {

}

//This is the best time to initialize the class methods as it will consistently be called after all classes have been added to the classDB
//Exception: if you're doing extension reloading this would not trigger
main_loop_startup :: proc "c" () {
    context = runtime.default_context()

    Classes.Node_Init_()
    Classes.CanvasItem_Init_()
    Classes.Viewport_Init_()
    Classes.World2D_Init_()
    Classes.Window_Init_()
    Classes.Font_Init_()
    Classes.TextServer_Init_()
    Classes.Node2D_Init_()
    Classes.CanvasItem_Init_()
    Toxin.textserver_init()

    //init singletons used.
    Toxin.init_renderserver_procs()
    Toxin.init_textservermanager_procs()
    Toxin.init_ThemeDB_procs()
    Classes.ResourceLoader_Init_()
    Classes.Texture2D_Init_()
    class.Resource_Init()

    scene: ^Toxin.Object = Toxin.get_current_scene()
    
    text_interface = Toxin.TextServerManager_get_primary_interface()
    font: Classes.Font = Toxin.themedb_get_fallback_font()
    fonts: Toxin.Array
    Classes.Font_get_rids->m_call(font, r_ret = &fonts)
    direction: Classes.TextServer_Direction
    orientation: Classes.TextServer_Orientation
    shaped_text = class.TextServer_create_shaped_text(text_interface, &direction, &orientation)
    //shaped_text = Toxin.textserver_create_shaped_text(text_interface)
    message: Toxin.gdstring = Toxin.gdstring_new("game over")
    size:Toxin.Int=20
    dumb_dic: Toxin.Dictionary
    GDW.Dictionary_M_List.Create0(&dumb_dic)
    lang: Toxin.gdstring = Toxin.gdstring_new("")
    dumb: Toxin.Variant
    text_err:= class.TextServer_shaped_text_add_string(text_interface, &shaped_text, &message, &fonts, &size, &dumb_dic, &lang, &dumb)
    //text_err:= Toxin.textserver_shaped_text_add_string(text_interface, shaped_text, "game over", fonts, 20)
    text_err= class.TextServer_shaped_text_shape(text_interface, &shaped_text)
    //text_err = Toxin.textserver_class_shaped_text_shape(text_interface, &shaped_text)
    GDW.Dictionary_M_List.Destroy(&dumb_dic)
    GDW.gdstring_M_List.Destroy(&lang)
    GDW.gdstring_M_List.Destroy(&message)
    //A scene is not added when running editor mode first time. Check for the scene before trying to add the child to it.
    if scene != nil {
        start()
    }

    cache:Classes.ResourceLoader_CacheMode=.CACHE_MODE_REUSE
    texture= Toxin.loadResource("icon.svg", "Texture2D",&cache)
    texture_rid= class.Resource_get_rid(texture)
}

main_loop_shutdown :: proc "c" () {
}

MainLoopFrameCallback :: proc "c" () {
    context = runtime.default_context()
    step()
}