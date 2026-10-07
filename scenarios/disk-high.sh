#!/bin/bash
TMPFILE=/tmp/obs_disk_fill_$$
SIZE_MB=${1:-2000}

echo "Writing ${SIZE_MB}MB temp file to fill disk..."
echo "   Watch Grafana: Disk usage will increase"
echo "   File: $TMPFILE"

dd if=/dev/zero of=$TMPFILE bs=1M count=$SIZE_MB status=progress

echo "   File written. Press ENTER to delete it and recover disk space."
read

rm -f $TMPFILE
echo "Disk space recovered -- alert should resolve in ~1 minute"
