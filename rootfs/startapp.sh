#!/bin/sh
#!/usr/bin/with-contenv sh

set -u # Treat unset variables as an error.

trap "exit" TERM QUIT INT
trap "kill_rvn" EXIT

log() {
    echo "[rvnsupervisor] $*"
}

export HOME=/storage

getpid_rvn() {
    PID=UNSET
    if [ -f /storage/.raven/ravend.pid ]; then
        PID="$(cat /storage/.raven/ravend.pid)"
        # Make sure the saved PID is still running and is associated to
        # ravencoin.
        if [ ! -f /proc/$PID/cmdline ] || ! cat /proc/$PID/cmdline | grep -qw "raven-qt"; then
            PID=UNSET
        fi
    fi
    if [ "$PID" = "UNSET" ]; then
        PID="$(ps -o pid,args | grep -w "raven-qt" | grep -vw grep | tr -s ' ' | cut -d' ' -f2)"
    fi
    echo "${PID:-UNSET}"
}

is_rvn_running() {
    [ "$(getpid_rvn)" != "UNSET" ]
}

start_rvn() {
	exec raven-qt
}

kill_rvn() {
    PID="$(getpid_rvn)"
    if [ "$PID" != "UNSET" ]; then
        log "Terminating raven-qt..."
		raven-cli -datadir=/storage/.raven stop
		sleep 8
        kill $PID
        wait $PID
    fi
}

if ! is_rvn_running; then
    log "raven-qt not started yet.  Proceeding..."
    start_rvn
fi

RVN_NOT_RUNNING=0
while [ "$RVN_NOT_RUNNING" -lt 5 ]
do
    if is_rvn_running; then
        RVN_NOT_RUNNING=0
    else
        RVN_NOT_RUNNING="$(expr $RVN_NOT_RUNNING + 1)"
    fi
    sleep 1
done

log "raven-qt no longer running.  Exiting..."