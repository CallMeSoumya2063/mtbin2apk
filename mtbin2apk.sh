#!/bin/bash

# Ensure that the script is running in Termux
[ -z "$TERMUX_VERSION" ] && echo -e "Termux not detected !!" && exit 1

# Define rsapksign version to use during modifying apk
rsapksign_ver="v0.1.10"

# Define color variables
RED='\e[31m'
BLUE='\e[34m'
GREEN='\e[32m'
YELLOW='\e[33m'
MAGENTA='\e[35m'
RESET='\e[0m'

# Define a function to draw '=' signs across screen width as separation line
width=$(stty size | awk '{print $2}')
separate() { printf '%*s\n' "$width" '' | tr ' ' '='; }

# Determine device architecture
arch=$(uname -m)

# Define download URLs based on device architecture
url_const="https://github.com/mcbegamerxx954/rsapksign/releases/download"
case "$arch" in
    aarch64 | arm64)
        rsapksign_url="$url_const/$rsapksign_ver/rsapksign-aarch64-linux-android.tar.gz"
        rsapksign_file="$rsapksign_ver-rsapksign-aarch64-linux-android.tar.gz"
        ;;
    armv7l | arm | armv8l | arm32)
        rsapksign_url="$url_const/$rsapksign_ver/rsapksign-armv7-linux-androideabi.tar.gz"
        rsapksign_file="$rsapksign_ver-rsapksign-armv7-linux-androideabi.tar.gz"
        ;;
    x86_64)
        rsapksign_url="$url_const/$rsapksign_ver/rsapksign-x86_64-unknown-linux-gnu.tar.gz"
        rsapksign_file="$rsapksign_ver-rsapksign-x86_64-unknown-linux-gnu.tar.gz"
        ;;
    *)
        echo "${RED}Unsupported architecture:${RESET} ${MAGENTA}$arch${RESET}"
        separate
        exit 1
        ;;
esac
separate

# Install dependencies
yes | pkg install fd unzip
separate

# Setup storage permission for Termux if necessary
directory="$HOME/storage"
if [ -d "$directory" ]; then
    echo -e "${BLUE}Termux's storage is already setup, skipping storage setup.${RESET}"
else
    echo -e "${YELLOW}Pressing ENTER on your keyboard will confirm selections and accept your input.${RESET}"
    read -s -p "Press ENTER to continue..."
    separate
    echo -e "${YELLOW}Please allow termux to access your storage.${RESET}"
    read -s -p "Press ENTER to continue..."
    termux-setup-storage
    sleep 2
    read -s -p "Once you have allowed, press ENTER to continue..."
fi
separate

# Get and validate important app info
while true; do
    echo -e "${YELLOW}Please enter the following info about modified Minecraft here...${RESET}\n"
    read -p "App Name: " app
    if [ -z "$app" ]; then
        echo -e "${RED}App name cannot be empty. Please try again.${RESET}\n"
        sleep 0.67
    else
        break
    fi
done

regex='^[A-Za-z][A-Za-z0-9]*(\.[A-Za-z][A-Za-z0-9]*)+$'
while true; do
    read -p "Package Name: " pack
    if [[ $pack =~ $regex ]]; then
        break
    else
        echo -e "${RED}Invalid package name. Please enter a valid package name.${RESET}"
        sleep 0.67
    fi
done

separate

echo -e "${BLUE}Searching for all Minecraft APK files in /storage/emulated/0/Download/mcpe, this may take a while...${RESET}"

# Select Minecraft apk with the faster approach to find all APK files having "Minecraft" (case insensitive) in file name, thanks @devendrn for the old one
readarray -d '' files < <(fd -0 -i -t f -e apk 'minecraft' /storage/emulated/0/Download/mcpe/)
if [ ${#files[@]} -eq 0 ]; then
    echo -e "${RED}No APK files with 'Minecraft' in the name found.${RESET}\n\n${YELLOW}TIP${RESET}: Make sure you have an APK in /storage/emulated/0/Download/mcpe that has the word 'Minecraft' in filename.\n\n${RED}Error found, stopping modifying apk process...${RESET}"
    separate
    exit 1
elif [ ${#files[@]} -eq 1 ]; then
    selected_file="${files[0]}"
    echo -e "${YELLOW}Found only one APK file:${RESET} ${MAGENTA}$selected_file${RESET}\n\nUsing the only auto-detected file for modifying apk..."
else
    echo -e "\n${YELLOW}Multiple APK files found!${RESET}"
    for i in "${!files[@]}"; do
        printf "${YELLOW}[%d]${RESET} %s\n" "$((i+1))" "${files[$i]##*/}"
    done
    while true; do
        echo -ne "\n${BLUE}[?]${RESET} ${YELLOW}Please enter the number beside the APK file you want to use:${RESET} "
        read -r selection
        if [[ $selection =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#files[@]}" ]; then
            selected_file="${files[$((selection-1))]}"
            echo -e "\n${BLUE}Selected APK file:${RESET} ${MAGENTA}${selected_file##*/}${RESET}\n\nUsing chosen file for modifying apk..."
            break
        else
            echo -e "${RED}Invalid selection. Please try again.${RESET}\n"
        fi
    done
fi
separate

echo -e "${BLUE}Searching for all mcpack files in /storage/emulated/0/Download/shaders, this may take a while...${RESET}\n\n${RED}WARNING${RESET}: Please use shaders that are for your OS ('merged' or 'android') and updated for your Minecraft version to avoid issues in game!"
sleep 3

# Select mcpack file with the same fast approach
readarray -d '' mcpacks < <(fd -0 -t f -e mcpack . /storage/emulated/0/Download/shaders/)
if [ ${#mcpacks[@]} -eq 0 ]; then
    echo -e "${RED}No .mcpack files found.${RESET}\n\n${YELLOW}TIP${RESET}: Make sure you have a .mcpack file in /storage/emulated/0/Download.\n\n${RED}Error found, stopping process...${RESET}"
    separate
    exit 1
elif [ ${#mcpacks[@]} -eq 1 ]; then
    selected_mcpack="${mcpacks[0]}"
    echo -e "${YELLOW}Found only one .mcpack file:${RESET} ${MAGENTA}$selected_mcpack${RESET}\n\nUsing the only auto-detected file for processing..."
else
    echo -e "\n${YELLOW}Multiple .mcpack files found!${RESET}"
    for i in "${!mcpacks[@]}"; do
        printf "${YELLOW}[%d]${RESET} %s\n" "$((i+1))" "${mcpacks[$i]##*/}"
    done
    while true; do
        echo -ne "\n${BLUE}[?]${RESET} ${YELLOW}Please enter the number beside the .mcpack file you want to use:${RESET} "
        read -r pk_selection
        if [[ $pk_selection =~ ^[0-9]+$ ]] && [ "$pk_selection" -ge 1 ] && [ "$pk_selection" -le "${#mcpacks[@]}" ]; then
            selected_mcpack="${mcpacks[$((pk_selection-1))]}"
            echo -e "\n${BLUE}Selected .mcpack file:${RESET} ${MAGENTA}${selected_mcpack##*/}${RESET}\n\nUsing chosen file for processing..."
            break
        else
            echo -e "${RED}Invalid selection. Please try again.${RESET}\n"
        fi
    done
fi
out="$app $(basename "$selected_mcpack" .mcpack).apk"
separate

echo -e "${YELLOW}Scanning for subpacks...${RESET}"

# Select subpacks from mcpack
readarray -t subpacks < <(unzip -Z1 "$selected_mcpack" 2>/dev/null | grep -E '(^|/)subpacks/[^/]+/renderer/materials/.*\.bin$' | awk -F 'subpacks/' '{print $2}' | cut -d '/' -f 1 | sort -u)
CHOSEN_SUBPACK=""
if [ ${#subpacks[@]} -gt 0 ] && [ -n "${subpacks[0]}" ]; then
    echo -e "\n${YELLOW}Subpacks found! Please choose a subpack to apply over the regular materials:${RESET}"
    printf "${YELLOW}[0]${RESET} None (Extract regular base materials only)\n"
    
    for i in "${!subpacks[@]}"; do
        printf "${YELLOW}[%d]${RESET} %s\n" "$((i+1))" "${subpacks[$i]}"
    done
    
    while true; do
        echo -ne "\n${BLUE}[?]${RESET} ${YELLOW}Please enter the number beside the subpack you want to use:${RESET} "
        read -r sp_selection
        if [[ $sp_selection =~ ^[0-9]+$ ]] && [ "$sp_selection" -ge 0 ] && [ "$sp_selection" -le "${#subpacks[@]}" ]; then
            if [ "$sp_selection" -eq 0 ]; then
                echo -e "\n${BLUE}Selected:${RESET} ${MAGENTA}None (Regular only)${RESET}"
            else
                CHOSEN_SUBPACK="${subpacks[$((sp_selection-1))]}"
                echo -e "\n${BLUE}Selected Subpack:${RESET} ${MAGENTA}$CHOSEN_SUBPACK${RESET}"
            fi
            break
        else
            echo -e "${RED}Invalid selection. Please try again.${RESET}\n"
        fi
    done
else
    echo -e "${BLUE}No subpacks containing renderer/materials/ found. Proceeding with regular materials only.${RESET}"
fi
separate

# Prepare material bins to inject into apk and mirror apk's internal structure
TEMP_STAGE=$(mktemp -d)
APK_TARGET_DIR="$TEMP_STAGE/assets/assets/renderer/materials"
mkdir -p "$APK_TARGET_DIR"

echo -e "${YELLOW}Extracting regular base materials to staging...${RESET}"
unzip -j -o -q "$selected_mcpack" "*renderer/materials/*.bin" -x "*subpacks/*" -d "$APK_TARGET_DIR"

if [ -n "$CHOSEN_SUBPACK" ]; then
    echo -e "${YELLOW}Applying subpack materials: ${MAGENTA}$CHOSEN_SUBPACK${YELLOW}...${RESET}"
    unzip -j -o -q "$selected_mcpack" "*subpacks/$CHOSEN_SUBPACK/renderer/materials/*.bin" -d "$APK_TARGET_DIR"
fi

# Inject material bins into the apk
WORKING_APK="$TEMP_STAGE/working_copy.apk"
cp "$selected_file" "$WORKING_APK"
echo -e "${YELLOW}Injecting materials directly into APK...${RESET}"
cd "$TEMP_STAGE" || exit 1
zip -urq "$WORKING_APK" assets/
cd - > /dev/null
echo -e "${BLUE}Done! Material bin files injected successfully into:${RESET} ${MAGENTA}$(basename "$selected_file")${RESET}"
separate

# Vanilla music removal
echo -ne "\n${BLUE}[?]${RESET} ${YELLOW}Do you want to remove the vanilla_music folder from the APK? (y/N):${RESET} "
read -r rm_mus
yn="${rm_mus,,}"
if [[ "$yn" == "y" || "$yn" == "ye" || "$yn" == "yes" ]]; then
    echo -e "${YELLOW}Removing vanilla_music folder from APK...${RESET}"
    zip -dq "$WORKING_APK" "assets/assets/resource_packs/vanilla_music/*" "assets/assets/resource_packs/vanilla_music/" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${BLUE}Successfully removed vanilla_music from the APK!${RESET}"
    else
        echo -e "${BLUE}Notice: vanilla_music folder was not found in the APK (already removed or missing).${RESET}"
    fi
else
    echo -e "${BLUE}Skipping removal of vanilla_music folder.${RESET}"
fi
separate

# Check if the rsapksign file already exists, download if necessary
if [ -f "$rsapksign_file" ]; then
    echo -e "${GREEN}rsapksign file for${RESET} ${MAGENTA}$rsapksign_ver${RESET} ${GREEN}already exists, skipping download.${RESET}\n"
else
    echo -e "${BLUE}Downloading rsapksign file${RESET} ${MAGENTA}$rsapksign_ver${RESET} ${BLUE}for${RESET} ${MAGENTA}$arch${RESET}${BLUE}...${RESET}\n"
    if curl -L -o "$rsapksign_file" "$rsapksign_url"; then
        echo -e "${GREEN}Downloaded rsapksign file successfully!${RESET}"
    else
        echo -e "${RED}Could not download rsapksign file...${RESET}\n\n${YELLOW}TIP${RESET}: Make sure you are connected to the internet, then try again!"
        separate
        exit 1
    fi
fi

# Extract the rsapksign binary
echo -e "\n${BLUE}Extracting the rsapksign file...${RESET}"
if tar xzf "$rsapksign_file"; then
    echo -e "${GREEN}rsapksign file extracted successfully!${RESET}"
    separate
else
    echo -e "${RED}Could not extract rsapksign file...${RESET}"
    separate
    exit 1
fi

# Run the rsapksign binary
if ./rsapksign -a "$app" -p "$pack" -o "$out" "$WORKING_APK"; then
    mv "$out" /storage/emulated/0/Download/mcpe/
    rm -rf "$TEMP_STAGE"
    separate
    echo -e "\e[1;32mModified Minecraft APK created successfully in your Download folder, with file name '$out'.${RESET}\n\n${YELLOW}TIP:${RESET}Activate the mcpack in Minecraft to correctly apply the shader!\n\n${GREEN}Installing the APK file...${RESET}"
    sleep 3
    termux-open "/storage/emulated/0/Download/mcpe/$out"
    separate
else
    separate
    rm "$out"
    rm -rf "$TEMP_STAGE"
    echo -e "\e[1;31mModifying apk process failed!\n\n${RED}Error found, stopping modifying apk process...${RESET}"
    separate
    exit 1
fi

# Exit
exit 0
