#!/bin/bash
# The script that creates users from .txt doc with spec params
echo "---Script for creating users---"
echo -e "\n\n"
echo "Text document which contains users should be placed in directory src"
echo -e "\n"
read -p "Enter name of the file which contains users with params: " FILE_USERS

USERS_PATH="./src/$FILE_USERS"

if [[ -f $USERS_PATH ]]; then 
	IFS=$'\n'
	touch log.txt
	for LINE in `cat $USERS_PATH`
	do

		username=`echo "$LINE" | cut -d ":" -f1`
		user_group=`echo "$LINE" | cut -d ":" -f2`
		user_shell=`echo "$LINE" | cut -d ":" -f4`
		user_password=`echo "$LINE" | cut -d ":" -f3`
		ssl_password=`openssl passwd -1 "$user_password"`
		user_shell=`echo "$LINE" | cut -d ":" -f4`
		exist_group=`id -gn $username`
		add_del_user=`echo "$LINE" | cut -d ":" -f1`

		read -p "Do you want to create or delete user $username? Press 1 to create, 2 to delete: " FIRST_ANS
			case $FIRST_ANS in
				[1])
					
					echo -e "Newly Added users were:" > log.txt
					if ! grep -q $username "/etc/passwd"; then
						echo -e "$username was not found in the system!"
						read -p "Do you want to create a new user $username? [y/n] " ANS_NEW
						case $ANS_NEW in
							[yY]|[yY][eE][sS])
								if [[ `grep $user_group "/etc/group"` ]]; then
									echo "Group $user_group already exists in the system!"
									useradd $username -s $user_shell -m -g $user_group -p $ssl_password
								else	
									echo -e "Group $user_group doesn't exists in the system!\n It will be created!"
									groupadd $user_group
									useradd $username -s $user_shell -m -g $user_group -p $ssl_password
								fi
							echo -e "User $username was created!\n"
							echo "$username: group - $user_group; password - $user_password; shell - $user_shell" >> log.txt
							;;
							[Nn]|[nN][Oo])
								echo -e "The creation of user $username will be skipped!\n"
								;;
							*)
								echo -e "Please enter [y/n] only!\n"
								;;
						esac
					elif [[ `grep $username "/etc/passwd"` ]]; then
						echo -e "$username was found in system!"
						read -p "Do you want to make some changes for $username? [y/n]: " ANS_CHANGES
						case $ANS_CHANGES in 
							[Yy]|[Yy][Ee][Ss])
								if [[ "$exist_group" == "$user_group" ]]; then
									echo "$username already exists in group $user_group";
								else
									read -p "Do you want to change $exist_group on $user_group?" ANS_GROUP
									case $ANS_GROUP in
										[Yy]|[Yy][Ee][Ss])
											echo -e "Group $user_group for $username was added!\n";
											usermod -g $user_group $username;;
										[Nn]|[Nn][Oo])
											echo -e "Group $exist_group was not changed!\n";;
										*)
											echo -e "Please enter correct values! [y/n]: \n";;
									esac

								fi

								exist_shell=`grep "$username" /etc/passwd | cut -d ":" -f7`

								if [[ $exist_shell == $user_shell ]]; then
									echo "$username already have shell $user_shell"
				
								else
									read -p "Do you want to change shell? ($user_shell)? [y/n]: \n" ANS_SHELL
									case $ANS_SHELL in
										[Yy]|[Yy][Ee][Ss])
											usermod -s $user_shell $username
											echo -e "Shell for user $username was changed!\n";;
										[Nn]|[Nn][Oo])
											echo -e "Shell wasn't changed!\n";;
										*)
											echo -e "Please enter correct values! [y/n]: ";;
									esac
								fi

									read -p "Do you want to change password for user $username?" ANS_PASS
									
									case $ANS_PASS in
										[Yy]|[Yy][Ee][Ss])
											usermod -p $ssl_password $username
											echo -e "Password for user $username was changed!\n";;
										[Nn]|[Nn][Oo])
											echo -e "Password wasn't changed!\n";;
										*)
											echo -e "Please enter correct values! [y/n]: \n";;
									esac
								;;

							[Nn]|[Nn][Oo])
								echo -e "Changes of user $username will be skipped!";;
							*)
								echo -e "Please enter [yes/no] only!";;
						esac

					fi
					;;
				[2])
					echo -e "Changed users were:" >> log.txt
					if grep -q $username "/etc/passwd"; then
						userdel -r $username
						echo "$username: was deleted from system" >> log.txt
					fi
					;;
				*)
					echo -e "Please enter correct values! [y/n]: \n";;
			esac
	done
	cat log.txt
else
	echo "$FILE_USERS doesn't exist"
	echo "You need to create a new file?"
fi

