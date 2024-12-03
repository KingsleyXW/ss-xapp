#!/bin/sh

export SS_XAPP=$(kubectl get svc -n ricxapp --field-selector metadata.name=service-ricxapp-ss-rmr -o jsonpath='{.items[0].spec.clusterIP}')
if [ -z "$SS_XAPP" ]; then
    echo "ERROR: failed to find ss-xapp nbi service; aborting cleanup!"
    exit 1
fi

echo "SS_XAPP=$SS_XAPP"
echo "Cleaning up previous NodeBs, slices, and UEs..."

# Delete NodeB
echo "Deleting NodeB (id=1)..." ; echo
curl -i -X DELETE "http://${SS_XAPP}:8000/v1/nodebs/enB_macro_001_001_0019b0" ; echo ; echo

# Delete Slices
echo "Deleting Slice (name=fast)..." ; echo
curl -i -X DELETE "http://${SS_XAPP}:8000/v1/slices/fast" ; echo ; echo

echo "Deleting Slice (name=secure_slice)..." ; echo
curl -i -X DELETE "http://${SS_XAPP}:8000/v1/slices/secure_slice" ; echo ; echo

# Delete UEs
echo "Deleting UE (imsi=001010123456789)..." ; echo
curl -i -X DELETE "http://${SS_XAPP}:8000/v1/ues/001010123456789" ; echo ; echo

echo "Deleting UE (imsi=001010123456780)..." ; echo
curl -i -X DELETE "http://${SS_XAPP}:8000/v1/ues/001010123456780" ; echo ; echo

echo "Cleanup completed. Ready to rerun the script."
