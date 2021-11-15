echo `uname -s`

if [[ -n "$IS_WSL" || -n "$WSL_DISTRO_NAME" ]]; then
    echo "Windows"
else
    echo "Linux"
fi

if [[ `uname -r` == "Microsoft" ]]; then
	echo "Linux"
else
	echo "Windows"
fi
