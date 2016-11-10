#!/bin/bash
#CentOS #jkhondhu - lrsupport - DataIndexer

echo "Creating output temp dir..."
OUTPUT_DIR=/tmp/$(hostname)-$(date +%F-%H%M%S)
mkdir -p $OUTPUT_DIR/logs

echo "Copying conf files..."
cp -r /usr/local/logrhythm/configserver/conf $OUTPUT_DIR

echo "Copying elasticsearch logs..."
cp /var/log/elasticsearch/* $OUTPUT_DIR/logs

echo "Copying component logs..."
cp /var/log/persistent/* $OUTPUT_DIR/logs

echo "Creating $OUTPUT_DIR.tgz..."
tar cfz $OUTPUT_DIR.tgz -C $OUTPUT_DIR .

if [ -f $OUTPUT_DIR.tgz ]; then
    echo "Deleting $OUTPUT_DIR"
    rm -rf $OUTPUT_DIR
fi
