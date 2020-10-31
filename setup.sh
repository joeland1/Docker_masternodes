#!/usr/bin/env bash

# setup master container
# setup.sh --ip [ip addpress] --key [masternode_key]

RED='\033[0;31m'
GREEN='\033[0;32m'
NEXT='\033[0;34m'
NC='\033[0m'

COIN_NAME='dogecash'
CLI_NAME=$COIN_NAME"-cli"
DAEMON_NAME=$COIN_NAME"d"

HOME_PATH="/home/$COIN_NAME"
CONF_NAME='dogecash.conf'

DAEMON_CONFIG_LAUNCH="-daemon -datadir=$HOME_PATH/.$COIN_NAME -conf=$HOME_PATH/.$COIN_NAME/$CONF_NAME"

HAS_IP=false
HAS_KEY=false

MN_IP=
MN_KEY=

#ifconfig.me
#ifconfig.co
#icanhazip.com
SECOND_LINK='ifconfig.me'
function get_ip()
{
  MN_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

  if [ -z "$MN_IP" ]; then
      #echo -e "${RED}$(date '+%F %r') [ERROR]: Could not get external ip from opendns.com${NC}" -> maybe add timestamps later
      echo -e "$RED[ERROR]: Could not get external ip from opendns.com$NC"
      echo -e "[INFO]: Trying to get ip from $SECOND_LINK"

      MN_IP=$(curl -s $SECOND_LINK)

      if [ -z "$MN_IP" ]; then
        echo -e "$RED[ERROR]: Could not get external ip from $SECOND_LINK$NC"
        echo -e "$NEXT[NEXT]: Please use another link or manually enter in an ip address$NC"

        exit 1
      fi
  fi
  HAS_IP=true
  echo "externalip=$MN_IP" >> $HOME_PATH/.$COIN_NAME/$CONF_NAME
  echo -e "$GREEN[INFO]: IP address aquired -> $MN_IP$NC"
}

function getmnkey()
{
  echo -e "[INFO]: Generating $COIN_NAME masternode key"
  ./$DAEMON_NAME $DAEMON_CONFIG_LAUNCH
  source "$HOME_PATH/.$COIN_NAME/$CONF_NAME"
  echo $rpcuser
  echo $rpcpassword
  sleep 3
  MN_KEY=$(./$CLI_NAME -rpcuser=$rpcuser -rpcpassword=$rpcpassword getblockcount)
  echo "mnkey="$MN_KEY

  while [ "$MN_KEY" = "-1" ] || [ -z "$MN_KEY" ]; do
    sleep 1
    MN_KEY=$(./$CLI_NAME -rpcuser=$rpcuser -rpcpassword=$rpcpassword getblockcount)
  done

  MN_KEY=$(./$CLI_NAME -rpcuser=$rpcuser -rpcpassword=$rpcpassword createmasternodekey)
  ./$CLI_NAME -rpcuser=$rpcuser -rpcpassword=$rpcpassword stop
  HAS_KEY=true
  echo -e "$GREEN[INFO]: Masternode key aquired -> $MN_KEY$NC"
}

function write_conf()
{
    echo "server=1" > $HOME_PATH/.$COIN_NAME/$CONF_NAME
    echo "rpcuser=user"$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '') >> $HOME_PATH/.$COIN_NAME/$CONF_NAME
    echo "rpcpassword="$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 ; echo '') >> $HOME_PATH/.$COIN_NAME/$CONF_NAME
}

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

if [ $# -gt 4 ]; then
  echo "too many peram"
  exit 1
fi

while [ "$1" != "" ]; do
    case $1 in
      -h|--help)
        echo "help"
        exit 1
        ;;
      -i|--ip)
        if [ $HAS_IP = true ]; then
          echo "You cannot input 2 ip"
          exit 1
        fi
        MN_IP=$2
        HAS_IP=true
        ;;
      -k|--key)
        if [ $HAS_KEY = true ]; then
          echo "You cannot input 2 mn keys"
          exit 1
        fi
        MN_KEY=$2
        HAS_KEY=true
        ;;
      *)
    esac
    shift
    shift
done

apt-get update
apt-get install dnsutils
write_conf
getmnkey
get_ip
#apt-get remove dnsutils
