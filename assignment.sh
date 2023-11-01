#!/usr/bin/env bash

# Define global variable here

# TODO: Add required and additional packagenas dependecies 
# for your implementation
declare -a packages=("https://github.com/nickjj/webserver.git" "https://github.com/bartobri/no-more-secrets.git")

# TODO: define a function to handle errors
# This funtion accepts two parameters one as the error message and one as the command to be excecuted when error occurs.
function handle_error() {
    # Do not remove next line!
    echo "function handle_error"

    local error_message="$1"
    local command="$2"

    #print error message
    echo "$error_message"

    #command execute
    if [ -n "$command" ]; then
        echo "Executing command: $command"
        eval "$command"
    fi
 
} 
# Function to solve dependencies
function setup() {
    # Do not remove next line!
    echo "function setup $1"
    
    # TODO installation from online package requires values for
    # package_name package_url install_dir3

    # TODO check if required dependency is not already installed otherwise install it
    # if a a problem occur during the this process 
    # use the function handle_error() to print a messgage and handle the error

    # TODO check if nessassary dependecies and folder structure exists and
    # print the outcome for each checking step
    sudo apt-get update
    packages=("curl" "unzip" "wget")
    for dependency in "${packages[@]}"; do
        if ! command -v "$dependency" >/dev/null 2>&1; then
            echo "$dependency missing, installing.."

            if ! sudo apt-get install -y "$dependency"; then #install dependency -y is for auto yes
                handle_error "Failed to install $dependency"
            fi

            echo "$dependency installed dependencies"
        else
            echo "$dependency is installed"
        fi
    done
    echo ""
    echo "Checking files & directories"
    echo ""
      if [ -d ./apps ]; then
          echo "directory exists"
      else
          mkdir -p ./apps
      fi

    if [ -f dev.conf ]; then
        echo "dev.conf exists"
      else
        echo "creating dev.conf"
        touch dev.conf
    fi

    # TODO check if required folders and files exists before installations
    # For example: the folder ./apps/ and the file "dev.conf"
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
            mkdir -p "$install_dir"

            # Download and unzip the package
            if wget -q "$package_url" -O "$install_dir/package.zip" && unzip -q "$install_dir/package.zip" -d "$install_dir"; then
                echo "Package $package_name installed successfully"

                # Perform package-specific actions
                case "$package_name" in
                    "nosecrets")
                        cd $install_dir/no-more-secrets-master
                        make nms
                        sudo make install
                        ;;
                    "pywebserver")
                        # Add any specific actions for the 'webserver' package here
                        cd $install_dir/webserver-master
                        sudo mv webserver /usr/local/bin/webserver
                        sudo chmod +x /usr/local/bin/webserver
                        ;;
                    *)
                        handle_error "Unknown package: $package_name"
                        ;;
                esac
            else
                handle_error "Error: Failed to download or unzip $package_name"
            fi
        fi
    fi
    }



function rollback_nosecrets() {
    # Do not remove next line!
    echo "function rollback_nosecrets"

    # TODO rollback intermiediate steps when installation fails
}

function rollback_pywebserver() {
    # Do not remove next line!
    echo "function rollback_pywebserver"

    # TODO rollback intermiediate steps when installation fails
}

function test_nosecrets() {
    # Do not remove next line!
    echo "function test_nosecrets"

    # TODO test nosecrets
     ls -l | nms
    pkill -f nms
}

function test_pywebserver() {
    # Do not remove next line!
    echo "function test_pywebserver"

    # TODO test the webserver
    # server and port number must be extracted from config.conf
    # test data must be read from test.json
    source dev.conf
    webserver &

    # Store the PID of the last background process (webserver) in a variable
    PID=$!

  # Debugging: Print the values to verify the correct IP and port
  echo "WEBSERVER_IP: $WEBSERVER_IP"
  echo "WEBSERVER_PORT: $WEBSERVER_PORT"

  # Check if the server is up and running before sending the request
  while ! nc -z $WEBSERVER_IP $WEBSERVER_PORT; do
      echo "Waiting for the server to start..."
      sleep 1
  done

  echo "Server is now running. Sending request..."

  # Send POST request using curl to the running webserver
  curl $WEBSERVER_IP:$WEBSERVER_PORT/ -H "Content-Type: application/json" -X POST --data @test.json > /dev/null 2>&1
  # Redirect output to /dev/null to prevent it from being displayed in the terminal

  # Kill the webserver process after it finishes its job
  kill $PID

}

function uninstall_nosecrets() {
    # Do not remove next line!
    echo "function uninstall_nosecrets"
    sudo rm -rf ./apps/nosecrets
    sudo rm -rf /usr/local/bin/nms
}

function uninstall_pywebserver() {
    echo "function uninstall_pywebserver"
    sudo rm -rf ./apps/pywebserver
    sudo rm -rf /usr/local/bin/webserver
}

#TODO removing installed dependency during setup() and restoring the folder structure to original state
function remove() {
      if [ -d ./apps ]; then
            sudo rm -rf ./apps
        else
            echo "no /apps directory found to delete."
        fi
    packages=("curl" "unzip" "wget")
    for dependency in "${packages[@]}"; do
        if command -v "$dependency" >/dev/null 2>&1; then
            echo "$dependency isn't found"

            if sudo apt purge -y "$dependency"; then #uninstall dependency -y is for auto yes
                handle_error "Failed to remove $dependency"
            fi

            echo "$dependency uninstalled dependencies"
        else
            echo "$dependency isnt installed"
        fi
    done
    # Do not remove next line!
    echo "function remove"
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
