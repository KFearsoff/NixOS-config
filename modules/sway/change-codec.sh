#!/bin/sh

CARD_NAME="bluez_card.E8_AB_FA_3B_C5_8C"
MIC_CODEC="headset-head-unit-msbc"
HQ_CODEC="a2dp-sink-sbc_xq"

CURRENT_PROFILE=$(pactl --format=json list cards | jq -r ".[] | select(.name == \"$CARD_NAME\") | .active_profile")

case $CURRENT_PROFILE in
$MIC_CODEC)
	pactl set-card-profile $CARD_NAME $HQ_CODEC
	;;
$HQ_CODEC)
	pactl set-card-profile $CARD_NAME $MIC_CODEC
	;;
*)
	echo "unknown codec: $CURRENT_PROFILE"
	;;
esac
