xterm -e ./script/server &
xterm -e ruby lib/flint_cron.rb &
sleep 20
xterm -e ruby lib/flint_fe_wxruby.rb &
