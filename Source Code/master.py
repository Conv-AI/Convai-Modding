import subprocess
import sys
import os
import time

def open_exe(exe_path):
    try:
        subprocess.Popen(exe_path, creationflags=subprocess.CREATE_NEW_CONSOLE)
    except Exception as e:
        print("Error:", e)
        sys.exit(1)

def check_control_file():
    control_file_path = os.path.join(master_dir, "control.txt")
    if os.path.exists(control_file_path):
        with open(control_file_path, 'r') as file:
            content = file.read().strip()
            with open(control_file_path, 'w') as file:
                    file.write("")
            if content == "start":
                open_exe(main_exe_path)
            elif content == "exit":
                sys.exit(0)


# Get the directory where the master.exe is located
master_dir = os.path.dirname(os.path.abspath(sys.argv[0]))

# Assuming main.exe is in the same directory as master.exe
main_exe_path = os.path.join(master_dir, "main.exe")

# Check if control.txt exists, if not create it
control_file_path = os.path.join(master_dir, "control.txt")
if not os.path.exists(control_file_path):
    open(control_file_path, 'w').close()

with open(control_file_path, 'w') as file:
                file.write("")
while True:
    check_control_file()
    time.sleep(0.1)  # Sleep for 100 milliseconds
