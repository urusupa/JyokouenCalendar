#! ruby -Ku
# encoding: utf-8

require 'rubygems'
require 'mechanize'
require 'nkf'
require 'fileutils'
require 'common'



#関数定義開始

def get_schedule(page)
	thisMonth = (page/:table)[0].inner_text
	thisMonth = thisMonth.gsub(/      /, ',')
	thisMonth = thisMonth.gsub(/( |\n)/, '')
	thisMonth = thisMonth.gsub(/,,,,,,,/, '')
	thisMonth = thisMonth.gsub(/日,曜,午前,午後,夜間,行　　事,/, '')

	strMonth = getTargetMonth(page)
	
	# 全角数字を半角数字に変換．nkf を使用
	thisMonth = NKF.nkf('-wZ0', thisMonth)
	wCalendarArry = []
	calendarArry = Array.new(94)
	wCalendarArry = thisMonth.split(",")
	wCalendarArry.map! {|elem| elem ? elem : ''}

	calendarArry[0] = strMonth
	posAry = 1
	cntDay = 1
	cntwCal = 0
	while cntDay <= 31 do
		calendarArry[posAry] = cntDay
		calendarArry[posAry+1] = wCalendarArry[cntwCal+2] + wCalendarArry[cntwCal+3] + wCalendarArry[cntwCal+4]
		calendarArry[posAry+2] = wCalendarArry[cntwCal+5]
		posAry += 3
		cntDay += 1
		cntwCal += 6
	end

	calendarArry.map! {|elem| elem ? elem : ''}
	#p calendarArry

	#DB接続
	connection = Mysql::new(DBHOST, DBUSER, DBPASS , DBSCHEMA)
	connection.charset = "utf8"
	result = connection.query("SELECT CALENDAR_YM FROM T_JYOKOUEN_CALENDAR WHERE CALENDAR_YM = '" + strMonth + "'")
	if result.num_rows() >= 1 then
		result = connection.prepare("UPDATE T_JYOKOUEN_CALENDAR SET D1 = ?,D2 = ?,D3 = ?,D4 = ?,D5 = ?,D6 = ?,D7 = ?,D8 = ?,D9 = ?,D10 = ?,D11 = ?,D12 = ?,D13 = ?,D14 = ?,D15 = ?,D16 = ?,D17 = ?,D18 = ?,D19 = ?,D20 = ?,D21 = ?,D22 = ?,D23 = ?,D24 = ?,D25 = ?,D26 = ?,D27 = ?,D28 = ?,D29 = ?,D30 = ?,D31 = ? ,RCD_KSN_TIME = ? WHERE CALENDAR_YM = ? AND RCD_KBN = ?")
		result.execute( calendarArry[2] , calendarArry[5] , calendarArry[8] , calendarArry[11] , calendarArry[14] , calendarArry[17] , calendarArry[20] , calendarArry[23] , calendarArry[26] , calendarArry[29] , calendarArry[32] , calendarArry[35] , calendarArry[38] , calendarArry[41] , calendarArry[44] , calendarArry[47] , calendarArry[50] , calendarArry[53] , calendarArry[56] , calendarArry[59] , calendarArry[62] , calendarArry[65] , calendarArry[68] , calendarArry[71] , calendarArry[74] , calendarArry[77] , calendarArry[80] , calendarArry[83] , calendarArry[86] , calendarArry[89] , calendarArry[92] , TIMESTMP , strMonth , '0' )
		result = connection.prepare("UPDATE T_JYOKOUEN_CALENDAR SET D1 = ?,D2 = ?,D3 = ?,D4 = ?,D5 = ?,D6 = ?,D7 = ?,D8 = ?,D9 = ?,D10 = ?,D11 = ?,D12 = ?,D13 = ?,D14 = ?,D15 = ?,D16 = ?,D17 = ?,D18 = ?,D19 = ?,D20 = ?,D21 = ?,D22 = ?,D23 = ?,D24 = ?,D25 = ?,D26 = ?,D27 = ?,D28 = ?,D29 = ?,D30 = ?,D31 = ? ,RCD_KSN_TIME = ? WHERE CALENDAR_YM = ? AND RCD_KBN = ?")
		result.execute( calendarArry[3] , calendarArry[6] , calendarArry[9] , calendarArry[12] , calendarArry[15] , calendarArry[18] , calendarArry[21] , calendarArry[24] , calendarArry[27] , calendarArry[30] , calendarArry[33] , calendarArry[36] , calendarArry[39] , calendarArry[42] , calendarArry[45] , calendarArry[48] , calendarArry[51] , calendarArry[54] , calendarArry[57] , calendarArry[60] , calendarArry[63] , calendarArry[66] , calendarArry[69] , calendarArry[72] , calendarArry[75] , calendarArry[78] , calendarArry[81] , calendarArry[84] , calendarArry[87] , calendarArry[90] , calendarArry[93] , TIMESTMP , strMonth , '1' )
	else
		result = connection.prepare("INSERT INTO T_JYOKOUEN_CALENDAR(CALENDAR_YM,RCD_KBN, D1,D2,D3,D4,D5,D6,D7,D8,D9,D10,D11,D12,D13,D14,D15,D16,D17,D18,D19,D20,D21,D22,D23,D24,D25,D26,D27,D28,D29,D30,D31,RCD_KSN_TIME,RCD_TRK_TIME) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
		result.execute( strMonth , 0 , calendarArry[2] , calendarArry[5] , calendarArry[8] , calendarArry[11] , calendarArry[14] , calendarArry[17] , calendarArry[20] , calendarArry[23] , calendarArry[26] , calendarArry[29] , calendarArry[32] , calendarArry[35] , calendarArry[38] , calendarArry[41] , calendarArry[44] , calendarArry[47] , calendarArry[50] , calendarArry[53] , calendarArry[56] , calendarArry[59] , calendarArry[62] , calendarArry[65] , calendarArry[68] , calendarArry[71] , calendarArry[74] , calendarArry[77] , calendarArry[80] , calendarArry[83] , calendarArry[86] , calendarArry[89] , calendarArry[92] , TIMESTMP , TIMESTMP)
		result = connection.prepare("INSERT INTO T_JYOKOUEN_CALENDAR(CALENDAR_YM,RCD_KBN, D1,D2,D3,D4,D5,D6,D7,D8,D9,D10,D11,D12,D13,D14,D15,D16,D17,D18,D19,D20,D21,D22,D23,D24,D25,D26,D27,D28,D29,D30,D31,RCD_KSN_TIME,RCD_TRK_TIME) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
		result.execute( strMonth , 1 , calendarArry[3] , calendarArry[6] , calendarArry[9] , calendarArry[12] , calendarArry[15] , calendarArry[18] , calendarArry[21] , calendarArry[24] , calendarArry[27] , calendarArry[30] , calendarArry[33] , calendarArry[36] , calendarArry[39] , calendarArry[42] , calendarArry[45] , calendarArry[48] , calendarArry[51] , calendarArry[54] , calendarArry[57] , calendarArry[60] , calendarArry[63] , calendarArry[66] , calendarArry[69] , calendarArry[72] , calendarArry[75] , calendarArry[78] , calendarArry[81] , calendarArry[84] , calendarArry[87] , calendarArry[90] , calendarArry[93] , TIMESTMP , TIMESTMP)
	end
	connection.close

	filehdl = open(LOGDIR + "GetJyokouenCalender_log.txt","a+")
		filehdl.puts (TIMESTMP)
	filehdl.close

	filehdl = File.open(DATADIR + "JyokouenCalendar_work.txt","a+")
		filehdl.puts (thisMonth + TIMESTMP)
	filehdl.close

	puts "取得完了 " + strMonth

	rescue => ex
		#p ex
	else
		PARCON_SQL.normal(strMonth, __FILE__.gsub(/^.*\//,'') )
end

def getTargetMonth(page)
	targetMonth = page.search('//html/body/div/div[@id="main_wrapper000"]/div/h2/font/b').inner_text
	targetMonth = targetMonth.gsub(/月/, '')
	targetMonth = NKF.nkf('-wZ0', targetMonth)
	targetMonth = TIMESTMP[0..3] + sprintf("%02d",targetMonth)
	
#	p targetMonth
	return targetMonth
rescue => ex
	puts "例外 " + "getTargetMonth()"
	return false
else
	return true
end

def checkNextMonth(agent)

	page = agent.get('http://osakajo.kyudojo.info/link3018.html')
	targetMonth = getTargetMonth(page)
	begin
		page = agent.page.link_with(:text => "・来月").click
		page = (page/:h2)[4].inner_text
	rescue => ex
		#予定表テーブルが存在する場合「inner_text」がundefined methodとなる
		puts ex
		return true
	else
		if /更新をお待ちください/.match(page) then
			puts "予定未作成 " + targetMonth
			return false
		else
			puts "翌月チェックエラー"
			return false
		end
	end
rescue => ex
	puts "例外 " + "checkNextMonth()"
	return false
else
	return false
end

#関数定義終了

#MAIN
begin
	agent = Mechanize.new
	page = agent.get('http://osakajo.kyudojo.info/')
	page = agent.page.link_with(:text => "行事予定表").click
	get_schedule(page)

	if checkNextMonth(agent) then
		page = agent.get('http://osakajo.kyudojo.info/link3018.html')
		page = agent.page.link_with(:text => "・来月").click
		get_schedule(page)
	else
		puts "翌月分データなし"
	end
rescue => ex
	p '例外'
	p ex
else
end

