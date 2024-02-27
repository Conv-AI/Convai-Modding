This guide will show you how to make Mods that add Convai's features to any pre-existing or already released game, regardless of which engine it is using as long as it has a modding framework capable of creating logic based mods and is able to call scripts or executables or at least write to text files. We will use Cyberpunk 2077 and Cyber Engine Tweaks it's modding framework as an example. The mod we'll create will let players talk to the characters through their microphone or keyboard and the character can even select and perform actions. Lipsync is a little tricky and depends on how the game implements it. If you're working on a mod for an Unreal Engine game, check out our guide for the Hogwarts Legacy mod on Nexus Mods, where we explain lipsync in more detail.

We'll be use the following tools:

Convai SDK(C++) (https://github.com/Conv-AI/convai-sdk-cpp): This repository provides a set of libraries to access the Convai Character GetResponse API via gRPC streaming.
Cyber Engine Tweaks (https://www.nexusmods.com/cyberpunk2077/mods/107): Cyber Engine Tweaks is a framework giving modders a way to script mods using Lua with access to all the internal scripting features, it also comes with a UI to configure the different mods you are using or using the console directly.

Installation
Let's get started by setting up the Convai SDK. First, go to the repository's readme and follow the instructions for installing Bazel and building the project.

If you encounter a "roots.pem" error, go to the file "convai-sdk-cpp\bazel-convai-sdk-cpp\external\com_github_grpc_grpc\src\core\lib\security\security_connector\ssl_utils.cc" and find line 60. Change the path to only "roots.pem". Then, copy the "roots.pem" file from "convai-sdk-cpp/bazel-convai-sdk-cpp/external/com_github_grpc_grpc/etc/" and paste it next to the "main.exe" file in the "convai-sdk-cpp\bazel-bin" directory or whichever directory you're using to execute "main.exe" from. When packaging your mod, ensure that you include the "roots.pem" file with  "main.exe".

Cyber Engine Tweaks can found at nexusmods.

Mod Creation
To grasp the Mod creation process, let's walk through the steps I took for the Cyberpunk 2077 Mod. You can find the code I used in the Source Code folder of the mod.

We'll begin with "main.cc," which holds the logic for "main.exe." Essentially, "main.cc" captures either the player's audio from microphone or text input from keyboard depending on the value in user_method_of_input.txt which is set by the lua mod, main.cc looks in the "get_response_config_example.txt" file for details like character ID, API key, available actions, and more which is again set by the lua mod. It then sends this information to Convai. After that, it plays the audio of the resulting dialogue of the character the player is interacting with and saves both the dialogue and action to a text file. This text file is later used to display subtitles and choose the appropriate in-game action. Additionally you can even get lipsync viseme data from the convai sdk for accurate lipsync.

We use Cyber Engine Tweaks to create a Lua mod, which waits for the player to press F6 or F7 or whichever key the player selected as the hotkey for the mod. When it is pressed, the Lua mod finds the character the player is looking at, extracts information like the character's name, and uses it to find the character ID from a dictionary defined in the Lua file. This information is then written to the "get_response_config_example.txt" file.

Next, we would use os.execute to run "main.exe" but since Cyber Engine Tweaks does not support os.execute so we need to look at a text file called control.txt and waits for it to have "start" and when it does run the main logic, the player will need to double click main.exe before launching the game. You can take a look at main.cc in source code folder to get a better understanding of what's going on. The execution completes after playing the dialogue. We parse the dialogue text and action value to display as subtitles. Using string matching we check which action was selected and execute the correct if block for that action.

Reviewing the code in "init.lua", "main.cc" will provide a clearer understanding.

Helpful Tools, Examples and Guides from the Community
https://wiki.redmodding.org/home/
https://wiki.redmodding.org/cyber-engine-tweaks/
https://github.com/psiberx/cp2077-cet-kit/tree/main
https://github.com/WolvenKit/cet-examples/tree/main/ai-components

Special Thanks
A special shout-out goes to the modding community at Cyberpunk 2077. Without their invaluable assistance, tools, guides, and documentation, none of this would have been achievable. Much appreciation for their indispensable contributions!