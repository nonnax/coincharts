#!/usr/bin/env ruby
# Id$ nonnax 2021-11-13 20:43:57 +0800
loop do
  IO.popen('./update_csv.rb', &:read)
  sleep 60*15
end
