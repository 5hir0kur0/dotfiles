#!/bin/sh

python -c "from math import *
try:
    print($*)
except Exception as e:
    print('[error]', e)"
