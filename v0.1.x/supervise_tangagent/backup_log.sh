#! /bin/sh
#
SROOT=$(cd $(dirname "$0"); pwd)
cd $SROOT

mv -f agent.log.2 agent.log.3
mv -f agent.log.1 agent.log.2
cp -f agent.log agent.log.1
echo > agent.log
