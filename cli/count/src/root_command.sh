is_all=${args[--all]}
is_file=${args[--file]}
is_dir=${args[--folder]}

if [[ $is_all ]]; then
	c=$(ls -Al | grep -v '^total' | wc -l)
	echo -e "\e[32m Total number of items (including hidden and dotfiles): $c \e[0m"

elif [[ $is_file ]]; then

	c=$(ls -l | grep -v '^total' | grep -v '^d' | wc -l)
	echo -e "\e[32m Total number of files: $c \e[0m"

elif [[ $is_dir ]]; then

	c=$(ls -l | grep '^d' | wc -l)
	echo -e "\e[32m Total number of directories: $c \e[0m"

else

	c=$(ls -l | grep -v '^total' | wc -l)
	echo -e "\e[32m Total Count: $c \e[0m"

fi
