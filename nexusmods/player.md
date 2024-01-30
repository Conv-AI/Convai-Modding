# Mod Installation Guide

1. After downloading the file from nexusmods, extract it and find the "Phoenix" folder in it and copy it.
2. Paste the "Phoenix" folder into the directory "C:\\Program Files\\Epic Games\\HogwartsLegacy" or the location where your game is installed.
3. Depending on which version you installed, grab main.exe from here https://drive.google.com/drive/folders/15V0WL59x9AVo6uy2BEZelrHpJRSQb7PT?usp=sharing and copy it here "C:\\Program Files\\Epic Games\\HogwartsLegacy\\Phoenix\\Binaries\\Win64\\convai"
4. Create a free account at https://www.convai.com/?referrer=hogwartslegacymod and then access the dashboard at https://convai.com/pipeline/dashboard.
5. Copy the API key by clicking on the key icon located at the top right of the navigation bar next to your account name.
6. Open "C:\\Program Files\\Epic Games\\HogwartsLegacy\\Phoenix\\Binaries\\Win64\\convai\\api_key.txt" with Notepad and paste your API key.
7. Launch the game.

# Using the Mod

1. Approach the character you wish to interact with.
2. Press F7 and start speaking after a second to initiate the conversation.
3. The character will respond back with a audio response and lipsync followed by a subtitle.
4. Characters can perform various actions based on your queries, such as becoming your companion, stopping at a location, resuming following you, or moving to a specific location.

# Customizing Character Details

1. You customize the character's voice, backstory, personality, catchphrase, and more by modifying the character ID in the file located at:
   "C:\\Program Files\\Epic Games\\HogwartsLegacy\\Phoenix\\Binaries\\Win64\\Mods\\ConvaiMod\\Scripts\\main.lua".
   Scroll to the bottom of the file to find a dictionary with character names and IDs.

2. Visit https://convai.com/pipeline/dashboard.

3. Click on "Create New Character" and create a new character according to your preferences.

4. Once you're finished, copy the character ID present in the character description section.

5. Paste the copied character ID into the associated character entry in the "main.lua" file.
