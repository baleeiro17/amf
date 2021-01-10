#!/bin/sh

sed -i "s/{{AMF_IP}}/$AMF_IP/" ../config/amfcfg.conf
sed -i "s/{{NRF_URI}}/$NRF_URI/" ../config/amfcfg.conf


prep_term()
{
    unset term_child_pid
    unset term_kill_needed
    trap 'handle_term' TERM INT
}

handle_term()
{
    if [ "${term_child_pid}" ]; then
        kill -TERM "${term_child_pid}" 2>/dev/null
    else
        term_kill_needed="yes"
    fi
}

wait_term()
{
    term_child_pid=$!
    if [ "${term_kill_needed}" ]; then
        kill -TERM "${term_child_pid}" 2>/dev/null
    fi
    wait ${term_child_pid} 2>/dev/null
    trap - TERM INT
    wait ${term_child_pid} 2>/dev/null
}

prep_term
./amf -amfcfg ../config/amfcfg.conf &
wait_term
