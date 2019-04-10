
# FIXME:: Set from Git Repo Base
setenv MGC_HOME /ecelib/linware/mentor/questa/questasim/
setenv QUESTA_HOME ${MGC_HOME}

setenv MGLS_LICENSE_FILE 1717@zuma.eecs.uci.edu
setenv LM_LICENSE_FILE ${MGLS_LICENSE_FILE}

setenv LD_LIBRARY_PATH ${MGC_HOME}/lib/:${MGC_HOME}
setenv MODEL_TECH ${MGC_HOME}/bin
setenv QUESTA_UVM_HOME $QUESTA_HOME/verilog_src/questa_uvm_pkg-1.2
setenv UVM_HOME $QUESTA_HOME/verilog_src/uvm-1.1d

setenv PATH ${MGC_HOME}:${MGC_HOME}/bin/:$PATH

source /ecelib/linware/synopsys15/env/dc.csh

setenv sim `pwd`/sim
setenv run `pwd`/sim/run
setenv syn `pwd`/qip/syn

setenv design `pwd`/src
setenv model `pwd`/sim/model
setenv verif `pwd`/sim/verif
setenv scripts `pwd`/scr



ln -s ../../scr/common.pl sim/run/ -f
ln -s ../../scr/do.pl     sim/run/ -f
ln -s ../../scr/Mixed.pm  sim/run/ -f

