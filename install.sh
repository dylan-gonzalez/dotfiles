#utility scripts
PLATFORM=`./utils/platform.sh`
HOME_DIR=`wslpath -m ~`
echo $HOME_DIR

create_dir() {
        local target_dir=$1
        if [ ! -e $target_dir ]; then
                #file does not already exist
                echo "mkdir -p $target_dir"
                mkdir -p $target_dir
        fi
}


create_link() {
        local origin_target=$1
        local link_target=$2
        #case $PLATFORM in
        #        "Windows" )
        #                echo "cp -r $origin_target $link_target" #Copy
        #                cp -r $origin_target $link_target
        #                ;;
        #	*)
                        echo "ln -s $origin_target $link_target" #Soft link
                        ln -s $origin_target $home_target
               #         ;;
        #esac
}

yn_prompt() {
	while true; do
		read INPUT
		case "$INPUT" in
			'y' )
				echo 0
				break ;;
			'n' )
				echo 1
				break ;;
			* )
				echo 0 ;;
		esac
	done
}

create_link_prompt() {
	local origin_target=$1
	local link_target=$2

	#Check for file existence
	if [ ! -e $origin_target ]; then
		echo "[Error] $origin_target does not exist"
	elif [ ! -e $link_target ]; then
		#difference=`diff -r ${origin_target%/*} ${link_target%/*}`
		#echo "DIFF: $difference"

		#if [ "$difference" == "" ]; then
		if [ $origin_target == $link_target ]; then
			echo "[Skip] Already exists. No difference between origin and link targets."
		else
			echo "[Ask] Already exists. ($_target)"
			#echo "$difference"
			echo -n "Overwrite? [y/n] "
			ret=`yn_prompt`
			if [ $ret -eq 0 ]; then
				#Backup and create new link
				link_backup="$link_target"_
				if [ -e $link_backup ]; then
					echo "rm -r $link_backup"
					rm -r $link_backup
				fi
				echo "mv $link_target $link_backup"
				mv $link_target $link_backup
				create_link $origin_target $link_target
			fi
		fi
	else
		create_link $origin_target $link_target
	fi

}

if [ $PLATFORM == 'Linux' ]; then
        #echo "* Setting up dotfiles for Linux environment..."
	#files="linux_files"
	files="linux_files"

elif [ $PLATFORM == "Windows" ]; then
	#echo "* Setting up dotfiles for Windows environment..."
	files="windows_files"
fi

#Store IFS separator in a temp var
OIFS=$IFS

# Set IFS separator to a carriage return & new line break
IFS=$'\r\n'



files="linux_files"


echo $HOME_DIR

#origin <--> target
for ((i=0;i<=1;i++)); do
	if [[ i == 1 ]]; then
		files="windows_files"
		$HOME_DIR=${PWD%/*}
		echo "WINDOWSSSS"
	else
		echo "LINUXXXX"
	fi

	links=($(cat "${files}"))

	for line in ${links[*]}; do
		link_dir=$HOME_DIR

		IFS=$' '
		line_array=($line)
		line_len=${#line_array[@]}

		IFS=$'\r\n'

		#if a link directory has been specified (other than $HOME)
		if [[ "$line_len" == 2 ]]; then
			link_dir="${HOME_DIR}/${line_array[1]}"
			echo "creating directory... @ $link_dir"
			create_dir "$link_dir"
		fi

		#create links
		create_link_prompt "dotfiles/${line_array[0]}" "${link_dir}/${line_array[0]}"
	done
done

# Reset IFS separator
IFS=$OIFS
