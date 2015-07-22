#! ruby -Ku
# encoding: utf-8

require 'rubygems'
require 'common'

begin
	puts 'GetJyokouenCalendar.rb 起動'
	load 'GetJyokouenCalendar.rb'
rescue => ex
	p ex
	puts 'GetJyokouenCalendar.rb エラー'
else
	puts 'GetJyokouenCalendar.rb 正常終了'
end

begin
	puts 'MakeJyokouenCalendar.rb 起動'
	load 'MakeJyokouenCalendar.rb'
rescue => ex
	p ex
	puts 'MakeJyokouenCalendar.rb エラー'
else
	puts 'MakeJyokouenCalendar.rb 正常終了'
end
