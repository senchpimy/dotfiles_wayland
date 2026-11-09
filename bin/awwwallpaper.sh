#!/usr/bin/env sh
#set -e


#// lock instance

lockFile="/tmp/hyde$(id -u)$(basename ${0}).lock"
[ -e "${lockFile}" ] && echo "An instance of the script is already running..." && exit 1
touch "${lockFile}"
trap 'rm -f ${lockFile}' EXIT

echo ":: awwwallpaper.sh ::"

#// define functions

Wall_Cache()
{
    local wallPath="${wallList[setIndex]}"
    local wallHashName=$(set_hash "${wallPath}")

    ln -fs "${wallPath}" "${wallSet}"
    ln -fs "${wallPath}" "${wallCur}"
    "${scrDir}/awwwallcache.sh" -w "${wallPath}" &> /dev/null
    "${scrDir}/awwwallbash.sh" "${wallPath}"

    ln -fs "${thmbDir}/${wallHashName}.sqre" "${wallSqr}"
    ln -fs "${thmbDir}/${wallHashName}.thmb" "${wallTmb}"
    ln -fs "${thmbDir}/${wallHashName}.blur" "${wallBlr}"
    ln -fs "${thmbDir}/${wallHashName}.quad" "${wallQad}"
    ln -fs "${dcolDir}/${wallHashName}.dcol" "${wallDcl}"
}

Wall_Change()
{
    curWall="$(set_hash "${wallSet}")"
    for i in "${!wallHash[@]}" ; do
        if [ "${curWall}" == "${wallHash[i]}" ] ; then
            if [ "${1}" == "n" ] ; then
                setIndex=$(( (i + 1) % ${#wallList[@]} ))
            elif [ "${1}" == "p" ] ; then
                setIndex=$(( i - 1 ))
            fi
            break
        fi
    done
    Wall_Cache
}


#// set variables
echo "${cacheDir}"

scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"
wallSet="${hydeThemeDir}/wall.set"
wallCur="${cacheDir}/wall.set"
wallSqr="${cacheDir}/wall.sqre"
wallTmb="${cacheDir}/wall.thmb"
wallBlr="${cacheDir}/wall.blur"
wallQad="${cacheDir}/wall.quad"
wallDcl="${cacheDir}/wall.dcol"


#// check wall

setIndex=0
[ ! -d "${hydeThemeDir}" ] && echo "ERROR: \"${hydeThemeDir}\" does not exist" && exit 0
wallPathArray=("${hydeThemeDir}")
wallPathArray+=("${wallAddCustomPath[@]}")
get_hashmap "${wallPathArray[@]}"
[ ! -e "$(readlink -f "${wallSet}")" ] && echo "fixig link :: ${wallSet}" && ln -fs "${wallList[setIndex]}" "${wallSet}"


#// evaluate options

while getopts "nps:" option ; do
    case $option in
    n ) # set next wallpaper
        xtrans="grow"
        Wall_Change n
        ;;
    p ) # set previous wallpaper
        xtrans="outer"
        Wall_Change p
        ;;
    s ) # set input wallpaper
        if [ ! -z "${OPTARG}" ] && [ -f "${OPTARG}" ] ; then
            get_hashmap "${OPTARG}"
        fi
        Wall_Cache
        ;;
    * ) # invalid option
        echo "... invalid option ..."
        echo "$(basename "${0}") -[option]"
        echo "n : set next wall"
        echo "p : set previous wall"
        echo "s : set input wallpaper"
        exit 1 ;;
    esac
done


#// check awww daemon

#~/.local/bin/awww query &> /dev/null
awww query &> /dev/null
if [ $? -ne 0 ] ; then
    awww-daemon --format xrgb &
fi


#// set defaults

[ -z "${xtrans}" ] && xtrans="grow"
[ -z "${wallFramerate}" ] && wallFramerate=60
[ -z "${wallTransDuration}" ] && wallTransDuration=0.4


#// apply wallpaper

echo ":: applying wall :: \"$(readlink -f "${wallSet}")\""
#wal -i "$(readlink -f "${wallSet}")"
#sh ~/.config/ags/scripts/color_generation/colorgen.sh "$(readlink -f "${wallSet}")" --apply --smart &
awww img "$(readlink "${wallSet}")" --transition-bezier .43,1.19,1,.4 --transition-type "${xtrans}" --transition-duration "${wallTransDuration}" --transition-fps "${wallFramerate}" --invert-y --transition-pos "$(hyprctl cursorpos)" &
imagePath="$(readlink -f "${wallSet}")"

if [ -f "${wallDcl}" ] ; then
    source "${wallDcl}"
fi
[ -z "${dcol_mode}" ] && dcol_mode="dark"

rm -f ~/.config/gtk-3.0/gtk.css ~/.config/gtk-4.0/gtk.css
matugen image "${imagePath}" --source-color-index 0 --mode "${dcol_mode}" --continue-on-error
#wal -i "${imagePath}"
xrdb -load ~/.Xdefaults
