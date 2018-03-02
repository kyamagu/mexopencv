/**
 * @file mexopencv_videostab.hpp
 * @brief Common definitions for the videostab module
 * @ingroup videostab
 * @author Amro
 * @date 2016
 *
 * Header file for MEX-functions that use videostab module from OpenCV library.
 * This file includes maps for option processing, as well as functions for
 * creating instances of cv::videostab:: classes from parsed arguments.
 */
#ifndef MEXOPENCV_VIDEOSTAB_HPP
#define MEXOPENCV_VIDEOSTAB_HPP

#include "mexopencv.hpp"
#include "mexopencv_features2d.hpp"
#include "opencv2/videostab.hpp"


// ==================== XXX ====================

/// motion model types for option processing
const ConstMap<std::string, cv::videostab::MotionModel> MotionModelMap =
    ConstMap<std::string, cv::videostab::MotionModel>
    ("Translation",         cv::videostab::MM_TRANSLATION)
    ("TranslationAndScale", cv::videostab::MM_TRANSLATION_AND_SCALE)
    ("Rotation",            cv::videostab::MM_ROTATION)
    ("Rigid",               cv::videostab::MM_RIGID)
    ("Similarity",          cv::videostab::MM_SIMILARITY)
    ("Affine",              cv::videostab::MM_AFFINE)
    ("Homography",          cv::videostab::MM_HOMOGRAPHY)
    ("Unknown",             cv::videostab::MM_UNKNOWN);

/// inverse motion model types for option processing
const ConstMap<cv::videostab::MotionModel, std::string> MotionModelInvMap =
    ConstMap<cv::videostab::MotionModel, std::string>
    (cv::videostab::MM_TRANSLATION,           "Translation")
    (cv::videostab::MM_TRANSLATION_AND_SCALE, "TranslationAndScale")
    (cv::videostab::MM_ROTATION,              "Rotation")
    (cv::videostab::MM_RIGID,                 "Rigid")
    (cv::videostab::MM_SIMILARITY,            "Similarity")
    (cv::videostab::MM_AFFINE,                "Affine")
    (cv::videostab::MM_HOMOGRAPHY,            "Homography")
    (cv::videostab::MM_UNKNOWN,               "Unknown");

/// Logger class to log messages from videostab in MATLAB
class LogToMATLAB : public cv::videostab::ILog
{
public:
    virtual void print(const char *format, ...);
};

/** Convert MxArray to RansacParams
 * @param arr input MxArray structure
 * @return output instance of RansacParams
 */
cv::videostab::RansacParams toRansacParams(const MxArray &arr);

/** Convert RansacParams to MxArray
 * @param params input instance of RansacParams
 * @return output MxArray structure
 */
MxArray toStruct(const cv::videostab::RansacParams &params);


// ==================== XXX ====================

/** Convert a ILog to MxArray
 * @param p smart poitner to an instance of ILog
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::videostab::ILog> p);

/** Convert a IFrameSource to MxArray
 * @param p smart poitner to an instance of IFrameSource
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::videostab::IFrameSource> p);

/** Convert a DeblurerBase to MxArray
 * @param p smart poitner to an instance of DeblurerBase
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::videostab::DeblurerBase> p);

/** Convert a MotionEstimatorBase to MxArray
 * @param p smart poitner to an instance of MotionEstimatorBase
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::videostab::MotionEstimatorBase> p);

/** Convert a FeatureDetector to MxArray
 * @param p smart poitner to an instance of FeatureDetector
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::FeatureDetector> p);

/** Convert a ISparseOptFlowEstimator to MxArray
 * @param p smart poitner to an instance of ISparseOptFlowEstimator
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::videostab::ISparseOptFlowEstimator> p);

/** Convert a IDenseOptFlowEstimator to MxArray
 * @param p smart poitner to an instance of IDenseOptFlowEstimator
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::videostab::IDenseOptFlowEstimator> p);

/** Convert a IOutlierRejector to MxArray
 * @param p smart poitner to an instance of IOutlierRejector
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::videostab::IOutlierRejector> p);

/** Convert a ImageMotionEstimatorBase to MxArray
 * @param p smart poitner to an instance of ImageMotionEstimatorBase
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::videostab::ImageMotionEstimatorBase> p);

/** Convert a InpainterBase to MxArray
 * @param p smart poitner to an instance of InpainterBase
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::videostab::InpainterBase> p);

/** Convert a MotionFilterBase to MxArray
 * @param p smart poitner to an instance of MotionFilterBase
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::videostab::MotionFilterBase> p);

/** Convert a IMotionStabilizer to MxArray
 * @param p smart poitner to an instance of IMotionStabilizer
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::videostab::IMotionStabilizer> p);

/** Convert a WobbleSuppressorBase to MxArray
 * @param p smart poitner to an instance of WobbleSuppressorBase
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::videostab::WobbleSuppressorBase> p);


// ==================== XXX ====================

/** Create an instance of ILog of the specified type
 * @param type logger type, one of:
 *    - "LogToMATLAB"
 *    - "LogToStdout" (Note: output wont show in MATLAB)
 *    - "NullLog"
 * @return smart pointer to created ILog
 */
cv::Ptr<cv::videostab::ILog> createILog(const std::string& type);

/** Create an instance of VideoFileSource using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created VideoFileSource
 */
cv::Ptr<cv::videostab::VideoFileSource> createVideoFileSource(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of IFrameSource using options in arguments
 * @param type frame source type, one of:
 *    - "VideoFileSource"
 *    - "NullFrameSource"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created IFrameSource
 */
cv::Ptr<cv::videostab::IFrameSource> createIFrameSource(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of WeightingDeblurer using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created WeightingDeblurer
 */
cv::Ptr<cv::videostab::WeightingDeblurer> createWeightingDeblurer(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of DeblurerBase using options in arguments
 * @param type deblurer type, one of:
 *    - "WeightingDeblurer"
 *    - "NullDeblurer"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created DeblurerBase
 */
cv::Ptr<cv::videostab::DeblurerBase> createDeblurerBase(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of MotionEstimatorL1 using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created MotionEstimatorL1
 */
cv::Ptr<cv::videostab::MotionEstimatorL1> createMotionEstimatorL1(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of MotionEstimatorRansacL2 using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created MotionEstimatorRansacL2
 */
cv::Ptr<cv::videostab::MotionEstimatorRansacL2> createMotionEstimatorRansacL2(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of MotionEstimatorBase using options in arguments
 * @param type motion estimator type, one of:
 *    - "MotionEstimatorL1" (requires CLP library)
 *    - "MotionEstimatorRansacL2"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created MotionEstimatorBase
 */
cv::Ptr<cv::videostab::MotionEstimatorBase> createMotionEstimatorBase(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of SparsePyrLkOptFlowEstimator using options in
 *  arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created SparsePyrLkOptFlowEstimator
 */
cv::Ptr<cv::videostab::SparsePyrLkOptFlowEstimator> createSparsePyrLkOptFlowEstimator(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of ISparseOptFlowEstimator using options in arguments
 * @param type sparse optical flow estimator type, one of:
 *    - "SparsePyrLkOptFlowEstimator"
 *    - "SparsePyrLkOptFlowEstimatorGpu" (requires CUDA)
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created ISparseOptFlowEstimator
 */
cv::Ptr<cv::videostab::ISparseOptFlowEstimator> createISparseOptFlowEstimator(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of IDenseOptFlowEstimator using options in arguments
 * @param type dense optical flow estimator type, one of:
 *    - "DensePyrLkOptFlowEstimatorGpu" (requires CUDA)
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created IDenseOptFlowEstimator
 */
cv::Ptr<cv::videostab::IDenseOptFlowEstimator> createIDenseOptFlowEstimator(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of createTranslationBasedLocalOutlierRejector using
 *  options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created createTranslationBasedLocalOutlierRejector
 */
cv::Ptr<cv::videostab::TranslationBasedLocalOutlierRejector> createTranslationBasedLocalOutlierRejector(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of IOutlierRejector using options in arguments
 * @param type outlier rejector type, one of:
 *    - "TranslationBasedLocalOutlierRejector"
 *    - "NullOutlierRejector"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created IOutlierRejector
 */
cv::Ptr<cv::videostab::IOutlierRejector> createIOutlierRejector(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of KeypointBasedMotionEstimator using options in
 *  arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created KeypointBasedMotionEstimator
 */
cv::Ptr<cv::videostab::KeypointBasedMotionEstimator> createKeypointBasedMotionEstimator(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of FromFileMotionReader using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created FromFileMotionReader
 */
cv::Ptr<cv::videostab::FromFileMotionReader> createFromFileMotionReader(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of ToFileMotionWriter using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created ToFileMotionWriter
 */
cv::Ptr<cv::videostab::ToFileMotionWriter> createToFileMotionWriter(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of ImageMotionEstimatorBase using options in arguments
 * @param type image motion estimator type, one of:
 *    - "KeypointBasedMotionEstimator"
 *    - "FromFileMotionReader"
 *    - "ToFileMotionWriter"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created ImageMotionEstimatorBase
 */
cv::Ptr<cv::videostab::ImageMotionEstimatorBase> createImageMotionEstimator(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of ColorInpainter using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created ColorInpainter
 */
cv::Ptr<cv::videostab::ColorInpainter> createColorInpainter(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of ColorAverageInpainter using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created ColorAverageInpainter
 */
cv::Ptr<cv::videostab::ColorAverageInpainter> createColorAverageInpainter(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of ConsistentMosaicInpainter using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created ConsistentMosaicInpainter
 */
cv::Ptr<cv::videostab::ConsistentMosaicInpainter> createConsistentMosaicInpainter(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of MotionInpainter using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created MotionInpainter
 */
cv::Ptr<cv::videostab::MotionInpainter> createMotionInpainter(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of InpaintingPipeline using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created InpaintingPipeline
 */
cv::Ptr<cv::videostab::InpaintingPipeline> createInpaintingPipeline(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of InpainterBase using options in arguments
 * @param type inpainter type, one of:
 *    - "NullInpainter"
 *    - "InpaintingPipeline"
 *    - "ConsistentMosaicInpainter"
 *    - "MotionInpainter" (requires CUDA)
 *    - "ColorAverageInpainter"
 *    - "ColorInpainter"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created InpainterBase
 */
cv::Ptr<cv::videostab::InpainterBase> createInpainterBase(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of GaussianMotionFilter using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created GaussianMotionFilter
 */
cv::Ptr<cv::videostab::GaussianMotionFilter> createGaussianMotionFilter(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of MotionFilterBase using options in arguments
 * @param type motion filter type, one of:
 *    - "GaussianMotionFilter"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created MotionFilterBase
 */
cv::Ptr<cv::videostab::MotionFilterBase> createMotionFilterBase(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of LpMotionStabilizer using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created LpMotionStabilizer
 */
cv::Ptr<cv::videostab::LpMotionStabilizer> createLpMotionStabilizer(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of MotionStabilizationPipeline using options in
 *  arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created MotionStabilizationPipeline
 */
cv::Ptr<cv::videostab::MotionStabilizationPipeline> createMotionStabilizationPipeline(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of IMotionStabilizer using options in arguments
 * @param type motion stabilizer type, one of:
 *    - "MotionStabilizationPipeline"
 *    - "GaussianMotionFilter"
 *    - "LpMotionStabilizer" (requires CLP library)
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created IMotionStabilizer
 */
cv::Ptr<cv::videostab::IMotionStabilizer> createIMotionStabilizer(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of MoreAccurateMotionWobbleSuppressor using options in
 *  arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created MoreAccurateMotionWobbleSuppressor
 */
cv::Ptr<cv::videostab::MoreAccurateMotionWobbleSuppressor> createMoreAccurateMotionWobbleSuppressor(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of WobbleSuppressorBase using options in arguments
 * @param type wobble suppressor type, one of:
 *    - "NullWobbleSuppressor"
 *    - "MoreAccurateMotionWobbleSuppressor"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created WobbleSuppressorBase
 */
cv::Ptr<cv::videostab::WobbleSuppressorBase> createWobbleSuppressorBase(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

#endif
