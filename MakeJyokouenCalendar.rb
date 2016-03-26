#! ruby -Ku
# encoding: utf-8

require 'rubygems'
require 'mechanize'
require 'nkf'
require 'fileutils'
require 'date'
require 'common'


def selectMonth()

	strMonthCurt = Date.new TIMESTMP[0..3].to_i,TIMESTMP[4..5].to_i,TIMESTMP[6..7].to_i
	strMonthPrev = strMonthCurt << 1
	strMonthPrev = strMonthPrev.to_s[0..3] + strMonthPrev.to_s[5..6]
	strMonthNext = strMonthCurt >> 1
	strMonthNext = strMonthNext.to_s[0..3] + strMonthNext.to_s[5..6]
	strMonthCurt = strMonthCurt.to_s[0..3] + strMonthCurt.to_s[5..6]

	connection = Mysql::new(DBHOST, DBUSER, DBPASS , DBSCHEMA)
	connection.charset = "utf8"
	chkMonthPrev = connection.query("SELECT Count(CALENDAR_YM) FROM T_JYOKOUEN_CALENDAR WHERE CALENDAR_YM = '" + strMonthPrev + "' AND RCD_KBN = 0")
	chkMonthCurt = connection.query("SELECT Count(CALENDAR_YM) FROM T_JYOKOUEN_CALENDAR WHERE CALENDAR_YM = '" + strMonthCurt + "' AND RCD_KBN = 0")
	chkMonthNext = connection.query("SELECT Count(CALENDAR_YM) FROM T_JYOKOUEN_CALENDAR WHERE CALENDAR_YM = '" + strMonthNext + "' AND RCD_KBN = 0")
	connection.close

	APPEND_LOGFILE('・当月と前後1ヶ月をSELECT')
	chkMonthPrev = chkMonthPrev.fetch_row().join("").to_i
	APPEND_LOGFILE("#{strMonthPrev} #{chkMonthPrev}")
	chkMonthCurt = chkMonthCurt.fetch_row().join("").to_i
	APPEND_LOGFILE("#{strMonthCurt} #{chkMonthCurt}")
	chkMonthNext = chkMonthNext.fetch_row().join("").to_i
	APPEND_LOGFILE("#{strMonthNext} #{chkMonthNext}")


	#この2つ分、最新+1が無い場合は-1それもないなら最新の一か月分のみ
	if chkMonthNext == 1 then
		aryMakeIcalMonth = [strMonthCurt,strMonthNext]
	elsif chkMonthPrev == 1 then
		aryMakeIcalMonth = [strMonthPrev,strMonthCurt]
	else
		aryMakeIcalMonth = [strMonthCurt]
	end
	APPEND_LOGFILE('・データ作成対象月')
	APPEND_LOGFILE(aryMakeIcalMonth)
	
	return aryMakeIcalMonth
rescue => ex
	p ex
end

def deleteFile()
	File.delete(DATADIR + "JyokouenCalendar.ics")
rescue => ex
	APPEND_LOGFILE(ex)
end

def makeIcalData(aryMakeIcalMonth)

	#icalヘッダー書き込み
	filehdl = File.open(DATADIR + "JyokouenCalendar.ics","a+")
	filehdl.puts <<-'EOS'
BEGIN:VCALENDAR
METHOD:PUBLISH
VERSION:2.0
PRODID:-//nyctea.me//Manually//JP
CALSCALE:GREGORIAN
X-WR-TIMEZONE:Asia/Tokyo
X-WR-CALNAME:大阪城公園弓道場 - 行事予定表
X-WR-CALDESC:大阪城公園弓道場の月間行事予定表です。\n
 http://osakajo.kyudojo.info/link3.html \n
 午前 9:00～12:00 午後 13:00～17:00 夜間 18:00～21:00\n
 ○:全面使用可 ▲:半面使用可 ×:全面使用不可\n
	EOS
	filehdl.puts " 更新日時:" + TIMESTMP[0..3] + "/" + TIMESTMP[4..5] + "/" + TIMESTMP[6..7] + " " + TIMESTMP[8..9] + ":" + TIMESTMP[10..11] + ":" + TIMESTMP[12..13] + "\\n"

	#月ごとにVEVENT作成
	aryMakeIcalMonth.each do|strMonth|
		connection = Mysql::new(DBHOST, DBUSER, DBPASS , DBSCHEMA)
		connection.charset = "utf8"
		result0 = connection.query("SELECT * FROM T_JYOKOUEN_CALENDAR WHERE CALENDAR_YM = '" + strMonth + "' AND RCD_KBN = 0")
		result1 = connection.query("SELECT * FROM T_JYOKOUEN_CALENDAR WHERE CALENDAR_YM = '" + strMonth + "' AND RCD_KBN = 1")
		connection.close

		calendarArry0 = []
		calendarArry1 = []
		result0.each do |res0|
		  calendarArry0 = res0
		end
		result1.each do |res1|
		  calendarArry1 = res1
		end

		#p calendarArry0
		#p calendarArry1

		begin
		cnt = 0
		cntDay = 1
		cntColumn = 2
		while cnt <= 32 do
			break if cntDay == 32
=begin
			break if /[0-9]{17}/ =~ calendarArry0[cntColumn]
			break if !calendarArry0[cntColumn]
			break if !calendarArry1[cntColumn]
=end
			strDTEND = strMonth + sprintf("%02d",cntDay)
			strDTEND = Date.parse(strDTEND) + 1
			strDTEND = strDTEND.strftime("%Y%m%d")
			strDTEND = strDTEND.to_s

			filehdl.puts "BEGIN:VEVENT"
			filehdl.puts "UID:"
			filehdl.puts "DTSTAMP:" + calendarArry0[33][0..7] + "T" + calendarArry0[33][8..13]
			filehdl.puts "SUMMARY:" + calendarArry0[cntColumn]
			filehdl.puts "DESCRIPTION:" + calendarArry1[cntColumn]
			filehdl.puts "DTSTART;VALUE=DATE:" + strMonth + sprintf("%02d",cntDay) + ";"
			filehdl.puts "DTEND;VALUE=DATE:" + strDTEND + ";"
			filehdl.puts "CLASS:PUBLIC"
			filehdl.puts "TRANSP:TRANSPARENT"
			filehdl.puts "STATUS:CONFIRMED"
			filehdl.puts "END:VEVENT"
			cnt += 1
			cntDay += 1
			cntColumn += 1
		end
		rescue => ex
			if cntDay == 32 then

			else
				#p ex
				APPEND_LOGFILE('・小の月 (' + strDTEND + ')')
			end
		end
	end
	filehdl.puts ("END:VCALENDAR")
	filehdl.close
rescue => ex
	p ex
	APPEND_LOGFILE('・ファイル作成異常終了')
	PARCON_SQL.abnormal(aryMakeIcalMonth.join(','), __FILE__.gsub(/^.*\//,'') )
else
	APPEND_LOGFILE('・ファイル作成正常終了')
	PARCON_SQL.normal(aryMakeIcalMonth.join(','), __FILE__.gsub(/^.*\//,'') )
end

def moveIcsForHost()
#	FileUtils.cp(DATADIR + "JyokouenCalendar.ics", SHAREDIR + "JyokouenCalendar.ics")
	FileUtils.cp(DATADIR + "JyokouenCalendar.ics", DATADIR + "JyokouenCalendar_bkup.ics")
	FileUtils.cp(DATADIR + "JyokouenCalendar.ics", WWWDIR + "icalendar/JyokouenCalendar.ics")
rescue => ex
	APPEND_LOGFILE("・ファイル移動異常終了")
	APPEND_LOGFILE(ex)
else
	PARCON_SQL.normal('JyokouenCalendar.ics', __FILE__.gsub(/^.*\//,'') )
	APPEND_LOGFILE("・ファイル移動正常終了")
end

#MAIN
aryMakeIcalMonth = selectMonth()

deleteFile()

makeIcalData(aryMakeIcalMonth)

moveIcsForHost()

