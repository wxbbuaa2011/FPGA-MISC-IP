#!/usr/bin/sh

git_root=`git rev-parse --show-toplevel`
name=wrr_arbiter

rm -rf *.jou *.log .Xil xvlog* *wdb xelab* xsim*
xvlog -sv $git_root/arbitration/rtl/$name.sv $git_root/arbitration/test/tb/wrr_arbiter/wrr_arbiter_tb.sv
xelab wrr_arbiter_tb
xsim work.wrr_arbiter_tb -runall

