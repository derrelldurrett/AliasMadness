require 'time'

module DebugLogger
  def log lines
    trace = caller.to_a
    t = Time.now.httpdate
    write_lines(lines, t)
    write_lines([trace.first, trace.second, trace.third, trace.fourth, trace.fifth], t)
  end

  private

  def write_lines(list, t)
    list.each {|line| puts "#{t}: #{line}"}
  end
end