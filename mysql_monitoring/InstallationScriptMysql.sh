#!/bin/bash

echo "Mysql Monitoring plugin Installation"
echo

echo "Get the Python version"
python_version=$(python3 --version 2>&1)
# Extracting the major and minor version numbers from the Python version string
major_version=$(echo $python_version | cut -d ' ' -f 2 | cut -d '.' -f 1)
minor_version=$(echo $python_version | cut -d ' ' -f 2 | cut -d '.' -f 2)
if [ "$major_version" -eq 3 ] && [ $minor_version -ge 7 ] || [ $major_version -gt 3 ]; then
    echo "Require pyhton version available"
    echo ""
else
    echo "To monitor the MYSQL you need Python3 "
    echo
    echo "Update apt to install python3 "
    echo "update apt (Y/N) : "
    read cx_inp
    if [ "$cx_inp" = "Y" ] || [ "$cx_inp" = "y" ]; then
    	echo "Updating apt"
    	apt update
    	if [ $? -eq 0 ]; then
    		echo "apt updated successfully."
    		echo
    		echo "Install python3 (Y/N)"
    		read cx_inp1
    		if [ "$cx_inp1" = "Y" ] || [ "$cx_inp1" = "y" ]; then
    			echo "Installing python3"
    			apt-get install python3
    			if [ $? -eq 0 ]; then
    				echo "Pyhton3 installed successfully."
				else
    				echo "Python3 installation failed."
    				echo "Ending the installation"
    				return 0
				fi

			elif [ "$cx_inp1" = "N" ] || [ "$cx_inp1" = "n" ]; then
    			echo "Without python3 can't monitor mysql."
    			echo
    			echo "Ending the installation"
    			return 0
			else
    			echo "Kindly give the correct input."
    			return 0
			fi

		else
    		echo "apt updation failed."
    		echo "Ending the installation"
    		return 0
		fi

	elif [ "$cx_inp" = "N" ] || [ "$cx_inp" = "n" ]; then
    	echo "Without updating apt can't install python."
    	echo
    	echo "Ending the installation"
    	return 0
	else
    	echo "Kindly give the correct input."
    	return 0
	fi
fi

echo "To create monitor user and to monitor mysql, we need Hostname , port , admin username and password. To craete monitoring user with reading privileges give the new username and password"
echo "Enter the hostname : "
read hostname
echo
echo "Enter the port : "
read port
echo
echo "Enter admin username : "
read sys_username
echo
echo "Enter admin password : "
read sys_password
echo
echo "New username and password will be created as monitoring user to monitor mysql"
echo "Create new monitoring user (Y/N) : "
read cx_inp
if [ "$cx_inp" = "Y" ] || [ "$cx_inp" = "y" ]; then
    echo "Creating monitor user"
    echo 
    echo "Enter New username : "
    read new_username
    echo
    echo "Enter new password : "
    read new_password
    echo
    wget https://raw.githubusercontent.com/site24x7/plugins/master/mysql_monitoring/InstallationScriptMysql.py
    script_path=$(pwd)
    if [ $? -eq 0 ]; then
        echo "Installation script downloaded successfully."
        echo 
        echo "Installing pymysql zip"
        wget https://github.com/site24x7/plugins/raw/master/mysql_monitoring/pymysql/pymysql.zip && unzip $script_path/pymysql.zip && rm $script_path/pymysql.zip
        if [ $? -eq 0 ]; then
            echo "Pymysql downloaded successfully"
            python3 $script_path/InstallationScriptMysql.py --hostname=$hostname --port=$port --sys_username=$sys_username --sys_password=$sys_password --new_username=$new_username --new_password=$new_password 
        else
            echo
            echo "Error in downloading pymysql"
            echo
            return 0
        fi
    else
        echo "Error in downloading ionstallation script"
        return 0
    fi

elif [ "$cx_inp" = "N" ] || [ "$cx_inp" = "n" ]; then
    echo "Without creating monitor user can't monitor mysql."
    echo
    echo "Ending the installation"
    return 0
else
    echo "Kindly give the correct input."
    return 0
fi