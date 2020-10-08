# setup master container
# setup.sh --ip [ip addpress] --key [masternode_key]
MN_IP=${1-} #-> ip not needed because already dl from docker
MN_KEY=${1-}

RED='\033[0;31m'
GREEN='\033[0;32m'
NEXT='\033[0;34m'

NC='\033[0m'

CLI_NAME='dogecash-cli'
DAEMON_NAME='dogecashd'
DAEMON_CONFIG=''



#ifconfig.me
#ifconfig.co
#icanhazip.com
SECOND_LINK='ifconfig.me'
function get_ip()
{
  MN_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

  if [ -z "$MN_IP" ]; then
      #echo -e "${RED}$(date '+%F %r') [ERROR]: Could not get external ip from opendns.com${NC}" -> maybe add timestamps later
      echo -e "${RED}[ERROR]: Could not get external ip from opendns.com${NC}"
      echo -e "[INFO]: Trying to get ip from ${SECOND_LINK}"

      MN_IP=$(curl -s ${SECOND_LINK})

      if [ -z "$MN_IP" ]; then
        echo -e "${RED}[ERROR]: Could not get external ip from ${SECOND_LINK}${NC}"
        echo -e "${NEXT}[NEXT]: Please use another link or manually enter in an ip address${NC}"

        exit 1
      fi
  fi
  echo -e "${GREEN}[INFO]: IP Address Aquired -> ${MN_IP}${NC}"
}

function getmnkey()
{
  echo "x"
}

for arg in "$@"
  do
    case $arg in
        "--ip" )
           echo "ip"
           echo "ip2"
           ;;
        "--key" )
           echo "key";;
    esac
  done
