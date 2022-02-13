#!/usr/bin/sh

git_root=`git rev-parse --show-toplevel`
name=bitscan

mkdir -p output
iverilog -g2005-sv $git_root/arbitration/rtl/bitscan.sv $git_root/arbitration/test/tb/bitscan/bitscan_tb.sv -o output/$name.out
cd output && ./$name.out