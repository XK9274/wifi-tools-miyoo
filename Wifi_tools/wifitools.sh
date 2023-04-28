miyoodir=/mnt/SDCARD/miyoo
wpa_cli=/customer/app
export LD_LIBRARY_PATH="/config/lib:$miyoodir/lib:$sysdir/lib:$sysdir/lib/parasyte"

while true; do
	echo -e "Wifi Tools for MMP+\n"

	echo -e "Select from below:\n" # Offer up a selection of methods/tools
	echo "1. Add new network and connect"
	echo "2. WPS connection (Wps button connection)"
	echo "3. Get status (Lists status of connected networks)"
	echo "4. Scan networks (Shows all networks nearby)"
	echo "5. Show networks configured in wpa_supplicant.conf"
	echo "6. Store a network in wpa_supplicant.conf"
	echo "7. Connect to stored network in wpa_supplicant.conf"
	echo "8. Remove a network from wpa_supplicant.conf"
	echo "9. Reset wpa_supplicant.conf"
	echo "0. Exit script"
	echo -e "\n"
	read -p "Enter your choice: " method_choice

	if [ "$method_choice" -eq 1 ]; then # Choice 1 of manual connection
		
		read -p "Enter the SSID: " new_ssid
		read -p "Enter the password: " new_password
		new_id=$($wpa_cli/wpa_cli -i wlan0 add_network | tail -n 1)
		$wpa_cli/wpa_cli -i wlan0 set_network $new_id ssid "\"$new_ssid\""
		$wpa_cli/wpa_cli -i wlan0 set_network $new_id psk "\"$new_password\""
		$wpa_cli/wpa_cli -i wlan0 enable_network $new_id
		$wpa_cli/wpa_cli -i wlan0 save_config
		echo "New network added to the configuration file with ID $new_id"

		echo "Connecting..."
		$wpa_cli/wpa_cli disable_network all
		$wpa_cli/wpa_cli select_network $new_id
		$wpa_cli/wpa_cli enable_network $new_id
		$wpa_cli/wpa_cli save_config
		echo "Asking for an IP..."
		udhcpc -i wlan0 -s /etc/init.d/udhcpc.script
		sleep 5

		while true; do
			IP=$(ip route get 1 | awk '{print $NF;exit}')
			if [ -z "$IP" ]; then
				echo -e "\nFailed to connect to $selected_ssid."
				echo -e "\nPress start to continue..."
				read -n 1 -s
				break
			else 
				echo -e "\nConnected to $new_ssid"
				if ping -q -c 4 -W 1 8.8.8.8 >/dev/null; then
					echo -e "\nInternet access is available."
					echo -e "\nPress start to continue..."
					read -n 1 -s
					break
				else
					echo -e "\nInternet access is not available yet."
					sleep 1
					break
				fi
			fi
			sleep 1
		done

	elif [ "$method_choice" -eq 2 ]; then # Choice 2 of WPS connection
		echo "Select WPS connection method:"
		echo "1. Basic WPS"
		echo "2. Pin WPS"
		read -p "Enter your choice (1 or 2): " wps_choice

		if [ "$wps_choice" -eq 1 ]; then
			wps_method="wps_pbc"
			echo "Scanning for available Wi-Fi networks..."
			$wpa_cli/wpa_cli scan
			sleep 1
			networkswps=$(echo "$($wpa_cli/wpa_cli scan_results | tail -n+3)" | awk '{print $NF " " $1}' | sed 's/\[.*\]//g')
			wait $!

			echo "Available networks:"
			echo ""
			echo "$networkswps" | awk '{print NR". "$0}'
			echo ""

			echo -e "\nPress your WPS button now and select from the above numbers\n"
			read -p "Enter the number of the network you want to connect to: " selected_number
			selected_bssid=$(echo "$networkswps" | awk "NR==$selected_number{print \$2}")

			echo "Initiating WPS connection to $selected_bssid using $wps_method..."
			$wpa_cli/wpa_cli $wps_method $selected_bssid
			
			
			echo "Waiting for connection..."
			
			sleep 5
			IP=$(ip route get 1 | awk '{print $NF;exit}')
			if [ -z "$IP" ]; then
				echo -e "\nUnable to connect to the network."
			else
				echo -e "\nConnected with IP of $IP"
			fi
			
		elif [ "$wps_choice" -eq 2 ]; then
			wps_method="wps_pin"
			read -p "What is your WPS Pin?" wps_pin
			echo "Scanning for available Wi-Fi networks..."
			$wpa_cli/wpa_cli scan
			networkswps=$(echo "$($wpa_cli/wpa_cli scan_results | tail -n+3)" | awk '{print $NF " " $1}' | sed 's/\[.*\]//g')

			echo "Available networks:"
			echo ""
			echo "$networkswps" | awk '{print NR". "$0}'
			echo ""

			echo -e "\nPress your WPS button now and select from the above numbers\n"
			read -p "Enter the number of the network you want to connect to: " selected_number
			selected_bssid=$(echo "$networkswps" | awk "NR==$selected_number{print \$2}")

			echo "Initiating WPS connection to $selected_bssid using $wps_method..."
			$wpa_cli/wpa_cli $wps_method $selected_bssid $wps_pin
			
			sleep 5
			IP=$(ip route get 1 | awk '{print $NF;exit}')
			
			if [ -z "$IP" ]; then
			
				echo "Unable to connect to the network."
			else
				echo "Connected with IP of $IP"
			fi
		else
			echo "Invalid choice. Exiting."
			exit 1
		fi
	elif [ "$method_choice" -eq 3 ]; then # Show status
		echo -e "\n"
		$wpa_cli/wpa_cli status
		echo -e "\nPress start to continue..."
		read -n 1 -s
		
	elif [ "$method_choice" -eq 4 ]; then # Show local scan
		echo -e "\n"
		$wpa_cli/wpa_cli scan
		echo "$($wpa_cli/wpa_cli scan_results | tail -n+3)" | awk '{print $NF " " $1}' | sed 's/\[.*\]//g'
		echo -e "\nPress start to continue..."
		read -n 1 -s

	elif [ "$method_choice" -eq 5 ]; then # Show Networks in supplicant.conf
		echo -e "\n"
		$wpa_cli/wpa_cli -i wlan0 list_networks
		echo -e "\nPress start to continue..."
		read -n 1 -s
		
	elif [ "$method_choice" -eq 6 ]; then # Store a new network
		echo -e "\n"
		read -p "Enter the SSID: " new_ssid
		read -p "Enter the password: " new_password
		new_id=$($wpa_cli/wpa_cli -i wlan0 add_network | tail -n 1)
		$wpa_cli/wpa_cli -i wlan0 set_network $new_id ssid "\"$new_ssid\""
		$wpa_cli/wpa_cli -i wlan0 set_network $new_id psk "\"$new_password\""
		$wpa_cli/wpa_cli -i wlan0 enable_network $new_id
		$wpa_cli/wpa_cli -i wlan0 save_config
		echo "New network added to the configuration file with ID $new_id"
		
	elif [ "$method_choice" -eq 7 ]; then # Connect to a stored network
		echo -e "\n"
		unset IP
		echo "Listing available Wi-Fi networks..."
		networks=$($wpa_cli/wpa_cli -i wlan0 list_networks | tail -n+2 | awk '{print $1 " " $2}' | sed 's/\[.*\]//g')
		echo "Available networks:"
		echo ""
		echo "$networks" | awk '{print NR-1". "$0}'
		echo ""
		read -p "Enter the number of the network you want to connect to: " selected_number
		selected_id=$(echo "$networks" | awk "NR==$selected_number+1{print \$1}")
		selected_ssid=$(echo "$networks" | awk "NR==$selected_number+1{print \$2}")

		echo "Selected network: ID=$selected_id SSID=$selected_ssid"
		
		echo "Connecting to $selected_ssid..."
		$wpa_cli/wpa_cli disable_network all
		$wpa_cli/wpa_cli select_network $selected_id
		$wpa_cli/wpa_cli enable_network $selected_id
		$wpa_cli/wpa_cli save_config
		echo "Asking for an IP"
		udhcpc -i wlan0 -s /etc/init.d/udhcpc.script
		sleep 5
		
		while true; do
			IP=$(ip route get 1 | awk '{print $NF;exit}')
			if [ -z "$IP" ]; then
				echo "Failed to connect to $selected_ssid."
				echo -e "\nPress start to continue..."
				read -n 1 -s
				break
			else 
				echo -e "\nConnected to $selected_ssid"
				if ping -q -c 4 -W 1 8.8.8.8 >/dev/null; then
					echo -e "\nInternet access is available."
					echo -e "\nPress start to continue..."
					read -n 1 -s
					break
				else
					echo -e "\nInternet access is not available yet."
					sleep 1
					break
				fi
			fi
			sleep 1
		done
	elif [ "$method_choice" -eq 8 ]; then # Remove a single entry from wpa_supplicant.conf
		echo -e "\n"
		echo "Current network configurations in wpa_supplicant.conf:"
		$wpa_cli/wpa_cli -i wlan0 list_networks
		read -p "Enter the SSID of the network you want to remove:" del_id
		wpa_cli -i wlan0 remove_network $del_id
		echo "Network with id $del_id removed."
		$wpa_cli/wpa_cli -i wlan0 list_networks
		echo -e "\nPress start to continue..."
		read -n 1 -s
		
	elif [ "$method_choice" -eq 9 ]; then # Remove wpa_supplicant.conf
		echo -e "\n"
		echo "Warning: This will delete ALL currently stored WiFi networks."
		read -p "Are you sure you want to do this? (y/n) " answer
		if [ "$answer" != "y" ]; then
			echo "Aborted. Your WiFi networks were not deleted."
			echo -e "\nPress start to continue..."
			read -n 1 -s
		else
			pkill -9 wpa_supplicant
			wpa_cli -i wlan0 remove_network all
			echo "Done, your wpa_supplicant.conf file has been reset"
			echo "Wifi has been shut down, use option 1 or 6 to add a new network"
			$wpa_cli/wpa_cli save_config
			$wpa_cli/wpa_cli terminate
			$miyoodir/app/wpa_supplicant -B -D nl80211 -iwlan0 -c /appconfigs/wpa_supplicant.conf
			echo -e "\nPress start to continue..."
			read -n 1 -s
			
		fi

	elif [ "$method_choice" -eq 0 ]; then # Remove wpa_supplicant.conf
		break
	fi
	
done