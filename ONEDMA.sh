#!/usr/bin/ksh

if [ $# -ne 1 ]
then
    echo "Usage: ./<script name> <env>"
    echo "Ex: ./ONEDMA.sh dev"
    exit
fi

env=$1
log="/ML-Config/LOGS/MDM"

./gradlew hubRunFlow -PflowName=ONEDMAOrchestraDelta -PentityName=Orchestra -PbatchSize=200 -PthreadCount=16 -PshowOptions=true -Psteps="1" -PenvironmentName=$env > ${log}/ONEDMAOrchestraDelta_`date +%s`.log 2>&1 &&

./gradlew corbOrchestraDeltaStep2 -PenvironmentName=$env > ${log}/corbOrchestraDeltaStep2_`date +%s`.log 2>&1
