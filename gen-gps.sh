#!/bin/sh

GUILE_AUTO_COMPILE=0
export GUILE_AUTO_COMPILE

exec ${GUILE_BINARY:-guile} -s ./gen-gps.scm
