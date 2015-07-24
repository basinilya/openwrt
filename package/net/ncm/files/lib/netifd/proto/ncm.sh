#!/bin/sh

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_ncm_init_config() {
	no_device=1
	available=1
	proto_config_add_string "device"
	proto_config_add_string "mode"
	proto_config_add_string "apn"
	proto_config_add_string "pincode"
	proto_config_add_string "authtype"
	proto_config_add_string "delay"
	proto_config_add_string "username"
	proto_config_add_string "password"
}

proto_ncm_setup() {

	local interface="$1"
	local iface="$JSON_ARRAY1_1"

	local device mode apn pincode authtype delay username password
	local cardinfo brand model driver
	local dialupscript modescript initscript

	json_get_vars device mode apn pincode delay authtype username password

	[ -e "$device" ] || {
		proto_set_available "$interface" 0
		return 1
	}

	cardinfo=$(gcom -d "$device" -s /etc/gcom/ncm/getcardinfo.gcom)
	brand=$(echo "$cardinfo" | grep "vendor '" | awk '{ gsub("\x27", ""); print $2; }')
	model=$(echo "$cardinfo" | grep "model '" | awk '{ gsub("\x27", ""); print $2; }')
	driver=$(echo "$cardinfo" | grep "driver '" | awk '{ gsub("\x27", ""); print $2; }')	

	[ "$driver" = "-" ] && {
		logger Detected $brand $model. Device is not supported.
		proto_notify_error "$interface" UNSUPPORTED_DEVICE
		proto_block_restart "$interface"
		return 1
	}

	initscript="/etc/gcom/ncm/initscripts/$driver.gcom"
	modescript="/etc/gcom/ncm/setmode/$driver.gcom"
	dialupscript="/etc/gcom/ncm/connect/$driver.gcom"

	logger Detected $brand $model. Using driver $driver.

	if [ -n "$pincode" ]; then
		PINCODE="$pincode" gcom -d "$device" -s /etc/gcom/setpin.gcom || {
			proto_notify_error "$interface" PIN_FAILED
			proto_block_restart "$interface"
			return 1
		}
	fi

	[ -e "$initscript" ] &&
		gcom -d "$device" -s "$initscript"

	[ "$authtype" = "pap" ] && authtype=1 || {
		[ "$authtype" = "chap" ] && authtype=2 || {
			[ "$authtype" = "cleartext" ] && authtype=0 ||
				authtype=-1
		}
	}

	[ -e "$modescript" ] &&
		MODE="$mode" gcom -d "$device" -s "$modescript"

	[ -e "$dialupscript" ] || {
		logger Dial-up script for driver $driver is missing.
		proto_notify_error "$interface" SCRIPT_MISSING
		proto_block_restart "$interface"
		return 1
	}

	USE_DISCONNECT="0" USE_APN="$apn" USE_AUTHTYPE="$authtype" USE_USERID="$username" USE_PASSWORD="$password" \
		gcom -d "$device" -s "$dialupscript"

	[ ! -z "${delay##*[!0-9]*}" ] && [ "$delay" != "0" ] && /bin/sleep $delay

	logger -p daemon.info -t "ncm[$$]" "Connected, notifying netifd"
	proto_init_update "$iface" 1
	proto_send_update "$interface"

	return 0
}

proto_ncm_teardown() {
	local interface="$1"
	local iface="$2"
	local device apn cardinfo driver dialupscript

	json_get_vars device apn

	cardinfo=$(gcom -d "$device" -s /etc/gcom/ncm/getcardinfo.gcom)
	driver=$(echo "$cardinfo" | grep "driver '" | awk '{ gsub("\x27", ""); print $2; }')
	dialupscript="/etc/gcom/ncm/connect/$driver.gcom"

	[ "$driver" == "-" ] || 
		[ -e "$device" ] && 
			[ -e "$dialupscript" ] && {
				USE_DISCONNECT="1" USE_APN="$apn" gcom -d "$device" -s "$dialupscript"
			}

	proto_init_update "$iface" 0
	proto_send_update "$interface"
}

add_protocol ncm
