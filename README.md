WatchCheck stats
================

This is a simple utility that I wrote to extract some useful statistics from data exported from the
[WatchCheck app](https://17jewels.info/workbench/software/268-watchcheck2-en.html).

Currently the only thing the script does is that it computes the overall accuracy rate for all watches in the data file (which is something the WatchCheck app itself does not do), which is
expected on STDIN (see the `.reflex` file).

If you want to hack it I recommend using [reflex](https://github.com/cespare/reflex):
```
reflex --sequential -d none -c .reflex
```
