#!/bin/bash
### Dependancies ###
# OCI_CLI 2.6.5
# jq-1.6

### VARS ###
# COMPART - Array - Hold compartment IDs

COMPART=( )

### FUNCTIONS ###

function renderLogo() {
echo "________                      .__          "
echo "\_____  \____________    ____ |  |   ____  "
echo " /   |   \_  __ \__  \ _/ ___\|  | _/ __ \ "
echo '/    |    \  | \// __ \   \___|  |_\  ___/ '
echo "\_______  /__|  (____  /\___  >____/\___  >"
echo "        \/           \/     \/          \/ "
echo "_________ .__                   .___       "
echo "\_   ___ \|  |   ____  __ __  __| _/       "
echo "/    \  \/|  |  /  _ \|  |  \/ __ |        "
echo "\     \___|  |_(  <_> )  |  / /_/ |        "
echo " \______  /____/\____/|____/\____ |        "
echo "        \/                       \/        "
echo ".___        _____                          "
echo "|   | _____/ ____\___________              "
echo '|   |/    \   __\\_  __ \__  \             '
echo "|   |   |  \  |   |  | \/ __ \_           "
echo "|___|___|  /__|   |__|  (____  /           "
echo "         \/                  \/            \n"
}

# User selects what they want to do
function startMainLoop() {
    # Get compartments array if $COMPART is empty
    if [[ -z ${COMPART[0]} ]]; then
        getCompartments
    fi

    echo 'What would you like to do?'
    echo '1: List resources in tenancy'
    echo 'q: Quit'
    read -r -n 1 -p 'Enter your selection here: ' ANSWER

    case $ANSWER in

        1)
            echo "\n"
            listResources
            ;;
        t)
            #getCompartments
            for i in ${COMPART[@]}; do
                echo $i
            done
            startMainLoop
            ;;
        *)
            echo '\nGoodbye!'
            return 0
            ;;
    esac
}

# Get list of compartments and save them to array
function getCompartments() {
    echo "Searching for compartments...\n"
    # Get list of compartments in tenancy where lifecycle-state is not DELETED and assign to $COMPART
    while IFS="\n" read -r line; do 
        COMPART+=( "${line:1:${#line}-2}" )
    # Use command as input
    done <<<"$(oci iam compartment list --all --compartment-id-in-subtree true | jq '.data[] | select(."lifecycle-state" != "DELETED") | .id')"
}

# User select option to list resources
function listResources() {
    echo "Please select a resource to list"
    echo "1: List Computes"
    echo "2: List Autonomous Data Warehouses"
    echo "3: List Autonomous Transaction Processors"
    echo "4: List Load Balancers"
    echo "r: Return to previous menu"
    echo "q: Quit"

    read -r -n 1 -p 'Enter your selection here: ' ANSWER
    case $ANSWER in

        1)
            #TODO
            echo $ANSWER
            startMainLoop
            ;;
        2)
            echo '\n'
            listADB 'DW'
            ;;
        3)
            echo '\n'
            listADB 'OLTP'
            ;;
        4)
            #TODO
            echo $ANSWER
            startMainLoop
            ;;
        r)
            echo "\n"
            startMainLoop
            ;;
        *)
            echo "\nGoodbye!"
            return 0
            ;;
        esac
}

# Find all autonomous databases in tenancy
function listADB() {
    for i in "${COMPART[@]}"; do
        oci db autonomous-database list -c $i | jq --arg var $1 '.data[] | select(."db-workload" == $var)'
    done
    echo "### Finished! ###"
    listResources
}


### START MAIN ###
renderLogo
startMainLoop
