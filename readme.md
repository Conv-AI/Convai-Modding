# Developer Guide
Before you read this guide, it's a good idea to check out the player guide first.

This guide will show you how to make Mods that add Convai's features to any pre-existing or already released Unreal Engine game, from version 4.12 to 5.2.

We'll be use the following tools:
- [Convai SDK(C++)](https://github.com/Conv-AI/convai-sdk-cpp): This repository provides a set of libraries to access the Convai Character GetResponse API via gRPC streaming.
- [UE4SS: Lua scripting system platform](https://github.com/UE4SS-RE/RE-UE4SS): C++ Modding API, SDK generator, blueprint mod loader, live property editor and other dumping utilities for UE4/5 games.

# Installation
Let's get started by setting up the [Convai SDK](https://github.com/Conv-AI/convai-sdk-cpp). First, go to the repository's readme and follow the instructions for installing Bazel and building the project.

If you encounter a "roots.pem" error, go to the file "convai-sdk-cpp\bazel-convai-sdk-cpp\external\com_github_grpc_grpc\src\core\lib\security\security_connector\ssl_utils.cc" and find line 60. Change the path to only "roots.pem". Then, copy the "roots.pem" file from "convai-sdk-cpp/bazel-convai-sdk-cpp/external/com_github_grpc_grpc/etc/" and paste it next to the "main.exe" file in the "convai-sdk-cpp\bazel-bin" directory or whichever directory you're using to execute "main.exe" from. When packaging your mod, ensure that you include the "roots.pem" file with  "main.exe".

If you've followed the player guide, [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) should already be installed.

To make blueprint Mods, you will need to install the unreal engine version that was used to make that game. For example Hogwarts Legacy used UE4.27 so we need to use that version for making the Blueprint Mod. Locate the exe file of the game and right click on it, select properties and go to details tab and you will find the version.

# Mod Creation
To grasp the Mod creation process, let's walk through the steps I took for the Hogwarts Legacy Mod. You can find the code I used in the repository.

We'll begin with "main.cc," which holds the logic for "main.exe." Essentially, "main.cc" captures the player's audio, looks in the "get_response_config_example.txt" file for details like character ID, API key, available actions, and more. It then sends this information to Convai. After that, it plays the audio of the resulting dialogue of the character the player is interacting with and saves both the dialogue and action to a text file. This text file is later used to display subtitles and choose the appropriate in-game action. Additionally you can even get lipsync viseme data from the convai sdk for accurate lipsync.

Once we have the "main.exe," we execute it only when the player interacts with a character. We use UE4SS to create a Lua mod, which waits for the player to press F7. When F7 is pressed, the Lua mod finds the nearest character of the class "NPC_Character," extracts information like the character's name, and uses it to find the character ID from a dictionary defined in the Lua file. This information is then written to the "get_response_config_example.txt" file.

Next, we use os.execute to run "main.exe." The execution completes after playing the dialogue. We parse the dialogue text and action value to display as subtitles. For the action value, we save it to a global variable. In the blueprint Mod, we create an empty function named "actionfunction" in the ModActor with one output pin. In the Lua mod, we create a custom event with the same name, setting the output value to the action value. When the blueprint mod calls the empty function, it instead triggers the custom event defined in the Lua mod, providing the action value. The blueprint mod will then use this to trigger the right action.

To add Lipsync, Create a function in your blueprint mod that prints the curve names, this will give a list of blendshapes you can move. Check which blendshapes are related to lips. Use the setmorphtarget node to create a function in blueprint mod to move a blendshape by a given value. Once you have a list of blendshape names and a function that takes a blendshape name and value and moves it by that value, the next step is to make a function in your lua mod that essentially uses a couple of equations to figure out how much to move a given blendshape by and then calls the function you made above for each blendshapes that is needed for Lipsync.  

To create lua mods with UE4SS, Go to this folder Phoenix\Binaries\Win64\Mods and then make a folder with your mod name and then open Phoenix\Binaries\Win64\Mods\mods.txt and enable your mod. Make a Scripts\main.lua file which will house the logic of your lua mod.

To create a blueprint mod with UE4SS, open a blank project with no content using unreal engine which is the same version as the game you are modding. The name of the blank project should be the same as the one in your game folder, for example Hogwarts Legacy has a folder called phoenix so I named the blank level phoenix. In project settings/packaging enable "Use Pak File" and "Generate Chunks" and any other setting that is required for the game you are modding. For example Hogwarts Legacy uses Io Store so I had to enable that setting as well. Then in editor preference/experimental enable "Allow ChunkID Assignments". Next create a blank level with any name, followed by creating a Mods folder and then a folder with your mod's name and within it create a actor with name ModActor. Drag this ModActor into the level. Open the ModActor and make a couple of blueprint functions which you can later call from your lua mod. Right click on the Level you made and go to asset actions/assign to chunk and select a number, repeat the same for ModActor and any other asset with the same number. Go to file/package project/build configuration and select shipping and then click on Windows to package your mod. In the folder you chose for packaging the mod go to WindowsNoEditor/{project_name}/Content/Paks and rename the three files with the number you selected above to match the name of the folder you made in Mods folder in unreal engine.

To call functions from the blueprint mod in our Lua mod, we use "FindFirstOf" to locate the ModActor we created above and then call the required function.Reviewing the code in "main.lua", "main.cc", "convailevel.umap" and "ModActor.uasset" will provide a clearer understanding.

### Helpful Tools, Examples and Guides:
- https://modding.wiki/en/hogwartslegacy/developers/hlblueprintex
- https://modding.wiki/en/hogwartslegacy
- https://github.com/LongerWarrior/FModel/releases/tag/HW_1.0.0.0
- https://modding.wiki/en/hogwartslegacy/developers/PhoenixUProjGuide
- https://modding.wiki/en/hogwartslegacy/developers/luaexamples
- https://docs.ue4ss.com/dev/index.html

### Special Thanks
A special shout-out goes to the modding community at UE4SS and Hogwarts Legacy. Without their invaluable assistance, tools, guides, and documentation, none of this would have been achievable. Much appreciation for their indispensable contributions!
