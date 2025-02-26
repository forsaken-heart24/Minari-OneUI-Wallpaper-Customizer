#!/bin/bash

function build_and_sign() {
    local app_path="$2"
    local extracted_dir_path="$1"
    local apkFileName
    if [ -f "$extracted_dir_path/apktool.yml" ]; then 
        apkFileName=$(grep apkFileName $extracted_dir_path/apktool.yml | cut -c 14-1000)
    else 
        abort "Invalid Apkfile path.."
    fi
    rm -rf ${extracted_dir_path}/dist/*
    java -jar ./bin/apktool.jar build --api-level "${BUILD_TARGET_SDK_VERSION}" "${extracted_dir_path}" &>/dev/null
    java -jar ./bin/signer.jar --apk ${extracted_dir_path}/dist/*.apk
    mv ${extracted_dir_path}/dist/$(ls | grep aligned-debugSigned.apk | head -n 1) $app_path/
    rm -rf ${extracted_dir_path}/build ${extracted_dir_path}/dist/
}

function ADD_THE_WALLPAPER_METADATA() {
    local value="$1" type="$2" index="$3"
    type="$(echo "$type" | tr '[:upper:]' '[:lower:]')"
    local filename="wallpaper_${value}.png"
    local path

    case "$type" in
        home)
            isDefault=true
            which=1
            the_homescreen_wallpaper_has_been_set=true
            ;;
        lock)
            isDefault=true
            which=2
            the_lockscreen_wallpaper_has_been_set=true
            ;;
        additionals)
            isDefault=false
            which=1
            ;;
    esac

    cat >> resources_info.json << EOF
    {
        "isDefault": ${isDefault},
        "index": ${index},
        "which": ${which},
        "screen": 0,
        "type": 0,
        "filename": "${filename}",
        "frame_no": -1,
        "cmf_info": [""]
    }${special_symbol}
EOF

    printf " - Enter the path to the default ${type^} wallpaper: "
    read path
    if [ -f "$path" ]; then
        cp -af "$path" "./res/drawable-nodpi/${filename}"
    fi
    clear
}

function main() {
    local wallpaper_count special_symbol special_index=00
    local the_homescreen_wallpaper_has_been_set=false
    local the_lockscreen_wallpaper_has_been_set=false

    printf "\e[1;36m - How many wallpapers do you need to add to the Wallpaper App?\e[0;37m "
    read wallpaper_count
    if ! [[ "$wallpaper_count" =~ ^[0-9]+$ ]]; then
        echo -e "\e[0;31m - Invalid input. Please enter a valid number. Exiting...\e[0;37m"
        return 1
    fi
    clear

    rm -rf resources_info.json
    echo -e "{\n\t\"version\": \"0.0.1\",\n\t\"phone\": [" > resources_info.json

    for ((i = 1; i <= wallpaper_count; i++)); do
        if [ "${i}" -ge "10" ]; then
            special_index=0
        fi
        printf "\e[0;36m - Adding configurations for wallpaper_${special_index}${i}.png.\e[0;37m\n"
        special_symbol=$([[ $i -eq $wallpaper_count ]] && echo "" || echo ",")
        if [[ "$the_lockscreen_wallpaper_has_been_set" == true && "$the_homescreen_wallpaper_has_been_set" == true ]]; then
            ADD_THE_WALLPAPER_METADATA "${special_index}${i}" "additionals" "$i"
        else
            clear
            echo -e "\e[1;36m - What do you want to do with wallpaper_${special_index}${i}.png?\e[0;37m"
            [[ "$the_lockscreen_wallpaper_has_been_set" == false ]] && echo "[1] - Set as default lockscreen wallpaper"
            [[ "$the_homescreen_wallpaper_has_been_set" == false ]] && echo "[2] - Set as default homescreen wallpaper"
            echo "[3] - Include in additional wallpapers"
            printf "\e[1;36mType your choice: \e[0;37m"
            read user_choice

            case "$user_choice" in
                1) 
                    if [ "$the_lockscreen_wallpaper_has_been_set" == "false" ]; then
                        the_lockscreen_wallpaper_has_been_set=true
                        ADD_THE_WALLPAPER_METADATA "${special_index}${i}" "lock" "$i"
                    else
                        ADD_THE_WALLPAPER_METADATA "${special_index}${i}" "additionals" "$i"
                    fi
                    ;;
                2) 
                    if [ "$the_homescreen_wallpaper_has_been_set" == "false" ]; then
                        the_homescreen_wallpaper_has_been_set=true
                        ADD_THE_WALLPAPER_METADATA "${special_index}${i}" "home" "$i"
                    else
                        ADD_THE_WALLPAPER_METADATA "${special_index}${i}" "additionals" "$i"
                    fi
                    ;;
                3) ADD_THE_WALLPAPER_METADATA "${special_index}${i}" "additionals" "$i" ;;
                *) echo -e "\e[0;31m Invalid response! Exiting...\e[0;37m"; exit 1 ;;
            esac
        fi
    done
    echo -e "  ]\n}" >> resources_info.json
    build_and_sign "." "."
}

clear
if ! command -v java; then
    echo -e "\e[1;36m - Please install openjdk or any java toolchain to continue.\e[0;37m"
    sleep 0.5
    exit 1
fi
main
echo -e "\e[0;31m######################################################################"
echo "#                                                                    #"
echo "#       __        ___    ____  _   _ ___ _   _  ____ _               #"
echo "#       \ \      / / \  |  _ \| \ | |_ _| \ | |/ ___| |              #"
echo "#        \ \ /\ / / _ \ | |_) |  \| || ||  \| | |  _| |              #"
echo "#         \ V  V / ___ \|  _ <| |\  || || |\  | |_| |_|              #"
echo "#          \_/\_/_/   \_\_| \_\_| \_|___|_| \_|\____(_)              #"
echo "#                                                                    #"
echo "#                                                                    #"
echo "######################################################################"
echo -e "\e[1;36m- Make sure to remove everything in /system/priv-app/wallpaper-res and copy minari-cust-output.apk to that folder."
echo -e "  The app is built and moved to: $(pwd)/minari-cust-output.apk\e[0;31m"
echo -e "  This script is still in beta stages. Please check \"res/raw/resources_info.json\" if you're concerned about issues.\e[0;37m"