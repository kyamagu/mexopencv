mexopencv
=========
[![Travis](https://img.shields.io/travis/kyamagu/mexopencv/master.svg)][1]
[![AppVeyor](https://img.shields.io/appveyor/ci/kyamagu/mexopencv/master.svg)][2]
[![License](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](LICENSE)

Collection and development kit of MATLAB MEX functions for OpenCV library.

The package provides MATLAB MEX functions that interface with hundreds of
OpenCV APIs. Also the package contains a C++ class that converts between
MATLAB's native data type and OpenCV data types. The package is suitable for
fast prototyping of OpenCV application in MATLAB, use of OpenCV as an external
toolbox in MATLAB, and development of custom MEX functions.

The current version of mexopencv is compatible with OpenCV 3.4.1.

For previous OpenCV 3.x versions, checkout the corresponding tags:

- [v3.4.0][24]
- [v3.3.1][23]
- [v3.3.0][22]
- [v3.2.0][21]
- [v3.1.0][20]
- [v3.0.0][19]

For OpenCV 2.x, checkout these older branches:

- [v2.4][18] (last tested with OpenCV v2.4.11)
- [v2.3][17]
- [v2.1][16]

Consult the [wiki][3] for help.

Table of Contents
=================

- [Structure](#structure)
- [Build](#build)
    - [Linux](#linux)
    - [OS X](#os-x)
    - [Windows](#windows)
- [Usage](#usage)
    - [Documentation](#documentation)
    - [Unit Testing](#unit-testing)
- [License](#license)

Structure
=========

The project tree is organized as follows:

    +cv/             OpenCV or custom API directory
    +mexopencv/      mexopencv utility API directory
    doc/             directory for documentation
    include/         header files
    lib/             directory for compiled C++ library files
    samples/         directory for sample application codes
    src/             directory for C++ source files
    src/+cv/         directory for MEX source files
    src/+cv/private/ directory for private MEX source files
    test/            directory for test scripts and resources
    opencv_contrib/  directory for sources/samples/tests of additional modules
    utils/           directory for utilities
    Doxyfile         config file for doxygen
    Makefile         make script
    README.markdown  this file

Build
=====

Prerequisite

- [MATLAB][4] or [Octave][5] (>= 4.0.0)
- [OpenCV][6] (3.4.1)

Depending on your platform, you also need the required build tools:

- Linux: g++, make, pkg-config
- OS X: Xcode Command Line Tools, pkg-config
- Windows: Visual Studio

Refer to the `Makefile` and `make.m` scripts for a complete list of
options accepted for building mexopencv across supported platforms.

Refer to the [wiki][3] for detailed build instructions.

OpenCV
------

Currently, mexopencv targets the final **3.4.1** stable version of OpenCV. You
must build it against this exact version, rather than using the bleeding-edge
dev-version of `opencv` and `opencv_contrib`. UNIX users should consider using
a package manager to install OpenCV if available.

- [OpenCV][7]
- [OpenCV contributed modules][8]

**DO NOT use the "master" branch of `opencv` and `opencv_contrib`!**
**Only the 3.4.1 release is supported by mexopencv.**

Linux
-----

First make sure you have OpenCV 3.4.1 installed in the system:

- if applicable, install OpenCV 3 package available in your package manager
  (e.g., `libopencv-dev` in Debian/Ubuntu, `opencv-devel` in Fedora).
  Note that these packages are not always up-to-date, so you might need to use
  older mexopencv versions to match their [opencv package][9] version.
- otherwise, you can always build and install OpenCV from [source][7]:

        $ cd <opencv_build_dir>
        $ cmake <options> <opencv_src_dir>
        $ make
        $ sudo make install

At this point, you should make sure that the [`pkg-config`][10] command can
identify and locate OpenCV libraries (if needed, set the `PKG_CONFIG_PATH`
environment variable to help it find the `opencv.pc` file):

    $ pkg-config --cflags --libs opencv

If you have all the prerequisites, go to the mexopencv directory and type:

    $ make

This will build and place all MEX functions inside `+cv/`. Specify your MATLAB
directory if you installed MATLAB to a non-default location:

    $ make MATLABDIR=/opt/local/MATLAB/R2017a

You can also work with [Octave][5] instead of MATLAB by specifying:

    $ make WITH_OCTAVE=true

To enable support for contributed modules, you must build OpenCV from both
[`opencv`][7] and [`opencv_contrib`][8] sources. You can then compile
mexopencv as:

    $ make all contrib

Finally you can test mexopencv functionality:

    $ make test

Developer documentation can be generated with Doxygen if installed:

    $ make doc

This will create HTML files under `doc/`.

Refer to the wiki for detailed instructions on how to compile OpenCV for both
[MATLAB][14] and [Octave][15].

OS X
----

Currently, the recommended approach to install OpenCV in OS X is
[Homebrew][11]. Install Homebrew first, and do the following to install
OpenCV 3:

    $ brew install pkg-config homebrew/science/opencv3
    $ brew link opencv3

Otherwise, you can build OpenCV from [source][7], similar to the Linux case.

If you have all the prerequisites, go to the mexopencv directory and run
(modifying the options as needed):

    $ make MATLABDIR=/Applications/MATLAB_R2016a.app PKG_CONFIG_MATLAB=opencv3 LDFLAGS=-L/usr/local/share/OpenCV/3rdparty/lib -j2

Replace the path to MATLAB with your version. This will build and place all
MEX functions inside `+cv/`.

Windows
-------

Refer to [the wiki][13] for detailed instructions on how to compile OpenCV
on Windows, and build mexopencv against it.

In a nutshell, execute the following in MATLAB to compile mexopencv:

    >> addpath('C:\path\to\mexopencv')
    >> mexopencv.make('opencv_path','C:\OpenCV\build')

Replace the path above with the location where OpenCV binaries are installed
(i.e location specified in `CMAKE_INSTALL_PREFIX` while building OpenCV).

Contrib modules are enabled as:

    >> addpath('C:\path\to\mexopencv')
    >> addpath('C:\path\to\mexopencv\opencv_contrib')
    >> mexopencv.make('opencv_path','C:\OpenCV\build', 'opencv_contrib',true)

If you have previously compiled mexopencv with a different configuration,
don't forget to clean old artifacts before building:

    >> mexopencv.make('clean',true, 'opencv_contrib',true)

Usage
=====

Once MEX functions are compiled, you can add path to the project directory and
call MEX functions within MATLAB using package name `cv`.

``` matlab
addpath('/path/to/mexopencv');
addpath('/path/to/mexopencv/opencv_contrib');

% recommended
out = cv.filter2D(img, kern);  % with package name 'cv'

% not recommended
import cv.*;
out = filter2D(img, kern);     % no need to specify 'cv' after imported
```

Note that some functions such as `cv.imread` will overload MATLAB's built-in
`imread` function when imported. Use the scoped name when you need to avoid
name collision. It is also possible to import individual functions. Check
`help import` in MATLAB.

Check a list of functions available by `help` command in MATLAB.

``` matlab
>> help cv;              % shows list of functions in package 'cv'

>> help cv.VideoCapture; % shows documentation of VideoCapture
```

Look at the `samples/` directory for examples.

Documentation
-------------

mexopencv includes a simple documentation utility that generates HTML help
files for MATLAB. The following command creates HTML user documentation
under `doc/matlab/` directory.

``` matlab
addpath('/path/to/mexopencv/utils');
MDoc;
```

On-line documentation is [available][12].

Unit Testing
------------

You can test the functionality of compiled files by `UnitTest` class located
inside `test` directory.

``` matlab
addpath('/path/to/mexopencv/test');
UnitTest;
```

Look at the `test/unit_tests/` directory for all unit-tests.

License
=======

The code may be redistributed under the [BSD 3-Clause license](LICENSE).


[1]: https://travis-ci.org/kyamagu/mexopencv
[2]: https://ci.appveyor.com/project/kyamagu/mexopencv
[3]: https://github.com/kyamagu/mexopencv/wiki
[4]: https://www.mathworks.com/products/matlab.html
[5]: https://www.gnu.org/software/octave/
[6]: https://opencv.org/
[7]: https://github.com/opencv/opencv/releases/tag/3.4.1
[8]: https://github.com/opencv/opencv_contrib/releases/tag/3.4.1
[9]: https://packages.ubuntu.com/bionic/libopencv-dev
[10]: https://people.freedesktop.org/~dbn/pkg-config-guide.html
[11]: https://brew.sh/
[12]: http://kyamagu.github.io/mexopencv/matlab
[13]: https://github.com/kyamagu/mexopencv/wiki/Installation-%28Windows%2C-MATLAB%2C-OpenCV-3%29
[14]: https://github.com/kyamagu/mexopencv/wiki/Installation-%28Linux%2C-MATLAB%2C-OpenCV-3%29
[15]: https://github.com/kyamagu/mexopencv/wiki/Installation-%28Linux%2C-Octave%2C-OpenCV-3%29
[16]: https://github.com/kyamagu/mexopencv/tree/v2.1
[17]: https://github.com/kyamagu/mexopencv/tree/v2.3
[18]: https://github.com/kyamagu/mexopencv/tree/v2.4
[19]: https://github.com/kyamagu/mexopencv/tree/v3.0.0
[20]: https://github.com/kyamagu/mexopencv/tree/v3.1.0.1
[21]: https://github.com/kyamagu/mexopencv/tree/v3.2.0
[22]: https://github.com/kyamagu/mexopencv/tree/v3.3.0
[23]: https://github.com/kyamagu/mexopencv/tree/v3.3.1
[24]: https://github.com/kyamagu/mexopencv/tree/v3.4.0
