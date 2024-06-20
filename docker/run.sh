#!/bin/bash

/root/gaianet/bin/gaianet init
/root/gaianet/bin/gaianet start
tail -f /root/gaianet/log/start-llamaedge.log
