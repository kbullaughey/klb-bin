#!/usr/bin/env python2.7

import codecs, sys
import unicodedata as ud

if len(sys.argv) != 2: raise RuntimeError("Invalid number of arguments")

fn = sys.argv[1]
fp = codecs.open(fn, mode="r", encoding='utf-8')
lines = fp.readlines()
fp.close()

lines = [x.rstrip() for x in lines]

for x in lines:
  print ud.normalize('NFKC', x)



# END
