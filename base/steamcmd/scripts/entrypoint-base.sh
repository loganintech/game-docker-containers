#!/bin/bash
# Base entrypoint script for native Linux game servers
# This script executes the command passed to the container

set -e

exec "$@"
