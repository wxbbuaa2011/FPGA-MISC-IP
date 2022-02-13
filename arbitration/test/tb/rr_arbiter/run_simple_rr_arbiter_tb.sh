#!/usr/bin/sh

git_root=`git rev-parse --show-toplevel`
name=rr_arbiter

mkdir -p output
iverilog -g2005-sv $git_root/arbitration/rtl/rr_arbiter.sv $git_root/arbitration/test/tb/rr_arbiter/simple_rr_arbiter_tb.sv -o output/$name.out
cd output && ./$name.out