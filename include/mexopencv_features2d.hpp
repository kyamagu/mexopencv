/**
* @file mexopencv_features2d.hpp
* @brief Common definitions for the features2d and xfeatures2d modules
* @autor Amro
* @date 2015
*/
#ifndef __MEXOPENCV_FEATURES2D_HPP__
#define __MEXOPENCV_FEATURES2D_HPP__

#include "mexopencv.hpp"
#include "opencv2/opencv_modules.hpp"
using namespace cv;
using std::vector;
using std::string;

#ifdef HAVE_OPENCV_XFEATURES2D
#include "opencv2/xfeatures2d.hpp"
using namespace cv::xfeatures2d;
#endif


// ==================== Feature Detection and Description ====================

/// ORB score types
const ConstMap<string, int> ORBScoreType = ConstMap<string, int>
    ("Harris", ORB::HARRIS_SCORE)
    ("FAST",   ORB::FAST_SCORE);

/// inverse ORB score types
const ConstMap<int, string> ORBScoreTypeInv = ConstMap<int, string>
    (ORB::HARRIS_SCORE, "Harris")
    (ORB::FAST_SCORE,   "FAST");

/// FAST types
const ConstMap<string, int> FASTTypeMap = ConstMap<string, int>
    ("TYPE_5_8",  FastFeatureDetector::TYPE_5_8)
    ("TYPE_7_12", FastFeatureDetector::TYPE_7_12)
    ("TYPE_9_16", FastFeatureDetector::TYPE_9_16);

/// inverse FAST types
const ConstMap<int, string> FASTTypeMapInv = ConstMap<int, string>
    (FastFeatureDetector::TYPE_5_8,  "TYPE_5_8")
    (FastFeatureDetector::TYPE_7_12, "TYPE_7_12")
    (FastFeatureDetector::TYPE_9_16, "TYPE_9_16");

/// KAZE Diffusivity type
const ConstMap<string, int> KAZEDiffusivityType = ConstMap <string, int>
    ("PM_G1",       KAZE::DIFF_PM_G1)
    ("PM_G2",       KAZE::DIFF_PM_G2)
    ("WEICKERT",    KAZE::DIFF_WEICKERT)
    ("CHARBONNIER", KAZE::DIFF_CHARBONNIER);

/// inverse KAZE Diffusivity type
const ConstMap<int, string> KAZEDiffusivityTypeInv = ConstMap <int, string>
    (KAZE::DIFF_PM_G1,       "PM_G1")
    (KAZE::DIFF_PM_G2,       "PM_G2")
    (KAZE::DIFF_WEICKERT,    "WEICKERT")
    (KAZE::DIFF_CHARBONNIER, "CHARBONNIER");

/// AKAZE descriptor type
const ConstMap<string, int> AKAZEDescriptorType = ConstMap <string, int>
    ("KAZEUpright", AKAZE::DESCRIPTOR_KAZE_UPRIGHT)
    ("KAZE",        AKAZE::DESCRIPTOR_KAZE)
    ("MLDBUpright", AKAZE::DESCRIPTOR_MLDB_UPRIGHT)
    ("MLDB",        AKAZE::DESCRIPTOR_MLDB);

/// inverse AKAZE descriptor type
const ConstMap<int, string> AKAZEDescriptorTypeInv = ConstMap <int, string>
    (AKAZE::DESCRIPTOR_KAZE_UPRIGHT, "KAZEUpright")
    (AKAZE::DESCRIPTOR_KAZE,         "KAZE")
    (AKAZE::DESCRIPTOR_MLDB_UPRIGHT, "MLDBUpright")
    (AKAZE::DESCRIPTOR_MLDB,         "MLDB");

#ifdef HAVE_OPENCV_XFEATURES2D
/// AgastFeatureDetector types
const ConstMap<string, int> AgastTypeMap = ConstMap<string, int>
    ("AGAST_5_8",   AgastFeatureDetector::AGAST_5_8)
    ("AGAST_7_12d", AgastFeatureDetector::AGAST_7_12d)
    ("AGAST_7_12s", AgastFeatureDetector::AGAST_7_12s)
    ("OAST_9_16",   AgastFeatureDetector::OAST_9_16);

/// inverse AgastFeatureDetector types
const ConstMap<int, string> AgastTypeInvMap = ConstMap<int, string>
    (AgastFeatureDetector::AGAST_5_8,   "AGAST_5_8")
    (AgastFeatureDetector::AGAST_7_12d, "AGAST_7_12d")
    (AgastFeatureDetector::AGAST_7_12s, "AGAST_7_12s")
    (AgastFeatureDetector::OAST_9_16,   "OAST_9_16");
#endif


// ==================== Descriptor Matching ====================


#endif
