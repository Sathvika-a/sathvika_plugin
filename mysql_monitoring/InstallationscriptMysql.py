import os
import requests
import subprocess
import json
import warnings
import re
import zipfile

warnings.filterwarnings("ignore")

def move_folder(source, destination):
    try:
        os.rename(source, destination)
    except Exception as e:
        print(str(e))
        return False
    return True


def move_plugin(plugin_name, plugins_temp_path, agent_plugin_path):
    try:
        if not check_directory(agent_plugin_path):
            print(f"    {agent_plugin_path} Agent Plugins Directory not Present")
            return False
        if not move_folder(plugins_temp_path+plugin_name, agent_plugin_path+plugin_name): 
            return False

    except Exception as e:
        print(str(e))
        return False
    return True


def plugin_config_setter(plugin_name, plugins_temp_path, arguments):
    try:
        full_path=plugins_temp_path+plugin_name+"/"
        config_file_path=full_path+plugin_name+".cfg"

        arguments='\n'.join(arguments.replace("--","").split())
        with open(config_file_path, "w") as f:
            f.write(f"[mysql]\n"+arguments)

    except Exception as e:
        print(str(e))
        return False
    return True


def plugin_validator(output):
    try:
        result=json.loads(output.decode())
        if "status" in result:
            if result['status']==0:
                print("Plugin execution encountered a error")
                if "msg" in result:
                    print(result['msg'])
            return False

    except Exception as e:
        print(str(e))
        return False
    
    return True



def download_file(url, path):
    filename=url.split("/")[-1]
    response=requests.get(url, stream=True)
    if response.status_code == 200 :
        with open(os.path.join(path,filename), "wb") as f:
            f.write(response.content)
        print(f"      {filename} Downloaded")
    else:
        print(f"      {filename} Download Failed with response code {str(response.status_code)}")
        return False
    return True


def down_move(plugin_name, plugin_url, plugins_temp_path):
    temp_plugin_path=os.path.join(plugins_temp_path,plugin_name+"/")
    if not check_directory(temp_plugin_path):
        if not make_directory(temp_plugin_path):return False

    py_file_url=plugin_url+"/"+plugin_name+".py"
    cfg_file_url=plugin_url+"/"+plugin_name+".cfg"
    pymysql_zip=plugin_url+"/pymysql/pymysql.zip"
    if not download_file(py_file_url, temp_plugin_path):return False
    if not download_file(cfg_file_url, temp_plugin_path):return False
    if not download_file(pymysql_zip, temp_plugin_path):return False
    return True


def execute_command(cmd, need_out=False):
    try:
        print(cmd)
        cmd=cmd.split()
        result=subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        if result.returncode != 0:
            print(f"    {cmd} execution failed with return code {result.returncode}")
            print(f"    {str(result.stderr)}")
            return False
        if need_out:
            return result.stdout
        return True
    except Exception as e:
        print(    str(e))
        return False

def executeQuery_mysql(con, query):
    try:
        cursor = con.cursor()
        cursor.execute(query)
    except Exception as e:
        print(e)
        return False

def create_user(args):
    try:
        import pymysql
        db = pymysql.connect(host=args.hostname,user=args.sys_username,passwd=args.sys_password,port=int(args.port))
        con = db
        query_array = [f"SELECT User FROM mysql.user WHERE User = '{args.new_username}'",f"CREATE USER '{args.new_username}'@'{args.hostname}' IDENTIFIED BY '{args.new_password}'",f"GRANT SELECT ON mysql.* TO '{args.new_username}'@'{args.hostname}' IDENTIFIED BY '{args.new_password}'",f"GRANT SUPER ON *.* TO '{args.new_username}'@'{args.hostname}'",f"FLUSH PRIVILEGES",f"use mysql",f"UPDATE mysql.user SET Super_Priv='Y' WHERE user= '{args.new_username}' AND host='{args.hostname}'",f"FLUSH PRIVILEGES"]
        
        for query in query_array:
            executeQuery_mysql(con,query)
    except Exception as e:
        print(e)
        return False
    return True




def make_directory(path):
    """
    Creates Directories.

    Args:
        path: The path where the directory have to be created

    Returns:
        bool: True/ False
    """
    if not check_directory(path):
        try:
            os.mkdir(path)
            print(f"    {path} directory created.")
        
        except Exception as e:
            print(f"    Unable to create {path} Directory  : {str(e)}")
            return False
    return True


def check_directory(path):
    return os.path.isdir(path)

def initiate(plugin_name, plugin_url, args=None):

    print("------------------------------ Starting Plugin Automation ------------------------------")
    print()


    agent_path="/opt/site24x7/monagent/" 
    agent_temp_path=agent_path+"temp/"
    agent_plugin_path=agent_path+"plugins/"

    # checking the existance of Agent Temporary Directory
    if not check_directory(agent_temp_path):
        print("    Agent Directory does not Exist")
        print("------------------------------ Plugin Automation Failed ------------------------------")
        return
    
    # Creating the Agent Plugin Temporary Directory
    print("    Creating Temporary Plugins Directory")
    plugins_temp_path=os.path.join(agent_temp_path,"plugins/")
    if not check_directory(plugins_temp_path):
        if not make_directory(plugins_temp_path):
            print("")
            print("------------------------------ Plugin Automation Failed ------------------------------")
            return 
    print("    Created Temporary Plugins Directory")
    print()

    # Downloading the files from GitHub
    print("    Downloading Plugin Files")
    if not down_move(plugin_name, plugin_url, plugins_temp_path):
       print("")
       print("------------------------------ Plugin Automation Failed ------------------------------")
       return 
    print("    Downloaded Plugin Files")
    print()

    print("    Unzipping pymysql")
    print("")
    with zipfile.ZipFile(f"{plugins_temp_path}/{plugin_name}/pymysql.zip", 'r') as zip_ref:
        # Extract all the contents of the ZIP file to the specified directory
        zip_ref.extractall(f"{plugins_temp_path}/{plugin_name}/")
    
    print("    Removing pymysql Zip file")
    cmd = f"rm {plugins_temp_path}/{plugin_name}/pymysql.zip"
    if not execute_command(cmd):
        print("")
        print("------------------------------ Plugin Automation Failed ------------------------------")
        return 
    print("    Removed pymysql zip folder")
    print("")

    # Setting Executable Permissions for the Plugin
    print("    Creating executable plugin file")
    cmd=f"chmod 744 {plugins_temp_path}/{plugin_name}/{plugin_name}.py"
    if not execute_command(cmd):
        print("")
        print("------------------------------ Plugin Automation Failed ------------------------------")
        return 
    print("    Created executable plugin file")
    print("")

    # Connecting with mysql and creating user
    if not create_user(args):
        print("")
        print("------------------------------ Plugin Automation Failed ------------------------------")
        return 
    print("    Monitoring user created sucessfully")
    print()

    # Updating pyhton path
    print("   Updating python path in python script")
    cmd="which python3"
    output=subprocess.check_output(cmd, shell=True, text=True)
    file_path=f"{plugins_temp_path}/{plugin_name}/{plugin_name}.py"
    with open(file_path, 'r') as file:
        file_content = file.read()
    updated_content = file_content.replace("#!/usr/bin/python", "#!"+output)
    with open(file_path, 'w') as file:
        file.write(updated_content)

    print('Python path update successfully')

    # Validating the plugin output
    print("    Validating the python plugin output")
    if not args:
        cmd=f"{plugins_temp_path}/{plugin_name}/{plugin_name}.py"
    else:
        cmd=f"{plugins_temp_path}/{plugin_name}/{plugin_name}.py --username={args.new_username} --password={args.new_password} --host={args.hostname} --port={args.port}"

    result=execute_command(cmd, need_out=True)
    if not plugin_validator(result):
        print("")
        print("------------------------------ Plugin Automation Failed ------------------------------")
        return
    print("    Plugin output validated sucessfully")
    print("")


    if args:
        # Setting the plugin config file
        print("    Setting plugin configuration")
        arguments=f"--username={args.new_username} --password={args.new_password} --host={args.hostname} --port={args.port}"
        if not plugin_config_setter(plugin_name, plugins_temp_path, arguments):
            print("")
            print("------------------------------ Plugin Automation Failed ------------------------------")
            return 
        print("    Plugin configuration set sucessfully")
        print()
    

    # Moving the plugin files into the Agent Directory
    print("    Moving the plugin into the Site24x7 Agent directory")
    if not move_plugin(plugin_name, plugins_temp_path, agent_plugin_path):
        print("")
        print("------------------------------ Plugin Automation Failed ------------------------------")
        return 
    print("    Moved the plugin into the Site24x7 Agent directory")
    print()

    print("------------------------------ Sucessfully Completed Plugin Automation ------------------------------")


if __name__ == "__main__":
    plugin_name="mysql_monitoring"
    plugin_url="https://raw.githubusercontent.com/site24x7/plugins/master/mysql_monitoring/"

    import argparse
    parser=argparse.ArgumentParser()
    parser.add_argument('--sys_username', help='admin username for mysql',default="root")
    parser.add_argument('--sys_password', help='admin password for mysql',default="")
    parser.add_argument('--hostname', help='hostname for mysql',default="localhost")
    parser.add_argument('--new_username', help='new username for mysql',default="user1")
    parser.add_argument('--new_password', help='new password for mysql',default="user1")
    parser.add_argument('--port', help='port number for mysql',default=3306)

    args=parser.parse_args()

    initiate(plugin_name, plugin_url, args)