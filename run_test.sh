#!/usr/bin/env bash

RESTY_ARGS="-I src" # remove it when using the luarocks

resty ${RESTY_ARGS} busted_runner.lua
