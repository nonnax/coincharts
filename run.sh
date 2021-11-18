#!/usr/bin/env bash
# Id$ nonnax 2021-11-14 15:04:36 +0800
echo "loading... "
echo "(ctrl+c to stop)"
./update_loop.rb & rackup && fg
