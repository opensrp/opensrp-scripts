#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLACK='\033[0;30m'
YELLOW='\033[0;33m'
NO_COLOR='\033[0m' 

echo_black() {
    echo -e "${BLACK}${1}${NO_COLOR}"
}

echo_red() {
    echo -e "${RED}${1}${NO_COLOR}"
}

echo_green() {
    echo -e "${GREEN}${1}${NO_COLOR}"
}

echo_yellow() {
    echo -e "${YELLOW}${1}${NO_COLOR}"
}

if [ $# -lt 2 ]; then
    echo_red "Error: Please specify a github token and keystore file path"
    exit 1
fi

while getopts t:f: opt; do
	case $opt in
		t)
			github_token=$OPTARG
			;;
		f)
			file_path=$OPTARG
			;;
    esac
done

echo_yellow "Logging you in..."
travis login --org --github-token $github_token
echo_yellow "Signing your keystore..."
travis encrypt-file $file_path --add



