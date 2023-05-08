# wifi-tools-miyoo
A tool script for managing wifi networks on the Miyoo Mini Plus

## Boots the script in the simple terminal app included in OnionOS

## Controls

"How to use:\n"
"  ARROWS: select key from keyboard\n"
"  A:  press key\n"
"  B:  toggle key (useful for shift/ctrl...)\n"
"  L1: shift\n"
"  R1: backspace\n"
"  Y:  change keyboard location (top/bottom)\n"
"  X:  show / hide keyboard\n"
"  START:    enter\n"
"  SELECT:   tab\n"
"  L2:       left\n"
"  R2:       right\n"
"  MENU:     quit\n\n"

## Menus

1. Add new network and connect - 						Adds a new network and immediatley attempts to connect - Will always be the next ID
2. WPS connection (Wps button connection) - 			Attempts to connect with the WPS function
3. Get status (Lists status of connected network) - 	Gets status of current network
4. Scan networks (Shows all networks nearby) - 			Scans for nearby networks
5. Show networks configured in wpa_supplicant.conf - 	Shows currently stored networks
6. Store a network in wpa_supplicant.conf - 			Stores a new network - Will store as the next available ID
7. Connect stored network in wpa_supplicant.conf - 		Allows hot-switching between networks (persistent over reboots) - Select based on ID
8. Remove a network from wpa_supplicant.conf - 			Removes a single stored entry - Removes an ID
9. Reset wpa_supplicant.conf -							Completely deletes all stored networks - Removes all ID's
0. Exit script - quits



![Wifi_tools_001](https://user-images.githubusercontent.com/47260768/236643458-86f9faed-4522-4afb-9972-57474f6f640a.png)
![MainUI_004](https://user-images.githubusercontent.com/47260768/235266020-7bcca519-265e-410f-bc6a-3e8ac3960f3d.png)


## Usage

Copy the Wifitools folder to the App folder on your SD
Browse to the Wifitools app and run
or
Copy the wifitools.sh script to your MMP to a known location
With either putty or the built in app (terminal on Onion os) start the script with sh wifitools.sh

Logo from pngtree.com
