function ADD_THE_WALLPAPER_METADATA() {
    local value="$1"
    local the_type_of_wallpaper="$2"
    the_type_of_wallpaper="$(echo "${the_type_of_wallpaper}" | tr '[:upper:]' '[:lower:]')"
    
    cat >> resources_info.json << EOF
    {
EOF

    case "$the_type_of_wallpaper" in
        home)
            cat >> resources_info.json << EOF
        "isDefault": ${the_homescreen_wallpaper_has_been_set},
        "index": ${value},
        "which": 1,
        "screen": 0,
        "type": 0,
        "filename": "wallpaper_${value}.png",
        "frame_no": -1,
        "cmf_info": [""]
    }${special_symbol}
EOF
        ;;
        
        lock)
            cat >> resources_info.json << EOF
        "isDefault": ${the_lockscreen_wallpaper_has_been_set},
        "index": ${value},
        "which": 2,
        "screen": 0,
        "type": 0,
        "filename": "wallpaper_${value}.png",
        "frame_no": -1,
        "cmf_info": [""]
    }${special_symbol}
EOF
        ;;
        
        additionals)
            cat >> resources_info.json << EOF
        "isDefault": false,
        "index": ${value},
        "which": 1,
        "screen": 0,
        "type": 0,
        "filename": "wallpaper_${value}.png",
        "frame_no": -1,
        "cmf_info": [""]
    }${special_symbol}
EOF
        ;;
    esac
}

function json_header() {
    cat >> resources_info.json << EOF
{
  "version": "0.0.1",
  "phone": [
EOF
}

function json_ending_stuffs() {
    cat >> resources_info.json << EOF
  ]
}
EOF
}

function main () {
    # wallpapers configuration
    local i
    local wallpaper_count
    local special_symbol
    local the_homescreen_wallpaper_has_been_set=false
    local the_lockscreen_wallpaper_has_been_set=false
    local wallpaper_count_additional_int=00
    local continue_the_thing=true
    
    # the main stuff starts from here!
    printf "\e[1;36m - How many wallpapers do you need to add to the FLOSSPaper App?\e[0;37m "
    read wallpaper_count

    # failsafe, let's avoid null values..
    if [ -z "$wallpaper_count" ]; then
        continue_the_thing=false
        echo ""
        echo -e "\e[0;31m - Failed to fetch some information. Exiting...\e[0;37m"
    fi

    if $continue_the_thing; then
        # removing the json file to start fresh
        rm -rf resources_info.json
        touch resources_info.json
        json_header
        echo -e " - Adding requested number of wallpapers to the list..\n"
        
        for ((i=1; i<=wallpaper_count; i++)); do
            # Handle wallpaper count formatting
            if [ "${wallpaper_count}" -ge 10 ]; then
                wallpaper_count_additional_int=0
            fi

            echo -e "\e[0;36m - Adding configurations for wallpaper_${wallpaper_count_additional_int}${i}.png."
            
            # Add or remove the comma for JSON
            if [ "${wallpaper_count}" -eq "${i}" ]; then
                special_symbol=""
            else
                special_symbol=","
            fi
			
            # Switch between default wallpapers
			echo -e "\e[1;36m - What do you want to do with wallpaper_${wallpaper_count_additional_int}${i}.png wallpaper file?\e[0;37m "
			if ! $the_lockscreen_wallpaper_has_been_set; then echo "[1] - Set this as the default lockscreen wallpaper.."; fi
			if ! $the_homescreen_wallpaper_has_been_set; then echo "[2] - Set this as the default homescreen wallpaper.."; fi
			echo "[3] - Include this into the wallpaper lists.."
			printf "\e[1;36mType your answer here \e[0;37m- "
			read hell_nah
			if [ "$hell_nah" == "1" ]; then
				if [ "$the_lockscreen_wallpaper_has_been_set" == "true" ]; then
					ADD_THE_WALLPAPER_METADATA "${wallpaper_count_additional_int}${i}" "additionals"
				elif [ "$the_lockscreen_wallpaper_has_been_set" == "false" ]; then
					the_lockscreen_wallpaper_has_been_set=true
					ADD_THE_WALLPAPER_METADATA "${wallpaper_count_additional_int}${i}" "lock"
				fi
			elif [ "$hell_nah" == "2" ]; then
				if [ "$the_homescreen_wallpaper_has_been_set" == "true" ]; then
					ADD_THE_WALLPAPER_METADATA "${wallpaper_count_additional_int}${i}" "additionals"
				elif [ "$the_homescreen_wallpaper_has_been_set" == "false" ]; then
					the_homescreen_wallpaper_has_been_set=true
					ADD_THE_WALLPAPER_METADATA "${wallpaper_count_additional_int}${i}" "home"
				fi
			elif [ "$hell_nah" == "3" ]; then
				ADD_THE_WALLPAPER_METADATA "${wallpaper_count_additional_int}${i}" "additionals"
			else
				echo -e "\e[0;31m Invalid response!"
				sleep 2
				exit 1
			fi
            
            echo -e "\e[0;36m - Finished adding configurations for wallpaper_${i}.png..\e[0;37m"
            echo ""
        done
        
        json_ending_stuffs
        if ! $the_homescreen_wallpaper_has_been_set; then
            echo -e "\e[0;31m - Warning! The default homescreen wallpaper was not included in the lists.\e[0;37m"
        elif ! $the_lockscreen_wallpaper_has_been_set; then
            echo -e "\e[0;31m - Warning! The default lockscreen wallpaper was not included in the lists.\e[0;37m"
        fi
    fi

    # Final message and move the JSON file
    echo -e "\e[0;31m"
    echo "######################################################################"
    echo "#                                                                    #"
    echo "#       __        ___    ____  _   _ ___ _   _  ____ _               #"
    echo "#       \ \      / / \  |  _ \| \ | |_ _| \ | |/ ___| |              #"
    echo "#        \ \ /\ / / _ \ | |_) |  \| || ||  \| | |  _| |              #"
    echo "#         \ V  V / ___ \|  _ <| |\  || || |\  | |_| |_|              #"
    echo "#          \_/\_/_/   \_\_| \_\_| \_|___|_| \_|\____(_)              #"
    echo "#                                                                    #"
    echo "#                                                                    #"
    echo "######################################################################"
    echo -e "\e[1;36m"
    echo -e "  Be sure to move the images to the drawable-nodpi/ folder with their appropriate names."
    echo -e "\e[0;31m  This script is still in beta stages."
	echo -e "The file is now at $(pwd)"
    echo -e "  Thanks for your time!\e[0;37m"
}