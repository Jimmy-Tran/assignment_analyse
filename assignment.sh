#!/usr/bin/env bash

# Define global variable here

# Created by
# Jimmy - 1052827
# Joel - 1062069

# TODO: Add required and additional packagenas dependecies 
# for your implementation
declare -a packages=("https://github.com/nickjj/webserver.git" "https://github.com/bartobri/no-more-secrets.git")

# TODO: define a function to handle errors
# This funtion accepts two parameters one as the error message and one as the command to be excecuted when error occurs.
function handle_error() {
    # Do not remove next line!
    echo "function handle_error"

    #print error message
    echo "Error: $1"

    #command execute
    if [ -n "$2" ]; then
        echo "Executing command: $2"
        eval "$2"
    fi

}
# Function to solve dependencies
function setup() {
    # Do not remove next line!
    echo "function setup"

    # TODO check if nessassary dependecies and folder structure exists and
    # print the outcome for each checking step

    # TODO installation from online package requires values for
    # package_name package_url install_dir3

    # TODO check if required dependency is not already installed otherwise install it
    # if a a problem occur during the this process
    # use the function handle_error() to print a messgage and handle the error
      echo ""
      echo "Checking dependencies"
      echo "WGET, CURL, UNZIP"
      echo ""
    # Array / list of packages that has to be installed
    packages=("wget" "unzip" "curl")
    # for loop for each package in the list
    for p in "${packages[@]}"; do
      # Check if the package is installed using the package name as command.
      if ! command -v "$p" > /dev/null 2>&1; then
        echo ""
        echo "Installing the package"
        echo "$p"
        echo ""
        # Install the package using apt-get -y is for auto yes. If the installation fails handle_error will be called. else it will show success message.
        sudo apt-get install -y "$p" && echo "$p successfully installed" || handle_error "Failed to install $p"
      else
        echo ""
        echo "The following package is already installed"
        echo "$p"
        echo ""
      fi
    done

  echo ""
  echo "Checking for directory"
  echo "/apps"
  echo ""
  # Check if the directory exists -d is for directory
    if [ -d ./apps ]; then
          echo ""
          echo "Found directory"
          echo "/apps"
          echo ""
          # if directory is not found create it
      else
          echo ""
          echo "Directory missing"
          echo "creating /apps"
          echo ""
            # Create the directory using mkdir -p is for creating parent directories if they don't exist
            if mkdir -p ./apps; then
              echo ""
              echo "Directory created"
              echo "/apps"
              echo ""
            else
              # if directory creation fails handle_error will be called
              handle_error "Failed to create directory /apps"
            fi
    fi
        # Check if the dev.conf file exists -f is for file
        if [ -f dev.conf ]; then
              echo ""
              echo "Found "
              echo "dev config"
              echo ""
          else
            # if dev.conf is not found create it
              echo ""
              echo "Dev config missing"
              echo "creating dev.conf"
              echo ""
              # Creating the dev.conf file using touch
                if touch dev.conf; then
                  echo ""
                  echo "Config file created"
                  echo "dev.conf"
                  echo ""
                else
                  # if dev.conf creation fails handle_error will be called
                  handle_error "Failed to create directory dev.conf"
                fi
        fi

          echo "Finished! setup successfully"
}

# Function to install a package from a URL
# TODO assign the required parameter needed for the logic
# complete the implementation of the following function.

function install_package() {
    # Do not remove next line!
    echo "function install_package"

    # local variables for the function
    local package_name="$1"
    local package_url="$2"
    local install_dir="./apps/$package_name"

    # check if the package name or package url is empty
    if [ -z "$package_name" ] || [ -z "$package_url" ]; then
      # if package name or package url is empty handle_error will be called
        handle_error "Package name or URL is missing"
    else
        # Check if the installation directory exists
        if [ -d "$install_dir" ]; then
            # if directory exists handle_error will be called
            handle_error "Package $package_name is already installed"
        else
            # Create the installation directory
            if mkdir -p "$install_dir"; then
              echo ""
              echo "Created installation directory of"
              echo "$install_dir"
              echo ""
            else
              # if directory creation fails handle_error will be called.
              handle_error "Failed to create $install_dir"
            fi

            # Download and unzip the package to the installation directory
            if wget -q "$package_url" -O "$install_dir/package.zip" && unzip -q "$install_dir/package.zip" -d "$install_dir"; then
                echo ""
                echo "Installed package"
                echo "$package_name"
                echo ""
                # remove the downloaded zip file
                rm ./apps/$package_name/package.zip



                # Perform case switch based on the package name
                case "$package_name" in
                    "nosecrets")
                        # Goes into the directory to install the package
                        cd $install_dir/no-more-secrets-master

                        echo ""
                        echo "Making"
                        echo "NMS"
                        echo ""

                        # Extra commands to install the package from github
                        if ! sudo make nms; then
                          # If it fails handle_error will be called
                            handle_error "Error: Failed to build NMS"
                        fi

                        echo ""
                        echo "Making"
                        echo "install"
                        echo ""
                        # Extra commands to install the package from github if it fails it will call the handle error
                        if ! sudo make install; then
                            handle_error "Error: Failed to build install"
                        fi

                        echo ""
                        echo "Installed successfully"
                        echo "nosecrets"
                        echo ""
                        ;;
                    "pywebserver")
                        # Add any specific actions for the 'webserver' package here
                        # Goes into the directory to install the package
                        cd $install_dir/webserver-master


                        echo ""
                        echo "Moving webserver"
                        echo "NMS"
                        echo ""
                        #  Extra steps for installing the package from github else if it fails call handle_error
                        if ! sudo mv webserver /usr/local/bin/webserver; then
                            handle_error "Error: Failed to move webserver"
                        fi

                        echo ""
                        echo "Changing permissions"
                        echo "webserver"
                        echo ""
                        # Extra steps for installing the package from github else if it fails call handle_error this gives the right permissions
                        if ! sudo chmod +x /usr/local/bin/webserver; then
                            handle_error "Error: failed to change permissions"
                        fi

                        echo ""
                        echo "Installed successfully"
                        echo "pywebserver"
                        echo ""
                        ;;
                    *)
                        # Handle error for unknown package if package name is invalid
                        handle_error "Unknown package: $package_name"
                        ;;
                esac
            else
                # Handle error for failed download or unzip
                handle_error "Error: Failed to download or unzip $package_name"
                # Rollback the package eval is for executing the function
                eval "rollback_$package_name"
            fi
        fi
    fi
    }



function rollback_nosecrets() {
    # Do not remove next line!
    echo "function rollback_nosecrets"

    # Functions variable
    local install_dir="./apps/nosecrets"

    echo ""
    echo "Removing directory"
    echo "$install_dir"
    echo ""
    # Checks for the directory and removes it
    if [ -d "$install_dir" ]; then
        rm -rf "$install_dir"
    fi


    # TODO rollback intermiediate steps when installation fails

    echo "rollback for nosecrets completed"
}


function rollback_pywebserver() {
    # Do not remove next line!
    echo "function rollback_pywebserver"

    # Function variable
    local install_dir="./apps/pywebserver"

    echo ""
    echo "Removing"
    echo "$install_dir"
    echo ""
    # remove installed files and directories
    if [ -d "$install_dir" ]; then
        rm -rf "$install_dir"
    fi

    echo "rollback for pywebserver completed"
}

function test_nosecrets() {
    # Do not remove next line!
    echo "function test_nosecrets"

    # TODO test nosecrets

    # Check if the package is installed
     if ls -l | nms 2>/dev/null; then
       # If it has a response and the exit code equals 0 its installed and success message will be shown
        if [ $? -eq 0 ]; then
            echo ""
            echo "Test was"
            echo "SUCCESSFULL"
            echo ""
        else
            # If it has a response and the exit code is not 0 something went wrong
            handle_error "test_nosecrets test failed"
        fi
      else
          handle_error "test_nosecrets failed."
      fi
}

function test_pywebserver() {
    # Do not remove next line!
    echo "function test_pywebserver"

    # TODO test the webserver
    # server and port number must be extracted from config.conf
    # test data must be read from test.json

    # Check if dev.conf is found and the command works
    if ! source dev.conf; then
        # If it doesnt work handle_error will be called
        handle_error "Error: Failed to start get the dev.conf data"
    fi

    # Check if the webserver is running
    if webserver & then
        echo "server starting"
    else
        # If it doesnt work handle_error will be called
        handle_error "Error: Failed to start webserver"
    fi

    # Store the PID of the last background process
    PID=$!

    # Max amount of attempts till declared failed
    max_tries=10
    attempt=1

    # Trying to send a request to the server
    while [ $attempt -le $max_tries ]; do
        if curl -s -o /dev/null "$WEBSERVER_IP:$WEBSERVER_PORT" &> /dev/null; then
            echo "Server is now running. Sending request..."
                    # Send POST request using curl to the running web server tail -n 1 gets the last line of the response
                      last_line=$(curl -X POST -H "Content-Type: application/json" --data @test.json "$WEBSERVER_IP:$WEBSERVER_PORT" 2>&1 | tail -n 1)
                      # Check if the last line of the response is the same as the test.json file
                      if [[ $last_line == $(<test.json) ]]; then
                          echo "Test is successful"
                      else
                        echo "Not same output failed!"
                      fi
                      # Kill the server (pywebserever)
                    kill $PID
            break
        else
            echo "Waiting for the server to start (Attempt $attempt of $max_tries)..."
            # Increment the attempt and wait 1 second
            ((attempt++))
            sleep 1
        fi
    done

    # If the attempt is greater than the max_tries handle_error will be called
    if [ $attempt -gt $max_tries ]; then
        handle_error "Failed to start server too many attempts"
    fi

}

function uninstall_nosecrets() {
    # Do not remove next line!
    echo "function uninstall_nosecrets"


    # Check if directory exists and remove it
    if [ -d "./apps/nosecrets" ]; then
      # Go into the directory and uninstall the package
      cd "apps/nosecrets/no-more-secrets-master"

      # Command to uninstall the package
      if ! sudo make uninstall; then
        # If failed handle_error will be called
        handle_error "Error: Failed to uninstall NMS"
      fi

      # Goes back to the root directory
      cd ../..

      # Remove the directory and its contents
      if ! sudo rm -rf ./nosecrets; then
        # If failed handle_error will be called
        handle_error "Error: Failed to remove nosecrets folder"
      fi
    else
        # If directory doesnt exist handle_error will be called
        handle_error "Failed to uninstall nosecrets no folder found"
    fi
}

function uninstall_pywebserver() {
    echo "function uninstall_pywebserver"

    # Check if the package is installed and remove it
    if ! sudo rm -rf /usr/local/bin/webserver; then
      # If failed handle_error will be called
        handle_error "Error: Failed to remove webserver from /usr/local/bin. See error.log for details."
    fi

    # Check if directory exists and remove it
        if [ -d "./apps/pywebserver" ]; then

          # Remove the directory and its contents
            if ! sudo rm -rf ./pywebserver; then
              # If failed handle_error will be called
                handle_error "Error: Failed to remove pywebserver folder"
            fi
        else
          # If directory doesnt exist handle_error will be called
          handle_error "Failed to uninstall nosecrets no folder found"
        fi


}

#TODO removing installed dependency during setup() and restoring the folder structure to original state
function remove() {
    # Do not remove next line!
    echo "function remove"

    # if there is a directory called apps remove it
    if [ -d "./apps" ]; then
        # Remove the directory and its contents
        if ! sudo rm -rf ./apps; then
          # If failed handle_error will be called
            handle_error "Error: Failed to remove apps folder"
        fi
        echo ""
        echo "Deleted the following directory"
        echo "./apps"
        echo ""
    else
        echo ""
        echo "The directory couldn't be found to be deleted"
        echo "./apps"
        echo ""
    fi

    # Array / list of packages that has to be uninstalled
    packages=("unzip" "wget" "curl")
    # for loop for each package in the list
    for p in "${packages[@]}"; do
      # Check if the package is installed using the package name as command.
      if command -v "$p" > /dev/null 2>&1; then
        # If the command works purge the package
        if ! sudo apt purge -y "$p"; then
          handle_error "Error: Failed to purge $p"
        fi
        echo ""
        echo "Deleted the package"
        echo "$p"
        echo ""
      else
        echo ""
        echo "The following package doesn't exist so couldn't be uninstalled"
        echo "$p"
        echo ""
      fi
    done

    echo "Finished! remove successfully"
}

function main() {
    # Do not remove next line!
    echo "function main"

    # TODO
    # Check if dev.conf is found and the command works
    source dev.conf
#    echo "$WEBSERVER_IP"
#    echo "$WEBSERVER_PORT"
#    echo "$APP1_URL"
#    echo "$APP2_URL"
#    echo "$INSTALL_DIR"

    # Arguments declaring the first and second argument
    arg1="$1"
    arg2="$2"

    # Case switch for the first argument
    case "$arg1" in
        # If the first argument is setup run the setup function with install directory as argument
        "setup")
            setup "$INSTALL_DIR"
            ;;
        # If the first argument is remove run the remove function
        "remove")
            remove
            ;;

        # If the first argument is nosecrets
        "nosecrets")
            case "$arg2" in
            # If the second argument is --install run the install_package function with the package name and url as arguments
                "--install")
                    install_package "$arg1" "$APP1_URL"
                    ;;
                  # If the second argument is --uninstall run the uninstall_nosecrets function
                "--uninstall")
                    uninstall_nosecrets
                    ;;
                "--test")
                # If the second argument is --test run the test_nosecrets function
                    test_nosecrets
                    ;;
                *)
                  # If the second argument is invalid handle_error will be called
                    handle_error "Invalid second argument: $arg2"
                    exit 1
                    ;;
            esac
            ;;

        # If the first argument is pywebserver
        "pywebserver")
            # Case switch for the second argument
            case "$arg2" in
            # If the second argument is --install run the install_package function with the package name and url as arguments
                "--install")
                    install_package "$arg1" "$APP2_URL"
                    ;;

                # If the second argument is --uninstall run the uninstall_pywebserver function
                "--uninstall")
                    uninstall_pywebserver
                    ;;

                # If the second argument is --test run the test_pywebserver function
                "--test")
                    test_pywebserver
                    ;;
                *)
                  #  If the second argument is invalid handle_error will be called
                    handle_error "Invalid second argument: $arg2"
                    exit 1
                    ;;
            esac
            ;;
        *)
          # If the first argument is invalid handle_error will be called
            handle_error "Invalid first argument: $arg1"
            exit 1
            ;;
    esac



    # Check if the first argument is valid
    # allowed values are "setup" "nosecrets" "pywebserver" "remove"
    # bash must exit if value does not match one of those values
    # Check if the second argument is provided on the command line
    # Check if the second argument is valid
    # allowed values are "--install" "--uninstall" "--test"
    # bash must exit if value does not match one of those values

    # Execute the appropriate command based on the arguments
    # TODO In case of setup
    # excute the function check_dependency and provide necessary arguments
    # expected arguments are the installation directory specified in dev.conf

}
# Pass commandline arguments to function main
main "$@"
