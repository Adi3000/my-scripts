#!/bin/sh

gpio mode 0 out
gpio mode 2 out
gpio write 2 1 
gpio write 0 0
gpio write 0 1
