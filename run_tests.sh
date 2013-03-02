#!/bin/bash -el

echo "Starting tests..."

# BEGIN TIMEOUT #
TIMEOUT=2700 # 45 minutes
BOSSPID=$$
(
  sleep $TIMEOUT
  echo
  echo "Test timed out after $TIMEOUT seconds."
  echo
  kill -9 $BOSSPID
  cat adb_logcat.log
)&
TIMERPID=$!
echo "PIDs: Boss: $BOSSPID, Timer: $TIMERPID"

trap "echo killing timer ; kill -9 $TIMERPID" EXIT
# END TIMEOUT #

if [ ! $(command -v ant) ] ; then
  if [ -e /etc/profile.d/ant.sh ] ; then
    . /etc/profile.d/ant.sh
  else
    echo Apache ANT is missing!
    exit 2
  fi
fi
ant -version

if [ "$RUBY_IMPL" != "" ] ; then
  if [ -e /etc/profile.d/rvm.sh ] ; then
    . /etc/profile.d/rvm.sh
  fi
  if [ ! $(command -v rvm) ] ; then
    echo RVM is missing!
    exit 2
  fi
  rvm --version
  unset JRUBY_HOME
  rvm install $RUBY_IMPL
  rvm use $RUBY_IMPL
  echo -n
fi

export NOEXEC_DISABLE=1
rake --trace clean
rake --trace test $*
