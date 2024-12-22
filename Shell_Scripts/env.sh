#!/bin/sh

SLEEPINT=10;

echo "Starting the script..."
echo "Fetching the SS_XAPP service IP..."

export SS_XAPP=`kubectl get svc -n ricxapp --field-selector metadata.name=service-ricxapp-ss-rmr -o jsonpath='{.items[0].spec.clusterIP}'`
if [ -z "$SS_XAPP" ]; then
    export SS_XAPP=`kubectl get svc -n ricxapp --field-selector metadata.name=service-ricxapp-ss-rmr -o jsonpath='{.items[0].spec.clusterIP}'`
fi
if [ -z "$SS_XAPP" ]; then
    echo "ERROR: Failed to find ss-xapp NBI service; aborting!"
    exit 1
fi

echo "SS_XAPP service IP: $SS_XAPP"
echo

echo "Listing NodeBs:"
curl -i -X GET http://${SS_XAPP}:8000/v1/nodebs
echo

echo "Listing Slices:"
curl -i -X GET http://${SS_XAPP}:8000/v1/slices
echo

echo "Listing UEs:"
curl -i -X GET http://${SS_XAPP}:8000/v1/ues
echo

sleep $SLEEPINT

echo "Creating NodeB (id=411):"
curl -i -X POST -H "Content-type: application/json" -d '{"type":"eNB","id":411,"mcc":"001","mnc":"01"}' http://${SS_XAPP}:8000/v1/nodebs
echo

echo "Verifying NodeB creation:"
curl -i -X GET http://${SS_XAPP}:8000/v1/nodebs
echo

sleep $SLEEPINT

echo "Creating Slice (name=fast1):"
curl -i -X POST -H "Content-type: application/json" -d '{"name":"fast1","allocation_policy":{"type":"proportional","share":1024}}' http://${SS_XAPP}:8000/v1/slices
echo

echo "Verifying Slice creation (fast1):"
curl -i -X GET http://${SS_XAPP}:8000/v1/slices
echo

sleep $SLEEPINT

echo "Creating Slice (name=fast2):"
curl -i -X POST -H "Content-type: application/json" -d '{"name":"fast2","allocation_policy":{"type":"proportional","share":1024}}' http://${SS_XAPP}:8000/v1/slices
echo

echo "Verifying Slice creation (fast2):"
curl -i -X GET http://${SS_XAPP}:8000/v1/slices
echo

sleep $SLEEPINT

echo "Binding Slice (fast1) to NodeB (enB_macro_001_001_0019b0):"
curl -i -X POST http://${SS_XAPP}:8000/v1/nodebs/enB_macro_001_001_0019b0/slices/fast1
echo

echo "Getting NodeB details (enB_macro_001_001_0019b0):"
curl -i -X GET http://${SS_XAPP}:8000/v1/nodebs/enB_macro_001_001_0019b0
echo

sleep $SLEEPINT

echo "Binding Slice (fast2) to NodeB (enB_macro_001_001_0019b0):"
curl -i -X POST http://${SS_XAPP}:8000/v1/nodebs/enB_macro_001_001_0019b0/slices/fast2
echo

echo "Getting NodeB details (enB_macro_001_001_0019b0):"
curl -i -X GET http://${SS_XAPP}:8000/v1/nodebs/enB_macro_001_001_0019b0
echo

sleep $SLEEPINT

echo "Creating Ue (ue=001010123456789)" ; echo
curl -i -X POST -H "Content-type: application/json" -d '{"imsi":"001010123456789"}' http://${SS_XAPP}:8000/v1/ues ; echo ; echo
echo Listing Ues: ; echo
curl -i -X GET http://${SS_XAPP}:8000/v1/ues ; echo ; echo

sleep $SLEEPINT

echo "Creating Ue (ue=001010123456780)" ; echo
curl -i -X POST -H "Content-type: application/json" -d '{"imsi":"001010123456780"}' http://${SS_XAPP}:8000/v1/ues ; echo ; echo
echo Listing Ues: ; echo
curl -i -X GET http://${SS_XAPP}:8000/v1/ues ; echo ; echo

sleep $SLEEPINT

echo "Binding Ue (imsi=001010123456789) to Slice (fast1):"
curl -i -X POST http://${SS_XAPP}:8000/v1/slices/fast1/ues/001010123456789 ; echo ; echo
echo

echo "Getting Slice details (fast1):"
curl -i -X GET http://${SS_XAPP}:8000/v1/slices/fast1
echo

sleep $SLEEPINT

echo "Binding Ue (imsi=001010123456780) to Slice (fast2):"
curl -i -X POST http://${SS_XAPP}:8000/v1/slices/fast2/ues/001010123456780 ; echo ; echo
echo

echo "Getting Slice details (fast2):"
curl -i -X GET http://${SS_XAPP}:8000/v1/slices/fast2
echo

sleep $SLEEPINT

echo "Environment Setting Complete!"
