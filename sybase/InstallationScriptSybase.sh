#!/bin/bash

plugin_name="sybase"
plugin_url="https://raw.githubusercontent.com/site24x7/plugins/suraj/"

echo "------------------------------ Starting Plugin Automation ------------------------------"
echo
    
agent_path="/opt/site24x7/monagent/" 
agent_temp_path=$agent_path"temp/"
agent_plugin_path=$agent_path"plugins/"
    
# checking the existence of Agent Temporary Directory
if [ ! -d $agent_temp_path ] ; then
    echo "The Site24x7LinuxAgent directory is not present. Install the Site24x7LinuxAgent and try installing the plugin again."
    echo "----------------------------- Process exited------------------------------"
    return 0
        
fi


install_plugin(){
    echo "------------------------------ Starting Plugin Automation ------------------------------"
    echo
        
    # Creating the Agent Plugin Temporary Directory
    echo "    Creating Temporary Plugins Directory"
    
    plugins_temp_path=$agent_temp_path"plugins/"
    if [ ! -d $plugins_temp_path ] ; then
        mkdir $plugins_temp_path
        if [ ! -d $plugins_temp_path ] ; then
            echo "$plugins_temp_path directory does not exists."
            echo
            return 0
        fi
    fi
    echo "Temporary plugin path exist"
    
    # Downloading the files from GitHub
    is_down=$(download_files $plugin_name $plugin_url $plugins_temp_path)
    
    echo $is_down
    
    echo "    Downloaded Plugin Files"
    echo 
    
    echo "   Configuring sybase.sh"
    java_path=$(which java)
    java_path=$(echo $java_path | awk '{print substr($0, 1, length($0)-5)}')
    if [ $java_path ] ; then
        echo "Java path available"
    else
        echo "Java path not available"
        return 0
    fi
    
    which javac
    if [ $? -eq 0 ] ; then
        echo "Java compiler is available"
    else
        echo "Java compiler is not available"
        return 0
    fi

    i=1
    while [ $i -le 3 ]
    do
        if [ $i = 3 ];then
            echo "Without hostname Sybase can't be monitored"
            return 0
        fi 
        echo "Enter the hostname :"
        read hostname
        if [ ${#hostname} -ne 0  ];then
            break;
        fi
        i=$(($i+1))
    done

    while [ $i -le 3 ]
    do
        if [ $i = 3 ];then
            echo "Without port Sybase can't be monitored"
            return 0
        fi 
        echo "Enter the port :"
        read port
        if [ ${#port} -ne 0  ];then
            break;
        fi
        i=$(($i+1))
    done

    while [ $i -le 3 ]
    do
        if [ $i = 3 ];then
            echo "Without username Sybase can't be monitored"
            return 0
        fi 
        echo "Enter the username :"
        read username
        if [ ${#username} -ne 0  ];then
            break;
        fi
        i=$(($i+1))
    done

    while [ $i -le 3 ]
    do
        if [ $i = 3 ];then
            echo "Without password Sybase can't be monitored"
            return 0
        fi 
        echo "Enter the password :"
        read password
        if [ ${#password} -ne 0  ];then
            break;
        fi
        i=$(($i+1))
    done
    
    plugin_dir_name="sybase/sybase.sh"
    sybase_temp_path=$plugins_temp_path$plugin_dir_name
    
    replace_string_in_file $sybase_temp_path 'HOST=""' 'HOST="'$hostname'"'
    replace_string_in_file $sybase_temp_path 'PORT=""' 'PORT="'$port'"'
    replace_string_in_file $sybase_temp_path 'USERNAME=""' 'USERNAME="'$username'"'
    replace_string_in_file $sybase_temp_path 'PASSWORD=""' 'PASSWORD="'$password'"'
    replace_string_in_file $sybase_temp_path 'JAVA_HOME="/usr/bin"' 'JAVA_HOME="'$java_path'"'
    replace_string_in_file $sybase_temp_path 'PLUGIN_PATH=""' 'PLUGIN_PATH="/opt/site24x7/monagent/temp/plugins/sybase"'
    
    
    
    # Setting Executable Permissions for the Plugin
    echo "    Creating executable plugin file"
    cmd="chmod 744 ${plugins_temp_path}/${plugin_name}/${plugin_name}.sh"
    eval "$cmd"
    
    if [ $? -ne 0 ] ; then
        return 0
    fi
    
    # Validating the plugin output
    echo "Validating the plugin output"
    file=".sh"
    sh $plugins_temp_path$plugin_name/$plugin_name$file
    if [ $? -ne 0 ] ; then
        echo "Error Occured when executing plugin file"
        return 0
    else
        echo "Plugin executed successfully"
        replace_string_in_file $sybase_temp_path 'PLUGIN_PATH="/opt/site24x7/monagent/temp/plugins/sybase"' 'PLUGIN_PATH="/opt/site24x7/monagent/plugins/sybase"'
    fi
    
    echo "Moving the plugin into the Site24x7 Agent directory"
    
    mv $plugins_temp_path$plugin_name $agent_plugin_path$plugin_name
    if [ $? -ne 0 ] ; then
        echo "Error Occured when moving plugin directory"
        return 0
    else
        echo "Plugin Automation completed successfully"
        echo
    fi
}     
    


replace_string_in_file(){

    #sed -i "s/$2/$3/g" "$1"
    sed -i "s|$2|$3|g" "$1"
    return 1
}

download_files(){
    temp_plugin_path=$3$1
    if [ ! -d $temp_plugin_path ] ; then
        mkdir "$temp_plugin_path"
        if [ ! -d $temp_plugin_path ] ; then
            echo "Error in Creating plugin directory"
            return 0
        fi
    fi
    java_file_url=$2$1/$1.java
    sh_file_url=$2$1/$1.sh
    jar1_file_url=$2$1/jconn4.jar
    jar2_file_url=$2$1/json-20140107.jar
    
    wget -O "$temp_plugin_path/sybase.java" "$java_file_url"
    if [ $? -eq 0 ]; then
        echo "Java File downloaded successfully."
    else
        echo "Error downloading the JAVA file. Please check the URL or path."
        result=0
        echo $result
        return
    fi
    
    wget -O "$temp_plugin_path/sybase.sh" "$sh_file_url"
    if [ $? -eq 0 ]; then
        echo "sh File downloaded successfully."
    else
        echo "Error downloading the sh file. Please check the URL or path."
        return 0
    fi
    
    wget -O "$temp_plugin_path/jconn4.jar" "$jar1_file_url"
    if [ $? -eq 0 ]; then
        echo "jconn4 jar downloaded successfully."
    else
        echo "Error downloading the jconn4 jar. Please check the URL or path."
        return 0
    fi
    
    wget -O "$temp_plugin_path/json-20140107.jar" "$jar2_file_url"
    if [ $? -eq 0 ]; then
        echo "json jar downloaded successfully."
    else
        echo "Error downloading the json jar. Please check the URL or path."
        return 0
    fi
    
    return 1
}

install_plugin
