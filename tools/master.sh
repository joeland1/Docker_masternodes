RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

function checkoutputs () {
    echo $@ | jq -r '.[] | .txhash, .outputidx' | (
        return_code=''
        while read txhash; do
            if [ -n $(echo "$txhash" | grep -v '^[a-zA-Z0-9]+$') ] || [ "${#txhash}" -ne 64 ]; then
                echo "${RED}tx invalid${NC}" > /dev/tty
            fi

            read output_index
            if ! [[ $output_index =~ ^[0-9]+$ ]]; then
                echo "${RED}Invalid txid${NC}" > /dev/tty
                echo "{\n  \"txhash\": \"$txhash\",\n  \"outputidx\": \"$output_index\"\n}"  > /dev/tty
            fi

            #https://api2.dogecash.org/transaction/229da48a3dc5cb3daf02734b22138210d7c98ea2ce340ff4251a54ab7c79eafa
            #https://api2.dogecash.org/unspent/DJSqbVXfsBzZKR7znDU4ceyWKQAfQmmhaM?amount=99
        done

        echo 225
    )
}

function main () {
    echo "Copy and paste the output of ${BOLD}getmasternodeoutputs${NC} below..."
    getmasternodeoutputs=$(sed '/^$/q')
    echo $getmasternodeoutputs
    if [ $(checkoutputs $getmasternodeoutputs) != 0 ]; then
        echo "${RED}something went wrong, output above. try fix or contact dev.\nThank you and have a great day" 
        exit 1
    fi
}

main