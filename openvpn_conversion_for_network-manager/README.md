# openvpn_conversion_for_network-manager
This folder contains a script that can be used to download *ovpn files from common vpn providers, 
extract certs from the files as needed for network-manager, and extract username-passwords for convenience with OpenVPN.

Please fork and submit pull requests if you have any useful modifications!
The license (Up a directory) does not require it, but it's good practice anyway!

USAGE:
	update_vpnprovidersinfo_and_extract_certs.sh [output_dir [temp_dir]]
	
WHERE:
-output_dir is a path that is writeable by the executor of the process & stores only the files necessary for OpenVPN to work
-temp_dir is a path that is writeable by the executor of the process & stores temporary files
-if temp_dir is not provided, the script path is used
-if output_dir is not provided, the script path is used
