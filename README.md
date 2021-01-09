# Ico-saver
by yuzawa-san

![Example](demo.gif)

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/yuzawa-san/ico-saver)](https://github.com/yuzawa-san/ico-saver/releases)
[![GitHub All Releases](https://img.shields.io/github/downloads/yuzawa-san/ico-saver/total)](https://github.com/yuzawa-san/ico-saver/releases)
[![build](https://github.com/yuzawa-san/ico-saver/workflows/build/badge.svg)](https://github.com/yuzawa-san/ico-saver/actions)

This is a macOS screensaver with various convex polyhedra bouncing across the screen.
It is inspired by X11's [ico](https://www.x.org/releases/unsupported/programs/ico/) and [mxico](https://people.freebsd.org/~maho/mxico/Tamentai.html).

Dozens of common polyhedra are included:

* [Regular Polyhedra](https://en.wikipedia.org/wiki/Regular_polyhedron) (R)
* [Semi-Regular Polyhedra](https://en.wikipedia.org/wiki/Semiregular_polyhedron) (S)
* [Johnson Solids](https://en.wikipedia.org/wiki/Johnson_solid) (J) _source uses `N` designation_
* [Prisms](https://en.wikipedia.org/wiki/Prism_%28geometry%29) (P) - first ten (of infinite)
* [Antiprisms](https://en.wikipedia.org/wiki/Antiprism) (A) - first ten (of infinite)

The shape data is derived from Kobayashi, M., Suzuki, T.: [Data of coordinates of all regular-faced convex polyhedra](http://mitani.cs.tsukuba.ac.jp/polyhedron/) (1992)

## Installation

The minimum build target is macOS 10.13.

Download a [release ZIP archive](https://github.com/yuzawa-san/ico-saver/releases) or build the application locally.

Open the ZIP archive to decompress. Control-click the the `Ico.saver` file and open via the context menu. This should open a context menu with an option to `Open Anyway`.
The system may complain about the origin of the file since it was downloaded from the internet.

Due to the lack of code signing (that costs money), it will likely be necessary to alter security settings to allow installation:

```
xattr -d "com.apple.quarantine" Ico.saver
```

### Homebrew

Ideally, this project would be distributed via Homebrew, however that is not possible at this point in time.
Please star this project if you want a homebrew distribution as they require projects to have a certain provenance to be added.

## Building

Open the Xcode project and build using the IDE.
Open the `Ico.saver` product in the Finder, which will open the screensaver in the System Preferences.