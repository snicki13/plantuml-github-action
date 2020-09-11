#!/usr/bin/env bash

# expands the arguments in order to pass them to plantuml
ARGS=( "$@" )

plantuml $ARGS
