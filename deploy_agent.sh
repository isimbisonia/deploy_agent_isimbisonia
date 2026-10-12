#!/bin/bash
deploy_project() {
	echo "DEPLOY IS SELECTED"
}

run_project() {
	echo "RUN IS SELECTED"
}

archieve_logs() {
	echo "ARCHIEVE IS  SELECTED"
}


while true; do
	echo ""
	echo "===================="
	echo "  ATTENDANCE TRACKER -DEPLOY AGENT"
	echo "==================="
	echo "1) Deploy the application"
	echo "2) Run the application"
	echo "3) Archive the log files"
	echo "4) Exit"
	read -p "Choose an option [1-4]: " choice


	case $choice in 
		1)deploy_project ;;
		2)run_project ;;
		3)archieve_logs ;;
		4)echo "Goodbye!"; exit 0 ;;
		*)echo " YOU ENTERED INVALID OPTION.PLEASE ENTER 1,2,3,4" ;;
	esac
done
