#!/bin/bash

i=0
tests=()
IFS=',' read -ra flavors <<< "$CIRCLECI_FLAVORS"
for flavor in $flavors
do
  if [ $(($i % $CIRCLE_NODE_TOTAL)) -eq $CIRCLE_NODE_INDEX ]
  then
    rake ci:run_circle[$flavor]
  fi
  ((i++))
done
