#!/bin/sh

SLEEPINT=$1
if [ -z "$SLEEPINT" ]; then
    SLEEPINT=4
fi

export SS_XAPP=$(kubectl get svc -n ricxapp --field-selector metadata.name=service-ricxapp-ss-nbi -o jsonpath='{.items[0].spec.clusterIP}')
if [ -z "$SS_XAPP" ]; then
    export SS_XAPP=$(kubectl get svc -n ricxapp --field-selector metadata.name=service-ricxapp-ss-rmr -o jsonpath='{.items[0].spec.clusterIP}')
fi
if [ -z "$SS_XAPP" ]; then
    echo "ERROR: failed to find ss-xapp nbi service; aborting!"
    exit 1
fi

echo SS_XAPP=$SS_XAPP ; echo

# Create NodeB
echo "Creating NodeB (id=1):" ; echo
OUTPUT=$(curl -X POST -H "Content-type: application/json" -d '{"type":"eNB","id":411,"mcc":"001","mnc":"01"}' http://${SS_XAPP}:8000/v1/nodebs)
echo $OUTPUT
NBNAME=$(echo $OUTPUT | jq -r '.name')

if [ -z "$OUTPUT" -o -z "$NBNAME" ]; then
    echo "ERROR: failed to create NodeB; aborting"
    exit 1
fi

sleep $SLEEPINT

# Create Slices (fast and slow)
echo "Creating Slice (name=fast):" ; echo
curl -i -X POST -H "Content-type: application/json" -d '{"name":"fast","allocation_policy":{"type":"proportional","share":1024}}' http://${SS_XAPP}:8000/v1/slices ; echo ; echo

echo "Creating Slice (name=slow):" ; echo
curl -i -X POST -H "Content-type: application/json" -d '{"name":"slow","allocation_policy":{"type":"proportional","share":256}}' http://${SS_XAPP}:8000/v1/slices ; echo ; echo

sleep $SLEEPINT

# Bind Slices to NodeB
echo "Binding Slice to NodeB (name=fast):" ; echo
curl -i -X POST http://${SS_XAPP}:8000/v1/nodebs/${NBNAME}/slices/fast ; echo ; echo

echo "Binding Slice to NodeB (name=slow):" ; echo
curl -i -X POST http://${SS_XAPP}:8000/v1/nodebs/${NBNAME}/slices/slow ; echo ; echo

sleep $SLEEPINT

# Create UE and bind to fast slice
UE_IMSI="001010123456789"
echo "Creating UE (imsi=${UE_IMSI}):" ; echo
curl -i -X POST -H "Content-type: application/json" -d "{\"imsi\":\"${UE_IMSI}\"}" http://${SS_XAPP}:8000/v1/ues ; echo ; echo

echo "Binding UE to Slice fast (imsi=${UE_IMSI}):" ; echo
curl -i -X POST http://${SS_XAPP}:8000/v1/slices/fast/ues/${UE_IMSI} ; echo ; echo

# Infinite loop for dynamic throttling
while true; do
    echo "Enter input (t=throttle, f=restore, exit=terminate):"
    read INPUT
    case $INPUT in
        t)
            echo "Throttling UE by moving it to slow slice..."
            curl -i -X POST http://${SS_XAPP}:8000/v1/sliceINPUTs/slow/ues/${UE_IMSI} ; echo ; echo
            ;;
        f)
            echo "Restoring UE by moving it to fast slice..."
            curl -i -X POST http://${SS_XAPP}:8000/v1/slices/fast/ues/${UE_IMSI} ; echo ; echo
            ;;
        exit)
            echo "Exiting the script..."
            break
            ;;
        *)
            echo "Invalid input. Please enter 't', 'f', or 'exit'."
            ;;
    esac
done
