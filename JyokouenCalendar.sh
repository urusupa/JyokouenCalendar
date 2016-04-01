#!/bin/sh
###############################################################################
# JyokouenCalendar.sh
# in:
# out:
# return RETCD
###############################################################################

. ${LIB_DIR}/common.sh


###############################################################################
# メイン
###############################################################################

JOBSTART $*

STEPSTART GetJyokouenCalendar

EXECRUBY ${RUBY_DIR}/GetJyokouenCalendar.rb

STEPEND

STEPSTART MakeJyokouenCalendar

EXECRUBY ${RUBY_DIR}/MakeJyokouenCalendar.rb

STEPEND

JOBEND
