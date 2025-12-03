#!/bin/bash

psql -U bobrnebobr -d postgres -f sessions/sessionA.sql > session_a.log &
PID_A=$!

psql -U bobrnebobr -d postgres -f sessions/sessionB.sql > session_b.log &
PID_B=$!

wait $PID_A
wait $PID_B

echo "Both sessions finished"