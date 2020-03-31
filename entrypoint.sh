
  # Login user
  /usr/bin/expect -c "
  set timeout 20
  spawn jotta-cli login
  expect \"accept license (yes/no): \" {send \"yes\n\"}
  expect \"Personal login token: \" {send \"$JOTTA_TOKEN\n\"}
  expect \"Devicename*: \" {send \"$JOTTA_DEVICE\n\"}
  expect eof
  "

# add backup volume
  jotta-cli add /backup/

else

  echo "User is logged in"

fi

  # load ignore file
  if [ -f /config/ignorefile ]; then
    echo "loading ignore file"
    jotta-cli ignores set /config/ignorefile
  fi

  # set scan interval
  echo "Setting scan interval"
  jotta-cli config set scaninterval $JOTTA_SCANINTERVAL

# put tail in the foreground, so docker does not quit
jotta-cli tail

exec "$@"