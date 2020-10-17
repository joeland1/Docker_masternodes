#!/bin/bash


COIN_NAME='dogecash'
CLI_NAME=$COIN_NAME"-cli"
DAEMON_NAME=$COIN_NAME"d"
HOME_PATH="/home/$COIN_NAME"

RPC_PW=
RPC_USER=
DAEMON_CONFIG_LAUNCH=

if [[ $EUID -eq 0 ]]; then
   echo "Please run script as dogecash user ( -u dogecash )"
   exit 1
fi

function get_credentials()
{
  source "$HOME_PATH/.$COIN_NAME/$CONF_NAME"
  RPC_PW=$rpcpassword
  RPC_USER=$rpcuser
  DAEMON_CONFIG_LAUNCH="-daemon -datadir=$HOME_PATH/.$COIN_NAME -conf=$HOME_PATH/.$COIN_NAME/$CONF_NAME"
}

#not running
if [ -z $(pidof $DAEMON_NAME) ]; then
  echo "Daemon not running... launching"
  ./$DAEMON_NAME $DAEMON_CONFIG_LAUNCH

  pidofdaemon=
  while [ -z $pidofdaemon ]; do
    $pidofdaemon=$(pidof $DAEMON_CONFIG_LAUNCH)
  done
else
  echo "daemon is running, are you really sure that you want to restart the node?"
  read -p "y/n" response
  if [ $response == [yY] ] || [ $response == [yY][eE][sS] ] ; then
    echo "yes"
  fi
fi
