This is a small game that runs via the mainLoopCallback without the us of Nodes in the sceneTree. All elements are created and managed via Odin code.

To run.
Update the path to Godot in the .vscode launch file. If you set the path to Godot is a environment variable you should be able to just us godot instead of the direct path to the .exe.
Once updated you should be able to compile and launch the game with f5.

Should work fine on Mac and Linux provided you compile it to that platform. Should just need two commands
``odin build src -build-mode:dll --debug -out:snake_gd/bin/snake.dll``
and to launch the game itself
``C:\\Godot\\godot\\bin\\godot.windows.editor.dev.x86_64.exe --verbose --path ./asteroid``

The main scene is just there because Godot requires a main scene in order to function. Nothing is actually running in the SceneTree.

Requires the [Toxin](https://github.com/Ferinzz/Toxin) GDExtension wrapper.