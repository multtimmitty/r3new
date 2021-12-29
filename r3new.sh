#!/bin/bash

export IFS='
'
# COLORS #
red="\e[01;31m"; green="\e[01;32m"; yellow="\e[01;33m"
blue="\e[01;34m"; purple="\e[01;35m"; cyan="\e[01;36m"
end="\e[00m"
# CUSTOM VARIABLES #
NBOX="${blue}⟦${cyan}*${blue}⟧${end}"
GBOX="${blue}⟦${green}+${blue}⟧${end}"
RBOX="${blue}⟦${red}-${blue}⟧${end}"

# FINISH AND CANCEL FUNCTION #
CTRL_C(){
  echo -e "\n${blue}>>> ${red}Process Canceled ${blue}<<<${end}"
  tput cnorm
  exit 0
}
FINISHED(){
  echo -e "${blue}>>> ${red}Finished Process ${blue}<<<${end}"
  tput cnorm
  exit 0
}
trap CTRL_C INT
trap FINISHED SIGTERM

# HELP MENU #
HELP_MENU(){
  echo -e "${blue}Arguments:${end}"
  echo -e "${purple}-d \tSpecify a Directory${end}"
  echo -e "${purple}-n \tNew Name for files${end}"
  echo -e "${purple}-h \tShow the Help Menu${end}"
  echo -e "${cyan}use: ./renew.sh -d <Path_Directory>${end}"
}

# RANAME FUNCTION #
RENAME(){
  local path="${1}"
  local news="${2}"
  local extensions=(jpeg jpg png gif mp4 mkv mov avi flv wmv)
  declare -i local count=1
  sleep 1; clear
  #check if the last char is a slash
  if [[ ${path: -1} == '/' ]]; then
    local path="${path%?}"
  fi
  #list the extensions
  for listExt in ${extensions[@]}; do
     #search the files for extension and list the files
     findExt=$(find ${path} -maxdepth 1 -type f -iname "*.${listExt}" 2>/dev/null)
     for listFiles in ${findExt}; do
       echo -e "${cyan}Renaming ${blue}:> ${end}${listFiles} ${green}to ${blue}:> ${end}${path}/${news}_$(printf "%02d" ${count}).${listExt,,}${end}\c "; sleep 0.2
        #rename to the files
        `mv "${listFiles}" "${path}/${news}_$(printf "%02d" ${count}).${listExt,,}"`
        #check that it was renamed correctly
        if [[ $? -eq 0 ]]; then
          echo -e "${green} done ${end}"
        else
          echo -e "${red} failed ${end}"; sleep 0.4
          echo -e "${red}Occurred Error to Rename of the File.${end}"
          FINISHED
        fi
        let count+=1
     done
  done
  echo -e "${green}Process Finished ${yellow}${count} ${green}Files Were Renamed Successfully...!${end}"
}

# MAIN FUNCTION #
if [[ $# -eq 4 ]]; then
  declare -i count=0
  while getopts ":d:n:h:" arg; do
       case $arg in
          d ) pathDirectory=$OPTARG; let count+=1;;
          n ) newName=$OPTARG; let count+=1;;
          h ) HELP_MENU;;
       esac
  done
  #check the value of the parameter
  if [[ $count -eq 2 ]]; then
    tput civis
    #check if exist the directory
    echo -e "${NBOX} ${yellow}Checking Directory.......${end}\c"; sleep 1
    if [[ -d ${pathDirectory} ]]; then
      echo -e "${green} done ${end}"
      echo -e "${NBOX} ${yellow}Checking the Content.......${end}\c"; sleep 1
      #check the directory content
      content=$(ls ${pathDirectory}/*.* 2>/dev/null | wc -l)
      if [[ ${content} -ne 0 ]]; then
        echo -e "${green} done ${end}"
        RENAME $pathDirectory $newName
      else
        echo -e "${red} failed ${end}"
        echo -e "${red}The Directory is Empty${end}"
        FINISHED
      fi
    else
      echo -e "${red} failed ${end}"
      echo -e "${red}The Directory is NOT Exist${end}"
      FINISHED
    fi
    tput cnorm
  else
    HELP_MENU
  fi
else
  HELP_MENU
fi
