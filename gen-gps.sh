#!/bin/sh

GUILE_AUTO_COMPILE=0
export GUILE_AUTO_COMPILE

exec ${GUILE_BINARY:-guile} ./gen-gps.scm
