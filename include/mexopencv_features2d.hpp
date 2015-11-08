/**
 * @file mexopencv_features2d.hpp
 * @brief Common definitions for the features2d and xfeatures2d modules
 * @author Amro
 * @date 2015
 *
 * Header file for MEX-functions that use features2d or xfeatures2d modules
 * from OpenCV library. This file includes maps for option processing, as well
 * as functions for creating instances of Features2D-derived classes from
 * parsed arguments.
*/
#ifndef __MEXOPENCV_FEATURES2D_HPP__
#define __MEXOPENCV_FEATURES2D_HPP__

#include "mexopencv.hpp"

#include "opencv2/opencv_modules.hpp"
#ifdef HAVE_OPENCV_XFEATURES2D
#include "opencv2/xfeatures2d.hpp"
#endif


// ==================== Feature Detection and Description ====================

/// ORB score types
const ConstMap<std::string, int> ORBScoreType = ConstMap<std::string, int>
    ("Harris", cv::ORB::HARRIS_SCORE)
    ("FAST",   cv::ORB::FAST_SCORE);

/// inverse ORB score types
const ConstMap<int, std::string> ORBScoreTypeInv = ConstMap<int, std::string>
    (cv::ORB::HARRIS_SCORE, "Harris")
    (cv::ORB::FAST_SCORE,   "FAST");

/// FAST types
const ConstMap<std::string, int> FASTTypeMap = ConstMap<std::string, int>
    ("TYPE_5_8",  cv::FastFeatureDetector::TYPE_5_8)
    ("TYPE_7_12", cv::FastFeatureDetector::TYPE_7_12)
    ("TYPE_9_16", cv::FastFeatureDetector::TYPE_9_16);

/// inverse FAST types
const ConstMap<int, std::string> FASTTypeMapInv = ConstMap<int, std::string>
    (cv::FastFeatureDetector::TYPE_5_8,  "TYPE_5_8")
    (cv::FastFeatureDetector::TYPE_7_12, "TYPE_7_12")
    (cv::FastFeatureDetector::TYPE_9_16, "TYPE_9_16");

/// KAZE Diffusivity type
const ConstMap<std::string, int> KAZEDiffusivityType = ConstMap<std::string, int>
    ("PM_G1",       cv::KAZE::DIFF_PM_G1)
    ("PM_G2",       cv::KAZE::DIFF_PM_G2)
    ("WEICKERT",    cv::KAZE::DIFF_WEICKERT)
    ("CHARBONNIER", cv::KAZE::DIFF_CHARBONNIER);

/// inverse KAZE Diffusivity type
const ConstMap<int, std::string> KAZEDiffusivityTypeInv = ConstMap<int, std::string>
    (cv::KAZE::DIFF_PM_G1,       "PM_G1")
    (cv::KAZE::DIFF_PM_G2,       "PM_G2")
    (cv::KAZE::DIFF_WEICKERT,    "WEICKERT")
    (cv::KAZE::DIFF_CHARBONNIER, "CHARBONNIER");

/// AKAZE descriptor type
const ConstMap<std::string, int> AKAZEDescriptorType = ConstMap<std::string, int>
    ("KAZEUpright", cv::AKAZE::DESCRIPTOR_KAZE_UPRIGHT)
    ("KAZE",        cv::AKAZE::DESCRIPTOR_KAZE)
    ("MLDBUpright", cv::AKAZE::DESCRIPTOR_MLDB_UPRIGHT)
    ("MLDB",        cv::AKAZE::DESCRIPTOR_MLDB);

/// inverse AKAZE descriptor type
const ConstMap<int, std::string> AKAZEDescriptorTypeInv = ConstMap<int, std::string>
    (cv::AKAZE::DESCRIPTOR_KAZE_UPRIGHT, "KAZEUpright")
    (cv::AKAZE::DESCRIPTOR_KAZE,         "KAZE")
    (cv::AKAZE::DESCRIPTOR_MLDB_UPRIGHT, "MLDBUpright")
    (cv::AKAZE::DESCRIPTOR_MLDB,         "MLDB");

/// AGAST neighborhood types
const ConstMap<std::string, int> AgastTypeMap = ConstMap<std::string, int>
    ("AGAST_5_8",   cv::AgastFeatureDetector::AGAST_5_8)
    ("AGAST_7_12d", cv::AgastFeatureDetector::AGAST_7_12d)
    ("AGAST_7_12s", cv::AgastFeatureDetector::AGAST_7_12s)
    ("OAST_9_16",   cv::AgastFeatureDetector::OAST_9_16);

/// inverse AGAST neighborhood types
const ConstMap<int, std::string> AgastTypeInvMap = ConstMap<int, std::string>
    (cv::AgastFeatureDetector::AGAST_5_8,   "AGAST_5_8")
    (cv::AgastFeatureDetector::AGAST_7_12d, "AGAST_7_12d")
    (cv::AgastFeatureDetector::AGAST_7_12s, "AGAST_7_12s")
    (cv::AgastFeatureDetector::OAST_9_16,   "OAST_9_16");

#ifdef HAVE_OPENCV_XFEATURES2D
/// DAISY normalization types
const ConstMap<std::string, int> DAISYNormType = ConstMap<std::string, int>
    ("None",    cv::xfeatures2d::DAISY::NRM_NONE)
    ("Partial", cv::xfeatures2d::DAISY::NRM_PARTIAL)
    ("Full",    cv::xfeatures2d::DAISY::NRM_FULL)
    ("SIFT",    cv::xfeatures2d::DAISY::NRM_SIFT);

/// inverse DAISY normalization types
const ConstMap<int, std::string> DAISYNormTypeInv = ConstMap<int, std::string>
    (cv::xfeatures2d::DAISY::NRM_NONE,    "None")
    (cv::xfeatures2d::DAISY::NRM_PARTIAL, "Partial")
    (cv::xfeatures2d::DAISY::NRM_FULL,    "Full")
    (cv::xfeatures2d::DAISY::NRM_SIFT,    "SIFT");
#endif

/** Create an instance of BRISK using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::BRISK
 */
cv::Ptr<cv::BRISK> createBRISK(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of ORB using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::ORB
 */
cv::Ptr<cv::ORB> createORB(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of MSER using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::MSER
 */
cv::Ptr<cv::MSER> createMSER(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of FastFeatureDetector using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::FastFeatureDetector
 */
cv::Ptr<cv::FastFeatureDetector> createFastFeatureDetector(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of GFTTDetector using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::GFTTDetector
 */
cv::Ptr<cv::GFTTDetector> createGFTTDetector(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of SimpleBlobDetector using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::SimpleBlobDetector
 */
cv::Ptr<cv::SimpleBlobDetector> createSimpleBlobDetector(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of KAZE using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::KAZE
 */
cv::Ptr<cv::KAZE> createKAZE(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of AKAZE using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::AKAZE
 */
cv::Ptr<cv::AKAZE> createAKAZE(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of AgastFeatureDetector using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::AgastFeatureDetector
 */
cv::Ptr<cv::AgastFeatureDetector> createAgastFeatureDetector(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

#ifdef HAVE_OPENCV_XFEATURES2D
/** Create an instance of SIFT using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::xfeatures2d::SIFT
 */
cv::Ptr<cv::xfeatures2d::SIFT> createSIFT(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of SURF using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::xfeatures2d::SURF
 */
cv::Ptr<cv::xfeatures2d::SURF> createSURF(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of FREAK using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::xfeatures2d::FREAK
 */
cv::Ptr<cv::xfeatures2d::FREAK> createFREAK(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of StarDetector using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::xfeatures2d::StarDetector
 */
cv::Ptr<cv::xfeatures2d::StarDetector> createStarDetector(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of BriefDescriptorExtractor using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::xfeatures2d::BriefDescriptorExtractor
 */
cv::Ptr<cv::xfeatures2d::BriefDescriptorExtractor> createBriefDescriptorExtractor(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of LUCID using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::xfeatures2d::LUCID
 */
cv::Ptr<cv::xfeatures2d::LUCID> createLUCID(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of LATCH using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::xfeatures2d::LATCH
 */
cv::Ptr<cv::xfeatures2d::LATCH> createLATCH(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of DAISY using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::xfeatures2d::DAISY
 */
cv::Ptr<cv::xfeatures2d::DAISY> createDAISY(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);
#endif

/** Factory function for FeatureDetector creation
 * @param type feature detector type, one of:
 *    - "BRISK"
 *    - "ORB"
 *    - "MSER"
 *    - "FastFeatureDetector"
 *    - "GFTTDetector"
 *    - "SimpleBlobDetector"
 *    - "KAZE"
 *    - "AKAZE"
 *    - "AgastFeatureDetector"
 *    - "SIFT" (requires `xfeatures2d` module)
 *    - "SURF" (requires `xfeatures2d` module)
 *    - "StarDetector" (requires `xfeatures2d` module)
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::FeatureDetector
 */
cv::Ptr<cv::FeatureDetector> createFeatureDetector(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Factory function for DescriptorExtractor creation
 * @param type descriptor extractor type, one of:
 *    - "BRISK"
 *    - "ORB"
 *    - "KAZE"
 *    - "AKAZE"
 *    - "SIFT" (requires `xfeatures2d` module)
 *    - "SURF" (requires `xfeatures2d` module)
 *    - "FREAK" (requires `xfeatures2d` module)
 *    - "BriefDescriptorExtractor" (requires `xfeatures2d` module)
 *    - "LUCID" (requires `xfeatures2d` module)
 *    - "LATCH" (requires `xfeatures2d` module)
 *    - "DAISY" (requires `xfeatures2d` module)
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::DescriptorExtractor
 */
cv::Ptr<cv::DescriptorExtractor> createDescriptorExtractor(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);


// ==================== Descriptor Matching ====================

/** Create an instance of FlannBasedMatcher using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::FlannBasedMatcher
 */
cv::Ptr<cv::FlannBasedMatcher> createFlannBasedMatcher(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of BFMatcher using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::BFMatcher
 */
cv::Ptr<cv::BFMatcher> createBFMatcher(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Factory function for DescriptorMatcher creation
 * @param type descriptor matcher type, one of:
 *    - "BruteForce"
 *    - "BruteForce-L1"
 *    - "BruteForce-SL2"
 *    - "BruteForce-Hamming" or "BruteForce-HammingLUT"
 *    - "BruteForce-Hamming(2)"
 *    - "FlannBased"
 *    .
 *    Or:
 *    - "FlannBasedMatcher"
 *    - "BFMatcher"
 *    .
 *    The last two matcher types are the ones that accept extra arguments
 *    passed to the corresponding create functions.
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to an instance cv::DescriptorMatcher
 */
cv::Ptr<cv::DescriptorMatcher> createDescriptorMatcher(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

#endif
