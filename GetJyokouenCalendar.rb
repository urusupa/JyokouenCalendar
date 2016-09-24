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
	thisMonth = thisMonth.gsub(/\u00A0/, '') # &nbsp;の削除
	thisMonth = thisMonth.gsub(/\t/, '')
	thisMonth = thisMonth.gsub(/\n\n\n/, ',')
	thisMonth = thisMonth.gsub(/\n\n/, '')
	thisMonth = thisMonth.gsub(/日\n午前\n午後\n夜間\n行事/, '')

	thisMonth = thisMonth.gsub(/ 日 \(.\)/, '') #曜日削除

	strMonth = getTargetMonth(page)
	
	# 全角数字を半角数字に変換．nkf を使用
#	thisMonth = NKF.nkf('-wZ0', thisMonth)

#	p thisMonth

	wCalendarArry = []
	calendarArry = Array.new(94)
	wCalendarArry = thisMonth.split(",")

	#年末年始休館対応
	wCalendarArry.map! {|elem| elem == '閉館' ? elem = '×' : elem}
	wCalendarArry.map! {|elem| elem == '休館' ? elem = ["×", "×", "×"] : elem}
	wCalendarArry.map! {|elem| elem == '休　館　日' ? elem = ["×", "×", "×"] : elem}
	wCalendarArry.flatten!
	
	calendarArry[0] = strMonth
	posAry = 1
	cntDay = 1
	cntwCal = 0
	while cntDay <= 31 do
		calendarArry[posAry] = cntDay
		break if !wCalendarArry[cntwCal+2] #小の月対応
		marubatuCheck(calendarArry[posAry] , wCalendarArry[cntwCal+1] , wCalendarArry[cntwCal+2] , wCalendarArry[cntwCal+3])
		calendarArry[posAry+1] = wCalendarArry[cntwCal+1] + wCalendarArry[cntwCal+2] + wCalendarArry[cntwCal+3]
		calendarArry[posAry+2] = wCalendarArry[cntwCal+4]
		posAry += 3
		cntDay += 1
		cntwCal += 5
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

		begin
		filehdl = File.open(TMPDIR + "JyokouenCalendar_work.txt","a+")
			filehdl.puts (thisMonth + TIMESTMP)
		filehdl.close
		rescue Errno::ENOENT => ex
		p ex

		filehdl = File.open(TMPDIR + "JyokouenCalendar_work.txt","w")
		filehdl.close
		retry
		end
	
	#puts "取得完了 " + strMonth
	APPEND_LOGFILE("取得完了 " + strMonth)
	
	rescue => ex
		p ex
	else
		PARCON_SQL.normal(strMonth, __FILE__.gsub(/^.*\//,'') )
		
end

def marubatuCheck(day,gozen,gogo,yakan)
	if    gozen != '○' && gozen != '▲' && gozen != '×' then
		raise StandardError, "marubatuCheck_error"
	elsif gogo != '○' && gogo != '▲' && gogo != '×' then
		raise StandardError, "marubatuCheck_error"
	elsif yakan != '○' && yakan != '▲' && yakan != '×' then
		raise StandardError, "marubatuCheck_error"
	else
	end
	
rescue => ex
	
	result = `SENDMAIL.sh 9 1 "marubatuCheck_error\n""day:"#{day}`
	
	exit 9
else
end



def getTargetMonth(page)
#	targetMonth = page.search('//html/body/div/div[@id="main_wrapper000"]/div/h2/font/b').inner_text
#	targetMonth = page.search('//*[@id="introduction_schedule_contents"]/div/section/div/div[2]/div/p').inner_text
	targetMonth = page.search('//*[@id="introduction_schedule_contents"]/div/section/div/div/div/p[@class="calendar_title"]').inner_text
	targetMonth = targetMonth.gsub(/月/, '')
	targetMonth = NKF.nkf('-wZ0', targetMonth)
	targetMonth = targetMonth.to_i
	
	if sprintf("%02d",targetMonth) == '01' && TIMESTMP[4..5] == '12' then #年越し対応
		tmp = TIMESTMP[0..3].to_i + 1
		targetMonth = tmp.to_s + sprintf("%02d",targetMonth)
	else
		targetMonth = TIMESTMP[0..3] + sprintf("%02d",targetMonth)
	end
	
	return targetMonth
rescue => ex
	puts "例外 " + "getTargetMonth()"
	p ex
	return false
else
	return true
end


###############################################################################
# checkNextMonth
# in:ページオブジェクト
# out:boolean
# 翌月のテーブルが取得可能ならtrueを返す
# それ以外はfalse
###############################################################################
def checkNextMonth(agent)

	page = agent.get('http://www.osaka-sp.jp/kyudojo/introduction/schedule/?month=next')
	targetMonth = getTargetMonth(page)
	page = agent.get('http://www.osaka-sp.jp/kyudojo/introduction/schedule/')

	begin
#		page = agent.page.link_with(:text => "・来月").click
		page = agent.page.link_with(href: '?month=next').click
#		page = (page/:h2)[4].inner_text
	rescue NoMethodError => ex
		#予定表テーブルが存在する場合「inner_text」がundefined methodとなる
		APPEND_LOGFILE( "翌月スケジュール無し" )
		APPEND_LOGFILE( ex.class )
		return true
	rescue => ex
		APPEND_LOGFILE( "例外：翌月inner_text")
	end
	return true
rescue => ex
	APPEND_LOGFILE( "例外 " + "checkNextMonth()")
	p ex
	return false
else

end

#関数定義終了

#MAIN
begin
	agent = Mechanize.new
#	page = agent.get('http://osakajo.kyudojo.info/')
	page = agent.get('http://www.osaka-sp.jp/kyudojo/')
#	page = agent.page.link_with(:text => "行事予定表").click
	page = agent.page.link_with(:text => "施設の空き状況とご予約").click
	get_schedule(page)

	if checkNextMonth(agent) then
		page = agent.get('http://www.osaka-sp.jp/kyudojo/introduction/schedule/?month=next')
#		page = agent.page.link_with(:text => "・来月").click
		get_schedule(page)
	else
		puts "翌月分データなし"
	end
rescue => ex
	p '例外'
	p ex
else
end



