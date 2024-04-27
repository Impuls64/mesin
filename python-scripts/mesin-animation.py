import sys
import time
import random

mesin_colors = ["\x1b[31m", "\x1b[32m", "\x1b[33m", "\x1b[34m", "\x1b[35m", "\x1b[36m", "\x1b[37m"]

running_colors = [
    "\x1b[31m", "\x1b[32m", "\x1b[33m",
    "\x1b[34m", "\x1b[35m", "\x1b[36m",
    "\x1b[37m"
]  # Colors for each letter in "Running"

def animate_mesin(current_index, total_scripts, script_name):
    # sys.stdout.write(f"\033[2K\rExecuting script {current_index+1}/{total_scripts}\n")
    sys.stdout.flush()
    
    while True:
        matrix_char = random.choice("Hello")
        sys.stdout.write(f"\033[2K\r")  # Clear the current line
        
        if script_name:
            sys.stdout.write(f"[\x1b[36m{matrix_char}\x1b[0m] {script_name}")  # Color the character within [] and print script name
        else:
            sys.stdout.write(f"[\x1b[36m{matrix_char}\x1b[0m] Unnamed Script")  # If no script name provided, use "Unnamed Script"
        
        sys.stdout.write(f" ({current_index+1}/{total_scripts}) ")  # Displaying index of the script
        
        running_text = "Running"
        for i in range(len(running_text)):
            color = running_colors[random.randint(0, len(running_colors)-1)]
            sys.stdout.write(f"{color}{running_text[i]}\x1b[0m")
            sys.stdout.flush()
            time.sleep(0.2)
        
        # Change color and case of each letter in 'mesin' on the last line
        colored_mesin = ''.join([f"{color}{char.upper() if random.random() < 0.5 else char.lower()}\x1b[0m" for color, char in zip(mesin_colors, "mesin")])
        sys.stdout.write(f"\n\033[2K\r{colored_mesin}")
        sys.stdout.flush()
        
        time.sleep(0.0)
        
        # Move the cursor up one line
        sys.stdout.write("\033[1A")
        sys.stdout.flush()

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python animation.py current_index total_scripts [script_name]")
        sys.exit(1)
    
    current_index = int(sys.argv[1])
    total_scripts = int(sys.argv[2])
    script_name = sys.argv[3] if len(sys.argv) >= 4 else ""
    animate_mesin(current_index, total_scripts, script_name)