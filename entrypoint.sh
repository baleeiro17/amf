#!/bin/sh

sed -i "s/{{AMF_IP}}/$AMF_IP/" ../config/amfcfg.conf
sed -i "s/{{NRF_URI}}/$NRF_URI/" ../config/amfcfg.conf

./amf -amfcfg config/amfcfg.conf