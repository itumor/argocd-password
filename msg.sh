#!/bin/bash

msg="rpc error: code = Unauthenticated desc = Invalid username or password"

if [[ "$msg" == *"rpc error: code = Unauthenticated desc = Invalid username or password"* ]]; then
  echo "The message contains the error 'rpc error: code = Unauthenticated desc = Invalid username or password'."
else
  echo "The message does not contain the error 'rpc error: code = Unauthenticated desc = Invalid username or password'."
fi
