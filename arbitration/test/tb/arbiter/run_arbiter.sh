#!/usr/bin/sh

git_root=`git rev-parse --show-toplevel`
name=arbiter

mkdir -p output
iverilog -g2005-sv $git_root/arbitration/rtl/arbiter.sv $git_root/arbitration/test/tb/arbiter/arbiter_tb.sv -o output/$name.out
cd output && ./$name.out