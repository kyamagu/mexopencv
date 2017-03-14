/**
 * @file mexopencv_stitching.hpp
 * @brief Common definitions for the stitching module
 * @ingroup stitching
 * @author Amro
 * @date 2016
 *
 * Header file for MEX-functions that use stitching module from OpenCV library.
 * This file includes maps for option processing, as well as functions for
 * creating instances of classes from parsed arguments.
 */
#ifndef MEXOPENCV_STITCHING_HPP
#define MEXOPENCV_STITCHING_HPP

#include "mexopencv.hpp"
#include "opencv2/stitching.hpp"
#include "opencv2/stitching/detail/timelapsers.hpp"

// check HAVE_OPENCV_XFEATURES2D for some of the functionalities
#include "opencv2/opencv_modules.hpp"
//TODO: check HAVE_CUDA for some of the functionalities
//#include "opencv2/cvconfig.h"


// ==================== XXX ====================

/// Stitcher error status types
const ConstMap<cv::Stitcher::Status, std::string> StitcherStatusInvMap =
    ConstMap<cv::Stitcher::Status, std::string>
    (cv::Stitcher::OK,                            "OK")
    (cv::Stitcher::ERR_NEED_MORE_IMGS,            "ERR_NEED_MORE_IMGS")
    (cv::Stitcher::ERR_HOMOGRAPHY_EST_FAIL,       "ERR_HOMOGRAPHY_EST_FAIL")
    (cv::Stitcher::ERR_CAMERA_PARAMS_ADJUST_FAIL, "ERR_CAMERA_PARAMS_ADJUST_FAIL");

/*
/// ExposureCompensator types
const ConstMap<std::string, int> ExposureCompensatorTypes = ConstMap<std::string, int>
    ("No",         cv::detail::ExposureCompensator::NO)
    ("Gain",       cv::detail::ExposureCompensator::GAIN)
    ("GainBlocks", cv::detail::ExposureCompensator::GAIN_BLOCKS);
*/

/// Cost function types
const ConstMap<std::string, cv::detail::DpSeamFinder::CostFunction> DpCostFunctionMap =
    ConstMap<std::string, cv::detail::DpSeamFinder::CostFunction>
    ("Color",     cv::detail::DpSeamFinder::COLOR)
    ("ColorGrad", cv::detail::DpSeamFinder::COLOR_GRAD);

/// Graph-Cut cost types
const ConstMap<std::string, int> GraphCutCostTypeMap = ConstMap<std::string, int>
    ("Color",     cv::detail::GraphCutSeamFinderBase::COST_COLOR)
    ("ColorGrad", cv::detail::GraphCutSeamFinderBase::COST_COLOR_GRAD);

/*
/// blender types
const ConstMap<std::string, int> BlenderTypesMap = ConstMap<std::string, int>
    ("No",        cv::detail::Blender::NO)
    ("Feather",   cv::detail::Blender::FEATHER)
    ("MultiBand", cv::detail::Blender::MULTI_BAND);
*/

/// wave correction kinds
const ConstMap<std::string, cv::detail::WaveCorrectKind> WaveCorrectionMap =
    ConstMap<std::string, cv::detail::WaveCorrectKind>
    ("Horiz", cv::detail::WAVE_CORRECT_HORIZ)
    ("Vert",  cv::detail::WAVE_CORRECT_VERT);

/// inverse wave correction kinds
const ConstMap<cv::detail::WaveCorrectKind, std::string> WaveCorrectionInvMap =
    ConstMap<cv::detail::WaveCorrectKind, std::string>
    (cv::detail::WAVE_CORRECT_HORIZ, "Horiz")
    (cv::detail::WAVE_CORRECT_VERT,  "Vert");


// ==================== XXX ====================

/** Convert MxArray to cv::details::ImageFeatures
 * @param arr struct-array MxArray object
 * @param idx linear index of the struct array element
 * @return image features object
 */
cv::detail::ImageFeatures MxArrayToImageFeatures(const MxArray &arr, mwIndex idx = 0);

/** Convert MxArray to cv::details::MatchesInfo
 * @param arr struct-array MxArray object
 * @param idx linear index of the struct array element
 * @return matches info object
 */
cv::detail::MatchesInfo MxArrayToMatchesInfo(const MxArray &arr, mwIndex idx = 0);

/** Convert MxArray to cv::details::CameraParams
 * @param arr struct-array MxArray object
 * @param idx linear index of the struct array element
 * @return camera params object
 */
cv::detail::CameraParams MxArrayToCameraParams(const MxArray &arr, mwIndex idx = 0);

/** Convert MxArray std::vector<cv::details::ImageFeatures>
 * @param arr struct-array MxArray object
 * @return vector of image features objects
 */
std::vector<cv::detail::ImageFeatures> MxArrayToVectorImageFeatures(const MxArray &arr);

/** Convert MxArray to std::vector<cv::details::MatchesInfo>
 * @param arr struct-array MxArray object
 * @return vector of matches info objects
 */
std::vector<cv::detail::MatchesInfo> MxArrayToVectorMatchesInfo(const MxArray &arr);

/** Convert MxArray to std::vector<cv::details::CameraParams>
 * @param arr struct-array MxArray object
 * @return vector of camera params objects
 */
std::vector<cv::detail::CameraParams> MxArrayToVectorCameraParams(const MxArray &arr);

/** Convert image features to scalar struct
 * @param feat instance of image features
 * @return scalar struct MxArray object
 */
MxArray toStruct(const cv::detail::ImageFeatures &feat);

/** Convert matches to scalar struct
 * @param matches_info instance of matches info
 * @return scalar struct MxArray object
 */
MxArray toStruct(const cv::detail::MatchesInfo &matches_info);

/** Convert cameras params to scalar struct
 * @param params instance of camera params
 * @return scalar struct MxArray object
 */
MxArray toStruct(const cv::detail::CameraParams &params);

/** Convert image features to struct array
 * @param features vector of image features
 * @return struct-array MxArray object
 */
MxArray toStruct(const std::vector<cv::detail::ImageFeatures> &features);

/** Convert matches to struct array
 * @param pairwise_matches vector of matches info
 * @return struct-array MxArray object
 */
MxArray toStruct(const std::vector<cv::detail::MatchesInfo> &pairwise_matches);

/** Convert cameras params to struct array
 * @param cameras vector of camera params
 * @return struct-array MxArray object
 */
MxArray toStruct(const std::vector<cv::detail::CameraParams> &cameras);


// ==================== XXX ====================

/** Convert a FeaturesFinder to MxArray
 * @param p smart poitner to an instance of FeaturesFinder
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::detail::FeaturesFinder> p);

/** Convert a FeaturesMatcher to MxArray
 * @param p smart poitner to an instance of FeaturesMatcher
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::detail::FeaturesMatcher> p);

/** Convert a Estimator to MxArray
 * @param p smart poitner to an instance of Estimator
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::detail::Estimator> p);

/** Convert a BundleAdjusterBase to MxArray
 * @param p smart poitner to an instance of BundleAdjusterBase
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::detail::BundleAdjusterBase> p);

/** Convert a WarperCreator to MxArray
 * @param p smart poitner to an instance of WarperCreator
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::WarperCreator> p);

/** Convert a ExposureCompensator to MxArray
 * @param p smart poitner to an instance of ExposureCompensator
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::detail::ExposureCompensator> p);

/** Convert a SeamFinder to MxArray
 * @param p smart poitner to an instance of SeamFinder
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::detail::SeamFinder> p);

/** Convert a Blender to MxArray
 * @param p smart poitner to an instance of Blender
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::detail::Blender> p);


// ==================== XXX ====================

/** Create an instance of OrbFeaturesFinder using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created OrbFeaturesFinder
 */
cv::Ptr<cv::detail::OrbFeaturesFinder> createOrbFeaturesFinder(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of AKAZEFeaturesFinder using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created AKAZEFeaturesFinder
 */
cv::Ptr<cv::detail::AKAZEFeaturesFinder> createAKAZEFeaturesFinder(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

#ifdef HAVE_OPENCV_XFEATURES2D
/** Create an instance of SurfFeaturesFinder using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created SurfFeaturesFinder
 */
cv::Ptr<cv::detail::SurfFeaturesFinder> createSurfFeaturesFinder(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);
#endif

/** Create an instance of FeaturesFinder using options in arguments
 * @param type features finder type, one of:
 *    - "OrbFeaturesFinder"
 *    - "AKAZEFeaturesFinder"
 *    - "SurfFeaturesFinder" (requires `xfeatures2d` module)
 *    - "SurfFeaturesFinderGpu" (requires CUDA and `xfeatures2d` module)
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created FeaturesFinder
 */
cv::Ptr<cv::detail::FeaturesFinder> createFeaturesFinder(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of BestOf2NearestMatcher using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created BestOf2NearestMatcher
 */
cv::Ptr<cv::detail::BestOf2NearestMatcher> createBestOf2NearestMatcher(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of BestOf2NearestRangeMatcher using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created BestOf2NearestRangeMatcher
 */
cv::Ptr<cv::detail::BestOf2NearestRangeMatcher> createBestOf2NearestRangeMatcher(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of AffineBestOf2NearestMatcher using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created AffineBestOf2NearestMatcher
 */
cv::Ptr<cv::detail::AffineBestOf2NearestMatcher> createAffineBestOf2NearestMatcher(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of FeaturesMatcher using options in arguments
 * @param type features matcher type, one of:
 *    - "BestOf2NearestMatcher"
 *    - "BestOf2NearestRangeMatcher"
 *    - "AffineBestOf2NearestMatcher"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created FeaturesMatcher
 */
cv::Ptr<cv::detail::FeaturesMatcher> createFeaturesMatcher(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of HomographyBasedEstimator using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created HomographyBasedEstimator
 */
cv::Ptr<cv::detail::HomographyBasedEstimator> createHomographyBasedEstimator(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of Estimator using options in arguments
 * @param type features matcher type, one of:
 *    - "HomographyBasedEstimator"
 *    - "AffineBasedEstimator"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created Estimator
 */
cv::Ptr<cv::detail::Estimator> createEstimator(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of BundleAdjusterBase using options in arguments
 * @param type bundle adjuster type, one of:
 *    - "NoBundleAdjuster"
 *    - "BundleAdjusterRay"
 *    - "BundleAdjusterReproj"
 *    - "BundleAdjusterAffine"
 *    - "BundleAdjusterAffinePartial"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created BundleAdjusterBase
 */
cv::Ptr<cv::detail::BundleAdjusterBase> createBundleAdjusterBase(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of CompressedRectilinearWarper using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created CompressedRectilinearWarper
 */
cv::Ptr<cv::CompressedRectilinearWarper> createCompressedRectilinearWarper(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of CompressedRectilinearPortraitWarper using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created CompressedRectilinearPortraitWarper
 */
cv::Ptr<cv::CompressedRectilinearPortraitWarper> createCompressedRectilinearPortraitWarper(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of PaniniWarper using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created PaniniWarper
 */
cv::Ptr<cv::PaniniWarper> createPaniniWarper(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of PaniniPortraitWarper using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created PaniniPortraitWarper
 */
cv::Ptr<cv::PaniniPortraitWarper> createPaniniPortraitWarper(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of WarperCreator using options in arguments
 * @param type warper creator type, one of:
 *   - "PlaneWarper"
 *   - "PlaneWarperGpu" (requires CUDA)
 *   - "AffineWarper"
 *   - "CylindricalWarper"
 *   - "CylindricalWarperGpu" (requires CUDA)
 *   - "SphericalWarper"
 *   - "SphericalWarperGpu" (requires CUDA)
 *   - "FisheyeWarper"
 *   - "StereographicWarper"
 *   - "CompressedRectilinearWarper"
 *   - "CompressedRectilinearPortraitWarper"
 *   - "PaniniWarper"
 *   - "PaniniPortraitWarper"
 *   - "MercatorWarper"
 *   - "TransverseMercatorWarper"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created WarperCreator
 */
cv::Ptr<cv::WarperCreator> createWarperCreator(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of RotationWarper using options in arguments
 * @param type rotation warper type, passed to createWarperCreator()
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @param scale
 * @return smart pointer to created RotationWarper
 */
cv::Ptr<cv::detail::RotationWarper> createRotationWarper(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last,
    float scale = 1.0f);

/** Create an instance of BlocksGainCompensator using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created BlocksGainCompensator
 */
cv::Ptr<cv::detail::BlocksGainCompensator> createBlocksGainCompensator(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of ExposureCompensator using options in arguments
 * @param type exposure compensator type, one of:
 *    - "NoExposureCompensator"
 *    - "GainCompensator"
 *    - "BlocksGainCompensator"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created ExposureCompensator
 */
cv::Ptr<cv::detail::ExposureCompensator> createExposureCompensator(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of DpSeamFinder using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created DpSeamFinder
 */
cv::Ptr<cv::detail::DpSeamFinder> createDpSeamFinder(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of GraphCutSeamFinder using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created GraphCutSeamFinder
 */
cv::Ptr<cv::detail::GraphCutSeamFinder> createGraphCutSeamFinder(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of SeamFinder using options in arguments
 * @param type seam finder type, one of:
 *    - "NoSeamFinder"
 *    - "VoronoiSeamFinder"
 *    - "DpSeamFinder"
 *    - "GraphCutSeamFinder"
 *    - "GraphCutSeamFinderGpu" (requires CUDA)
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created SeamFinder
 */
cv::Ptr<cv::detail::SeamFinder> createSeamFinder(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of FeatherBlender using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created FeatherBlender
 */
cv::Ptr<cv::detail::FeatherBlender> createFeatherBlender(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of MultiBandBlender using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created MultiBandBlender
 */
cv::Ptr<cv::detail::MultiBandBlender> createMultiBandBlender(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of Blender using options in arguments
 * @param type blender type, one of:
 *    - "NoBlender"
 *    - "FeatherBlender"
 *    - "MultiBandBlender"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created Blender
 */
cv::Ptr<cv::detail::Blender> createBlender(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

#endif
