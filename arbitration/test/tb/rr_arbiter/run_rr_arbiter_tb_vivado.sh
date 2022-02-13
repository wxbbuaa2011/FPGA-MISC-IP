#!/usr/bin/sh

git_root=`git rev-parse --show-toplevel`
name=rr_arbiter

rm -rf *.jou *.log .Xil xvlog* *wdb xelab* xsim*
xvlog -sv $git_root/arbitration/rtl/$name.sv $git_root/arbitration/test/tb/rr_arbiter/rr_arbiter_tb.sv
xelab rr_arbiter_tb
xsim work.rr_arbiter_tb -runall

