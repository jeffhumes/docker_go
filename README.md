Prerequisites:
	- you must be logged in as dockrusr
		-- 'sudo su - dockrusr'
1. Edit go.conf
	- update the instance name variable
	- update the port numbers to meet your requirements

2. Run update-ports
	- ./go update-ports
		-- this will update all of the necessary files with the updated port numbers

3. Run the docker instance build
	- ./go build
		- this will run all of the commands in Dockerfile to create the instance

4. Run the 'go' script
	use this command: ./go start

