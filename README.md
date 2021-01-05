# Ico-saver
by yuzawa-san

![Example](Ico/thumbnail.png)

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/yuzawa-san/ico-saver)](https://github.com/yuzawa-san/ico-saver/releases)
[![GitHub All Releases](https://img.shields.io/github/downloads/yuzawa-san/ico-saver/total)](https://github.com/yuzawa-san/ico-saver/releases)
[![build](https://github.com/yuzawa-san/ico-saver/workflows/build/badge.svg)](https://github.com/yuzawa-san/ico-saver/actions)

This is a macOS screensaver with various convex polyhedra bouncing across the screen.
It is inspired by X11's [ico](https://www.x.org/releases/unsupported/programs/ico/) and [mxico](https://people.freebsd.org/~maho/mxico/Tamentai.html)

Dozens of common polyhedra are included:

* Regular Polyhedra (R)
* Semi-Regular Polyhedra (S)
* Johnson Solids (J) _source uses `N` designation_

The shape data is derived from Kobayashi, M., Suzuki, T.: [Data of coordinates of all regular-faced convex polyhedra](http://mitani.cs.tsukuba.ac.jp/polyhedron/) (1992)

## Installation

Download a [release ZIP archive](https://github.com/yuzawa-san/ico-saver/releases) or build the application locally.

Open the `Ico.saver` file.

Due to the lack of code signing (that costs money), it will likely be necessary to alter security settings to allow installation:

```
xattr -d "com.apple.quarantine" Ico.saver
```

## Building

Open the Xcode project and build using the IDE.
Open the `Ico.saver` product in the Finder, which will open the screensaver in the System Preferences.