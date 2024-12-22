# import subprocess
# code added by Jawad
# #Small test script for running shell scripts
# cmd1 = ['sudo','./zmqtwoue_with_2slices.sh']
# shellscript = subprocess.Popen(cmd1, stdout=subprocess.PIPE,stderr=subprocess.STDOUT,stdin=subprocess.PIPE)
# stdout, stderr = shellscript.communicate()
# print(stdout)

import subprocess
import time

#def run_script(  , slice_name, share, throttle, throttle_period, throttle_share):
def run_script(script_name, slice_name, share, throttle, throttle_period, throttle_share):
    # Convert Python boolean to Bash true/false
    throttle_str = "true" if throttle else "false"
    
    # Run the shell script with arguments
    subprocess.run([
        "bash", script_name,
        #"bash", throttle.sh
        slice_name,
        str(share),
        throttle_str,
        str(throttle_period),
        str(throttle_share)
    ])

# Example usage
if __name__ == "__main__":
    # Customize parameters
    run_script("zmqtwoue_with_2slices_1.sh","fast-2", 0, False, 900, 10)
    time.sleep(5)
    #run_script("zmqtwoue_with_2slices_1","fast-2", 1024, True, 1800, 20)
