AndroidCarPCScripts
===================

Scripts for some CarPC automation on rooted Android CarPC based on RK3288 chipset (Rikomagic MK902II)

* init.d - directory contains GPS and ELM327 scanner module initialization scripts run by init.d and call for scripts from /etc/scripts directory
* scripts - custom scripts directory to be put in /etc. Placed separately by reason
	* start.sh - starts all scripts in correct order
	* gps-time.sh - sets system time from GPS data
	* obd.sh - reads PID values from ELM327 scanner and stores to file. To be used with WordWidget or TextDisplayWidget
	* send-coord.sh - send coordinates of car on boot (after succesful GPS init). Uses qpush.me. User account data is to be updated to your own.
	* stop-park.sh - unparks your car from Moscow Parking Zone on boot. User account data is to be updated to your own.

