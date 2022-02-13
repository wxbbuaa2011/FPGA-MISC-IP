#!/usr/bin/sh

git_root=`git rev-parse --show-toplevel`
name=wrr_arbiter

mkdir -p output
iverilog -g2005-sv $git_root/arbitration/rtl/wrr_arbiter.sv $git_root/arbitration/test/tb/wrr_arbiter/simple_wrr_arbiter_tb.sv -o output/$name.out
cd output && ./$name.out