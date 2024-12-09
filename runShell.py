import subprocess

#Small test script for running shell scripts
cmd1 = ['sudo','./zmqtwoue_with_2slices.sh']
shellscript = subprocess.Popen(cmd1, stdout=subprocess.PIPE,stderr=subprocess.STDOUT,stdin=subprocess.PIPE)
stdout, stderr = shellscript.communicate()
print(stdout)