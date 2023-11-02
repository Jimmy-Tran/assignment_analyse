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

    packages=("wget" "unzip" "curl")
    for p in "${packages[@]}"; do
      if ! command -v "$p" > /dev/null 2>&1; then
        echo ""
        echo "Installing the package"
        echo "$p"
        echo ""
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

    if [ -d ./apps ]; then
          echo ""
          echo "Found directory"
          echo "/apps"
          echo ""
      else
          echo ""
          echo "Directory missing"
          echo "creating /apps"
          echo ""
            if mkdir -p ./apps; then
              echo ""
              echo "Directory created"
              echo "/apps"
              echo ""
            else
              handle_error "Failed to create directory /apps"
            fi
    fi

        if [ -f dev.conf ]; then
              echo ""
              echo "Found "
              echo "dev config"
              echo ""
          else
              echo ""
              echo "Dev config missing"
              echo "creating dev.conf"
              echo ""
                if touch dev.conf; then
                  echo ""
                  echo "Config file created"
                  echo "dev.conf"
                  echo ""
                else
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

    local package_name="$1"
    local package_url="$2"
    local install_dir="./apps/$package_name"

    if [ -z "$package_name" ] || [ -z "$package_url" ]; then
        handle_error "Package name or URL is missing"
    else
        # Check if the installation directory already exists
        if [ -d "$install_dir" ]; then
            handle_error "Package $package_name is already installed"
        else
            # Create the installation directory
            if mkdir -p "$install_dir"; then
              echo ""
              echo "Created installation directory of"
              echo "$install_dir"
              echo ""
            else
              handle_error "Failed to create $install_dir"
            fi

            # Download and unzip the package
            if wget -q "$package_url" -O "$install_dir/package.zip" && unzip -q "$install_dir/package.zip" -d "$install_dir"; then
                echo ""
                echo "Installed package"
                echo "$package_name"
                echo ""
                rm ./apps/$package_name/package.zip



                # Perform package-specific actions
                case "$package_name" in
                    "nosecrets")
                        cd $install_dir/no-more-secrets-master

                        echo ""
                        echo "Making"
                        echo "NMS"
                        echo ""
                        if ! sudo make nms; then
                            handle_error "Error: Failed to build NMS"
                        fi

                        echo ""
                        echo "Making"
                        echo "install"
                        echo ""
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
                        cd $install_dir/webserver-master

                        echo ""
                        echo "Moving webserver"
                        echo "NMS"
                        echo ""
                        if ! sudo mv webserver /usr/local/bin/webserver; then
                            handle_error "Error: Failed to move webserver"
                        fi

                       echo ""
                        echo "Changing permissions"
                        echo "webserver"
                        echo ""
                        if ! sudo chmod +x /usr/local/bin/webserver; then
                            handle_error "Error: failed to change permissions"
                        fi

                        echo ""
                        echo "Installed successfully"
                        echo "pywebserver"
                        echo ""
                        ;;
                    *)
                        handle_error "Unknown package: $package_name"
                        ;;
                esac
            else
                handle_error "Error: Failed to download or unzip $package_name"
                eval "rollback_$package_name"
            fi
        fi
    fi
    }



function rollback_nosecrets() {
    # Do not remove next line!
    echo "function rollback_nosecrets"

    local install_dir="$1/nosecrets"

    echo ""
    echo "Removing directory"
    echo "$install_dir"
    echo ""
    if [ -d "$install_dir" ]; then
        rm -rf "$install_dir"
    fi

    echo ""
    echo "Removing"
    echo "/usr/local/bin/nms"
    echo ""
    if ! sudo rm -rf /usr/local/bin/nms; then
        handle_error "Error: Unable to delete NMS from /usr/local/bin"
    fi


    # TODO rollback intermiediate steps when installation fails

    echo "rollback for nosecrets completed"
}


function rollback_pywebserver() {
    # Do not remove next line!
    echo "function rollback_pywebserver"

    local install_dir="$1/pywebserver"

    echo ""
    echo "Removing"
    echo "$install_dir"
    echo ""
    # remove installed files and directories
    if [ -d "$install_dir" ]; then
        rm -rf "$install_dir"
    fi

    echo ""
    echo "Removing"
    echo "/usr/local/bin/webserver"
    echo ""
    if ! sudo rm -rf /usr/local/bin/webserver; then
        handle_error "Error: Unable to delete webserver from /usr/local/bin"
    fi

    echo "rollback for pywebserver completed"
}

function test_nosecrets() {
    # Do not remove next line!
    echo "function test_nosecrets"

    # TODO test nosecrets
     if ls -l | nms 2>/dev/null; then
        if [ $? -eq 0 ]; then
            echo ""
            echo "Test was"
            echo "SUCCESSFULL"
            echo ""
        else
            handle_error "test_nosecrets output failed wasnt matching!"
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

    if ! source dev.conf; then
        handle_error "Error: Failed to start get the dev.conf data"
    fi

    if webserver & then
        echo "server starting"
    else
        handle_error "Error: Failed to start webserver"
    fi

    # Store the PID of the last background process (webserver) in a variable
    PID=$!

  # Check if the server is up and running before sending the request
    max_tries=10
    attempt=1

    # Check if the server is up and running before sending the request
    while [ $attempt -le $max_tries ]; do
        if curl -s -o /dev/null "$WEBSERVER_IP:$WEBSERVER_PORT" &> /dev/null; then
            echo "Server is now running. Sending request..."
                    # Send POST request using curl to the running web server
                      last_line=$(curl -X POST -H "Content-Type: application/json" --data @test.json "$WEBSERVER_IP:$WEBSERVER_PORT" 2>&1 | tail -n 1)
                      if [[ $last_line == $(<test.json) ]]; then
                          echo "Test is successful"
                      else
                        echo "Not same output failed!"
                      fi
                    kill $PID
            break
        else
            echo "Waiting for the server to start (Attempt $attempt of $max_tries)..."
            ((attempt++))
            sleep 1
        fi
    done

    if [ $attempt -gt $max_tries ]; then
        handle_error "Failed to start server too many attempts"
    fi

}

function uninstall_nosecrets() {
    # Do not remove next line!
    echo "function uninstall_nosecrets"
    if [ -d "./apps/nosecrets" ]; then
      cd "apps/nosecrets/no-more-secrets-master"
      if ! sudo make uninstall; then
        handle_error "Error: Failed to uninstall NMS"
      fi

      cd ../..

      if ! sudo rm -rf ./nosecrets; then
        handle_error "Error: Failed to remove nosecrets folder"
      fi
    else
        handle_error "Failed to uninstall nosecrets no folder found"
    fi
}

function uninstall_pywebserver() {
    echo "function uninstall_pywebserver"
    if ! sudo rm -rf /usr/local/bin/webserver; then
        handle_error "Error: Failed to remove webserver from /usr/local/bin. See error.log for details."
        # You can also inspect the error.log for debugging: cat error.log
    fi
        if [ -d "./apps/pywebserver" ]; then
            if ! sudo rm -rf ./pywebserver; then
                handle_error "Error: Failed to remove pywebserver folder"
            fi
        else
          handle_error "Failed to uninstall nosecrets no folder found"
        fi


}

#TODO removing installed dependency during setup() and restoring the folder structure to original state
function remove() {
    # Do not remove next line!
    echo "function remove"
    if [ -d "./apps" ]; then
        if ! sudo rm -rf ./apps; then
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

    packages=("unzip" "wget" "curl")
    for p in "${packages[@]}"; do
      if command -v "$p" > /dev/null 2>&1; then
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
    source dev.conf
#    echo "$WEBSERVER_IP"
#    echo "$WEBSERVER_PORT"
#    echo "$APP1_URL"
#    echo "$APP2_URL"
#    echo "$INSTALL_DIR"

    arg1="$1"
    arg2="$2"

    case "$arg1" in
        "setup")
            setup "$INSTALL_DIR"
            ;;

        "remove")
            remove
            ;;

        "nosecrets")
            case "$arg2" in
                "--install")
                    install_package "$arg1" "$APP1_URL"
                    ;;
                "--uninstall")
                    uninstall_nosecrets
                    ;;
                "--test")
                    test_nosecrets
                    ;;
                "--rollback")
                    rollback_nosecrets
                    ;;
                *)
                    handle_error "Invalid second argument: $arg2"
                    exit 1
                    ;;
            esac
            ;;

        "pywebserver")
            case "$arg2" in
                "--install")
                    install_package "$arg1" "$APP2_URL"
                    ;;
                "--uninstall")
                    uninstall_pywebserver
                    ;;
                "--test")
                    test_pywebserver
                    ;;
                "--rollback")
                    rollback_pywebserver
                    ;;
                *)
                    handle_error "Invalid second argument: $arg2"
                    exit 1
                    ;;
            esac
            ;;
        *)
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

#bash assignment.sh setup
#bash assignment.sh remove

#bash assignment.sh nosecrets --install
#bash assignment.sh nosecrets --test
#bash assignment.sh nosecrets --uninstall
#bash assignment.sh nosecrets --rollback

#bash assignment.sh pywebserver --install
#bash assignment.sh pywebseraver --test
#bash assignment.sh pywebserver --uninstall
#bash assignment.sh pywebserver --rollback
