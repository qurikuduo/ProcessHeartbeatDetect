# ProcessHeartbeatDetect
using linux internal shell command: ps, uptime to detect   the specific process is exist or not. Then using curl to post a json  String to the server.

# How to use:
* Modify this script according to your own needs ( Such as server URL, Server ID, curl's parameter etc. ).
* Upload this script to your server which your process runs on it.
* tail -100f log file to see if the script is running as your purpose
