#!/bin/sh

stop()
{
   echo "stop" 
   pkill -TERM -f "webserver@127.0.0.1" && echo "Process has been terminated"
   pkill -KILL -f "webserver@127.0.0.1" && echo "Process has been killed"
}

start()
{
    echo "start"
    erl -pa ebin -pa deps/*/ebin -s webserver start $COUNT -kernel error_logger false -boot start_sasl -noinput -detached -name webserver@127.0.0.1 -config chat.config
}

$@
