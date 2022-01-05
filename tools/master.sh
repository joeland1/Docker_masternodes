RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

function checkoutputs (){
    echo $@ | jq -r '.[] | .txhash, .outputidx' | (
        while read txhash; do
            read output_index
            if ! [[ $output_index =~ ^[0-9]+$ ]]; then
                echo "${RED}Invalid txid${NC}" > /dev/tty
                echo "{\n  \"txhash\": \"$txhash\",\n  \"outputidx\": \"$output_index\"\n}"  > /dev/tty
                echo 255
            fi
        done
    )
}

function main () {
    echo -e "Copy and paste the output of ${BOLD}getmasternodeoutputs${NC} below..."
    getmasternodeoutputs=$(sed '/^$/q')
    if [ $(checkoutputs $getmasternodeoutputs) != 0 ]; then
        echo "${RED}something went wrong, output above. try fix or contact dev.\n thank you and have a great day" 
        exit 1
    fi
}

main