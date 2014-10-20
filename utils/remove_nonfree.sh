#!/usr/bin/env bash
rm src/+cv/SIFT.cpp
rm src/+cv/SURF.cpp
grep -lR '#include "opencv2/nonfree/nonfree.hpp"' src/ | xargs sed -i -e 's/#include "opencv2\/nonfree\/nonfree.hpp"//g'
grep -lR 'initModule_nonfree();' src/ | xargs sed -i -e 's/[ ]*if (last_id==0)//g'
grep -lR 'initModule_nonfree();' src/ | xargs sed -i -e 's/[ ]*initModule_nonfree();//g'
rm test/unit_tests/TestSIFT.m
rm test/unit_tests/TestSURF.m
sed -i -e 's/SIFT/ORB/g' test/unit_tests/TestBOWImgDescriptorExtractor.m
rm samples/SURF_descriptor.m
rm samples/SURF_detector.m
