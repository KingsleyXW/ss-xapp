#!/bin/bash

# Define the iperf3 server details
SERVER_IP="172.16.0.1"
SERVER_PORT=5006

# Prompt user for input
echo "Enter the lower size of the requests from UE (in Mbps):"
read lower_size_of_the_requests
echo "Enter the upper size of the requests from UE (in Mbps):"
read upper_size_of_the_requests

# Infinite loop for ON and OFF durations
while true; do
    # Generate random ON and OFF durations within the specified ranges
    ON_DURATION=$(shuf -i 5-10 -n 1)  # Random value between 5 and 10
    OFF_DURATION=$(shuf -i 10-15 -n 1)  # Random value between 10 and 15

    echo "Generating traffic for ${ON_DURATION} seconds with varying rates..."

    # Loop through rates in the specified range
    for RATE in $(seq $lower_size_of_the_requests $upper_size_of_the_requests); do
        echo "Testing with rate: ${RATE} Mbps..."
        sudo ip netns exec ue1 iperf3 -c ${SERVER_IP} -p ${SERVER_PORT} -i 1 -t 1 -b "${RATE}M"
    done

    echo "Pausing traffic for ${OFF_DURATION} seconds..."
    sleep $OFF_DURATION
done

'''
    old script 
#!/bin/bash

# Define the ON and OFF durations in seconds
ON_DURATION=5
OFF_DURATION=5

# Define the iperf3 server details
SERVER_IP=172.16.0.1
SERVER_PORT=5006

while true; do
    echo "Generating traffic for ${ON_DURATION} seconds with varying rates..."
    
    # Loop through different rates
    for RATE in 1M 2M 3M 4M 5M 6M 7M 8M 9M 10M; do
        echo "Testing with ${RATE}..."
        sudo ip netns exec ue1 iperf3 -c ${SERVER_IP} -p ${SERVER_PORT} -i 1 -t 1 -b ${RATE}
    done

    echo "Pausing traffic for ${OFF_DURATION} seconds..."
    sleep ${OFF_DURATION}
done
'''