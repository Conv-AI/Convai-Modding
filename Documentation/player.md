### Installation Instructions:

1. **Install Cyber Engine Tweaks Mod:**
   - Before installing the Convai mod, ensure Cyber Engine Tweaks mod is installed from NexusMods.
   - Launch the game after installing Cyber Engine Tweaks. It will prompt you to bind a key, enabling you to open the Cyber Engine Tweaks GUI during gameplay.

2. **Install Convai Mod:**
   - Download the Convai mod and extract its contents.
   - Copy the "bin" folder to the Cyberpunk 2077 game directory.
   - Navigate to `bin\x64\plugins\cyber_engine_tweaks\mods\convaimod\convai` folder.
   - Download "main.exe" from the provided GitHub link according to your mod version and copy them to the Convai folder. 
   - https://github.com/Conv-AI/Convai-Modding/tree/Cyberpunk-2077
   - Create a free account at convai.com and obtain your API key.
   - Paste the API key into the file named `api_key.txt`.

3. **Launch and Setup:**
   - Double-click on "main.exe" whenever you launch the game or reload mods in Cyber Engine Tweaks.
   - The application will run in the background, communicating with the Lua mod via text files when interacting with NPCs using hotkeys.
   - It will automatically close when you exit the game or reload mods.

4. **Binding Hotkeys:**
   - Launch the game and press the key bound to Cyber Engine Tweaks to open the GUI.
   - In the GUI, navigate to the "Bindings" section.
   - Assign a hotkey to both "Talk to NPCs with Microphone" and "Talk to NPCs with Keyboard" options.
   - Save the changes.

### Customization Instructions:

1. **Customizing Characters:**
   - Open `init.lua` and scroll to the bottom.
   - Find the "Character ID Mapping" table.
   - Locate the character you want to customize or add a new character to the table.
   - Replace the existing character ID with the ID of your custom character created in the Convai dashboard.

2. **Creating New Characters:**
   - Go to the Convai dashboard and click on "Create New Character."
   - Enter a name, information, memories, and select a voice for the character.
   - Optionally, add more detailed information about the character in the "Knowledge Bank" and connect it.
   - After any modification, press the "Update" button.

3. **Using Custom Voices from Elevenlabs:**
   - Visit the Convai dashboard and navigate to Profile > API Integrations.
   - Select "Add New Key" and input your Elevenlabs API key.
   - Your custom voices will be visible in the "Voice" section of the character for selection.