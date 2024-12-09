# import subprocess
# code added by Jawad
# #Small test script for running shell scripts
# cmd1 = ['sudo','./zmqtwoue_with_2slices.sh']
# shellscript = subprocess.Popen(cmd1, stdout=subprocess.PIPE,stderr=subprocess.STDOUT,stdin=subprocess.PIPE)
# stdout, stderr = shellscript.communicate()
# print(stdout)

import subprocess

def run_script(slice_name, share, throttle, throttle_period, throttle_share):
    # Convert Python boolean to Bash true/false
    throttle_str = "true" if throttle else "false"
    
    # Run the shell script with arguments
    subprocess.run([
        "bash", "script.sh",
        slice_name,
        str(share),
        throttle_str,
        str(throttle_period),
        str(throttle_share)
    ])

# Example usage
if __name__ == "__main__":
    # Customize parameters
    run_script("fast-1", 1024, True, 1800, 20)
    run_script("fast-2", 512, False, 900, 10)
