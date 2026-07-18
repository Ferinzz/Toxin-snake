#!/bin/bash
# filepath: build.sh

# This build setup assumes that vscode's project is a folder containing a
# src folder for the Odin gdextension code as well as a godot project folder.

# Main
# |_godot_project/bin - put your dll and .gdextension here.
# |_src - Odin extension code here.
# ::|_GDWrapper/gdextension - Don't forget to include the GDWrapper and gdextension packages in your Odin folder or as a shared library.

# Dump the details about Godot's API. This only needs to be done once.
# gdextension-interface is the C header file.
# extension-api is a massive json file with all the classes and method info.
# /path/to/godot --headless --dump-gdextension-interface
# /path/to/godot --headless --dump-extension-api

# Builds whatever odin main package there is in the folder you're in.
# Currently set to target a src folder, as that's what I currently work out of.
odin build src -build-mode:dll --debug -out:snake_gd/bin/snake.dll

# Launch Godot with your project (optional)
# godot --verbose --path ./snake_gd