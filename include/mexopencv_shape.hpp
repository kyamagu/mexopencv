/**
 * @file mexopencv_shape.hpp
 * @brief Common definitions for the shape module
 * @ingroup shape
 * @author Amro
 * @date 2015
 *
 * Header file for MEX-functions that use shape module from OpenCV library.
 * This file includes maps for option processing, as well as functions for
 * creating instances of classes from parsed arguments.
 */
#ifndef MEXOPENCV_SHAPE_HPP
#define MEXOPENCV_SHAPE_HPP

#include "mexopencv.hpp"
#include "opencv2/shape.hpp"


// ==================== XXX ====================

/** Convert a HistogramCostExtractor to MxArray
 * @param p smart poitner to an instance of HistogramCostExtractor
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::HistogramCostExtractor> p);

/** Convert a ShapeTransformer to MxArray
 * @param p smart poitner to an instance of ShapeTransformer
 * @return output MxArray structure
 */
MxArray toStruct(cv::Ptr<cv::ShapeTransformer> p);


// ==================== XXX ====================

/** Create an instance of NormHistogramCostExtractor using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created HistogramCostExtractor
 */
cv::Ptr<cv::HistogramCostExtractor> create_NormHistogramCostExtractor(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of EMDHistogramCostExtractor using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created HistogramCostExtractor
 */
cv::Ptr<cv::HistogramCostExtractor> create_EMDHistogramCostExtractor(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of ChiHistogramCostExtractor using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created HistogramCostExtractor
 */
cv::Ptr<cv::HistogramCostExtractor> create_ChiHistogramCostExtractor(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of EMDL1HistogramCostExtractor using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created HistogramCostExtractor
 */
cv::Ptr<cv::HistogramCostExtractor> create_EMDL1HistogramCostExtractor(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of HistogramCostExtractor using options in arguments
 * @param type histogram cost extractor type, one of:
 *    - "NormHistogramCostExtractor"
 *    - "EMDHistogramCostExtractor"
 *    - "ChiHistogramCostExtractor"
 *    - "EMDL1HistogramCostExtractor"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created HistogramCostExtractor
 */
cv::Ptr<cv::HistogramCostExtractor> create_HistogramCostExtractor(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of AffineTransformer using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created AffineTransformer
 */
cv::Ptr<cv::AffineTransformer> create_AffineTransformer(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of ThinPlateSplineShapeTransformer using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created ThinPlateSplineShapeTransformer
 */
cv::Ptr<cv::ThinPlateSplineShapeTransformer> create_ThinPlateSplineShapeTransformer(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of ShapeTransformer using options in arguments
 * @param type shape transformer type, one of:
 *    - "AffineTransformer"
 *    - "ThinPlateSplineShapeTransformer"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created ShapeTransformer
 */
cv::Ptr<cv::ShapeTransformer> create_ShapeTransformer(
    const std::string& type,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of ShapeContextDistanceExtractor using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created ShapeContextDistanceExtractor
 */
cv::Ptr<cv::ShapeContextDistanceExtractor> create_ShapeContextDistanceExtractor(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of HausdorffDistanceExtractor using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created HausdorffDistanceExtractor
 */
cv::Ptr<cv::HausdorffDistanceExtractor> create_HausdorffDistanceExtractor(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

#endif
