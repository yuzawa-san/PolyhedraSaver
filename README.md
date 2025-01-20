# PolyhedraSaver
by yuzawa-san

![Example](demo.gif)

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/yuzawa-san/PolyhedraSaver)](https://github.com/yuzawa-san/PolyhedraSaver/releases)
[![GitHub All Releases](https://img.shields.io/github/downloads/yuzawa-san/PolyhedraSaver/total)](https://github.com/yuzawa-san/PolyhedraSaver/releases)
[![build](https://github.com/yuzawa-san/PolyhedraSaver/workflows/build/badge.svg)](https://github.com/yuzawa-san/PolyhedraSaver/actions)

This is a macOS screensaver with various convex polyhedra bouncing across the screen.
It is inspired by X11's [ico](https://www.x.org/releases/unsupported/programs/ico/) and [mxico](https://people.freebsd.org/~maho/mxico/Tamentai.html).

Dozens of common polyhedra are included:

* [Regular Polyhedra](https://en.wikipedia.org/wiki/Regular_polyhedron) (R)
* [Semi-Regular Polyhedra](https://en.wikipedia.org/wiki/Semiregular_polyhedron) (S)
* [Johnson Solids](https://en.wikipedia.org/wiki/Johnson_solid) (J) _source uses `N` designation_
* [Prisms](https://en.wikipedia.org/wiki/Prism_%28geometry%29) (P) - first ten (of infinite)
* [Antiprisms](https://en.wikipedia.org/wiki/Antiprism) (A) - first ten (of infinite)

## Coordinate Data Attribution

* **[ja]** 小林光夫, [鈴木卓治](https://www.rekihaku.ac.jp/research/researcher/suzuki_takuzi/): [正多角形を面にもつすべての凸多面体の頂点座標の計算](https://ndlonline.ndl.go.jp/#!/detail/R300000002-I3803620-00), 電気通信大学紀要 編 5(2) 1992.12 p.p147～184  
**[en]** Kobayashi, M., [Suzuki, T.](https://www.rekihaku.ac.jp/research/researcher/suzuki_takuzi/), "[Calculation of Coordinates of Vertices of All Convex Polyhedra with Regular Faces](https://ndlonline.ndl.go.jp/#!/detail/R300000002-I3803620-00)", _Bulletin of the University of Electro-Communications_, vol. 5, no. 2, pp.147-184, Dec. 1992.  
_The original paper describing an algorithm to calculate vertex coordinates. The authors later published coordinate data to the `fj.sources` newsgroup on 1994-06-22 in multiple pieces with the subject `Data of coordinates of all regular-faced convex polyhedra`. The newsgroup data is not accessible at this time._
* **[ja]** [中田真秀](http://nakatamaho.riken.jp/): [正多面体、準正多面体、ザルガラー多面体、mxico](https://people.freebsd.org/~maho/mxico/Tamentai.html)  
**[en]** [Nakata, Maho](http://nakatamaho.riken.jp/): [Regular polyhedron, quasi-regular polyhedron, Zalgaller polyhedron, mxico](https://people.freebsd.org/~maho/mxico/Tamentai.html)  
_This source downloaded the coordinate data from the newsgroup. This project imported the coordinate data. [archive](https://people.freebsd.org/~maho/mxico/polyhedron.tar.bz2)_
* **[ja]** [三谷純](http://mitani.cs.tsukuba.ac.jp/): [多面体データ](http://mitani.cs.tsukuba.ac.jp/polyhedron/)  
**[en]** [Mitani, Jun](http://mitani.cs.tsukuba.ac.jp/): [Polyhedral data](http://mitani.cs.tsukuba.ac.jp/polyhedron/)  
_This source is a mirror of the previous source. The coordinate data was converted to OBJ file format. [archive](https://mitani.cs.tsukuba.ac.jp/polyhedron/data/polyhedrons_obj.zip)_

The original data from Kobayashi and Suzuki lacks an SPDX license, but states that the original README files be included in this project. Here are their README files: [English](third-party/README.txt) and [Japanese](third-party/READMEj.txt)

## Installation

The minimum build target is macOS 10.15 (Catalina) for [technical ](https://developer.apple.com/forums/thread/89482?answerId=268962022#268962022) [reasons](https://github.com/JohnCoates/Aerial/issues/1149). Manual installation or Homebrew installation is available.

* Download a [release ZIP archive](https://github.com/yuzawa-san/PolyhedraSaver/releases).
* Open `Polyhedra.saver.zip` to uncompress.
* Open `Polyhedra.saver` which will load the screen saver System Preferences pane. This will install the screensaver.
* Configure the screensaver.

Alternative shell version:

```console
# Download a tagged version (see shield above)
curl -OL https://github.com/yuzawa-san/PolyhedraSaver/releases/download/TAG/Polyhedra.saver.zip
# Decompress
unzip Polyhedra.saver.zip
# Load screensaver into System Preferences
open Polyhedra.saver
# Clean up
rm -rf Polyhedra.saver.zip Polyhedra.saver
```

### Homebrew

Ideally, this project would be distributed via [Homebrew](https://brew.sh/) main repo, however that is not possible at this point in time.
Please star this project if you want a homebrew distribution as they require projects to have a certain provenance to be added.

A self-maintained tap is available for use. To install tap:
```console
brew tap yuzawa-san/tap
```

To install:
```console
brew update
brew install --cask polyhedrasaver
```

To update:
```console
brew update
# upgrade all Homebrew software
brew upgrade
# update just this
brew upgrade --no-quarantine --cask polyhedrasaver
```

## Building

Open the Xcode project and build using the IDE or by running `xcodebuild clean build -configuration Debug`
Open the `Polyhedra.saver` product, which will open the screensaver in the System Preferences.