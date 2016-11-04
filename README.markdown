mexopencv
=========
[![Travis](https://img.shields.io/travis/kyamagu/mexopencv/master.svg)][1]
[![AppVeyor](https://img.shields.io/appveyor/ci/kyamagu/mexopencv/master.svg)][2]
[![License](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](LICENSE)

Collection and a development kit of MATLAB MEX functions for OpenCV library.

The package provides MATLAB MEX functions that interface with hundreds of
OpenCV APIs. Also the package contains C++ class that converts between
MATLAB's native data type and OpenCV data types. The package is suitable for
fast prototyping of OpenCV application in MATLAB, use of OpenCV as an external
toolbox in MATLAB, and development of a custom MEX function.

The current version of mexopencv (master branch) is compatible with OpenCV 3.1.
For older OpenCV versions, please checkout the corresponding releases or
branches ([v3.0][3], [v2.4][4], [v2.3][5], and [v2.1][6]).

Consult the [wiki][7] for help.

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

Prerequisite: [MATLAB][8] or [Octave][9] (>= 4.0.0), [OpenCV][10] (3.1.0).

Depending on your platform, you also need:

- Linux: g++, make, pkg-config
- OS X: Xcode Command Line Tools, pkg-config
- Windows: supported Visual Studio compiler

Currently, mexopencv targets the final **3.1.0** stable version of OpenCV. You
must build it against this exact version, rather than using the bleeding-edge
dev-version of `opencv` or `opencv_contrib`. UNIX users should consider using
a package manager to install OpenCV if available.

- [OpenCV][11]
- [OpenCV contributed modules][12]

Refer to the `Makefile` and `make.m` scripts for a complete list set of
options accepted for building mexopencv across supported platforms.

Linux
-----

First make sure you have OpenCV 3.1.0 installed in the system:

- if applicable, install OpenCV 3 package available in your package manager
  (e.g., `libopencv-dev` in Debian/Ubuntu, `opencv-devel` in Fedora).
  Sadly the [OpenCV package][13] provided in Ubuntu 16.10 is still behind
  with OpenCV 2.4, which can only be used with the [v2.4 release][4] of
  mexopencv, not the master branch.
- otherwise, you need to build and install OpenCV from [source][11]:

        $ cd <opencv_build_dir>
        $ cmake <options> <opencv_src_dir>
        $ make
        $ sudo make install

At this point, you should make sure that the [`pkg-config`][14] command can
identify and locate OpenCV libraries (if needed, set the `PKG_CONFIG_PATH`
environment variable to help it find `opencv.pc`):

    $ pkg-config --cflags --libs opencv

If you have all the prerequisites, go to the mexopencv directory and type:

    $ make

This will build and place all MEX functions inside `+cv/`. Specify your MATLAB
directory if you installed MATLAB to a non-default location:

    $ make MATLABDIR=/opt/local/MATLAB/R2016a

You can also work with [Octave][9] by specifying:

    $ make WITH_OCTAVE=true

To enable support for contributed modules, you must build OpenCV from both
[`opencv`][11] and [`opencv_contrib`][12] sources. You can then compile
mexopencv as:

    $ make WITH_CONTRIB=true

Optionally you can test mexopencv functionality:

    $ make test

Developer documentation can be generated with Doxygen if installed:

    $ make doc

This will create HTML and LaTeX files under `doc/`.

OS X
----

Currently, the recommended approach to install OpenCV in OS X is
[Homebrew][15]. Install Homebrew first, and do the following to install
OpenCV 3:

    $ brew install pkg-config homebrew/science/opencv3
    $ brew link opencv3

Otherwise, you can build OpenCV from [source][11], similar to the Linux case.

If you have all the prerequisite, go to the mexopencv directory and type:

    $ make MATLABDIR=/Applications/MATLAB_R2016a.app PKG_CONFIG_MATLAB=opencv3 LDFLAGS=-L/usr/local/share/OpenCV/3rdparty/lib -j2

Replace the path to MATLAB with your version. This will build and place all
MEX functions inside `+cv/`.

Windows
-------

Refer to [the wiki][16] for detailed instructions on how to compile OpenCV
on Windows, and build mexopencv against it.

In a nutshell, execute the following in MATLAB to compile mexopencv:

    >> addpath('C:\path\to\mexopencv')
    >> mexopencv.make('opencv_path','C:\OpenCV\build')

Replace the path above with the location where OpenCV binaries are installed
(i.e location specified in `CMAKE_INSTALL_PREFIX` while building OpenCV).

Contrib modules are enabled as:

    >> addpath('C:\path\to\mexopencv\opencv_contrib')
    >> mexopencv.make(..., 'opencv_contrib',true)

Usage
=====

Once MEX functions are compiled, you can add path to the project directory and
call MEX functions within MATLAB using package name `cv`.

``` matlab
addpath('/path/to/mexopencv');
addpath('/path/to/mexopencv/opencv_contrib')

result = cv.filter2D(img, kern);  % with package name 'cv'

import cv.*;
result = filter2D(img, kern);     % no need to specify 'cv' after imported
```

Note that some functions such as `cv.imread` overload MATLAB's built-in
function when imported. Use the scoped name when you need to avoid name
collision. It is also possible to import individual functions. Check
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

On-line documentation is [available][17].

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
[3]: https://github.com/kyamagu/mexopencv/releases/tag/v3.0.0
[4]: https://github.com/kyamagu/mexopencv/releases/tag/v2.4.11
[5]: https://github.com/kyamagu/mexopencv/tree/v2.3
[6]: https://github.com/kyamagu/mexopencv/tree/v2.1
[7]: https://github.com/kyamagu/mexopencv/wiki
[8]: https://www.mathworks.com/products/matlab/
[9]: https://www.gnu.org/software/octave/
[10]: http://opencv.org/
[11]: https://github.com/opencv/opencv
[12]: https://github.com/opencv/opencv_contrib
[13]: http://packages.ubuntu.com/zesty/libopencv-dev
[14]: https://people.freedesktop.org/~dbn/pkg-config-guide.html
[15]: http://brew.sh/
[16]: https://github.com/kyamagu/mexopencv/wiki/Installation-%28Windows%2C-MATLAB%2C-OpenCV-3%29
[17]: http://kyamagu.github.io/mexopencv/matlab
