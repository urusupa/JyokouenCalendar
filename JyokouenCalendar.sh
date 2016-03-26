#!/bin/sh
#################
# JyokouenCalendar.sh
# 
# return RETCD
###############

. ${LIB_DIR}/common.sh


#################
# 関数
###############
JOBSTART $*

#################
# メイン
###############

STEPSTART GetJyokouenCalendar

EXECRUBY ${RUBY_DIR}/GetJyokouenCalendar.rb

STEPEND

STEPSTART MakeJyokouenCalendar

EXECRUBY ${RUBY_DIR}/MakeJyokouenCalendar.rb

STEPEND


JOBEND
