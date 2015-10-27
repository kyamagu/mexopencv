/**
 * @file mexopencv_ml.hpp
 * @brief Common definitions for the ml module
 * @author Amro
 * @date 2015
 *
 * Header file for MEX-functions that use ML module from OpenCV library.
 * This file includes maps for option processing, as well as functions for
 * creating instances of classes from parsed arguments.
*/
#ifndef __MEXOPENCV_ML_HPP__
#define __MEXOPENCV_ML_HPP__

#include "mexopencv.hpp"
#include "opencv2/ml.hpp"


// ==================== XXX ====================

/** Convert tree nodes to struct array
 * @param nodes vector of decision tree nodes
 * @return struct-array MxArray object
 */
MxArray toStruct(const std::vector<cv::ml::DTrees::Node>& nodes);

/** Convert tree splits to struct array
 * @param splits vector of decision tree splits
 * @return struct-array MxArray object
 */
MxArray toStruct(const std::vector<cv::ml::DTrees::Split>& splits);


// ==================== XXX ====================

/** Create an instance of TrainData using options in arguments
 * @param samples data samples
 * @param responses data responses
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created cv::ml::TrainData
 */
cv::Ptr<cv::ml::TrainData> createTrainData(
    const cv::Mat& samples, const cv::Mat& responses,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Read a dataset from a CSV file
 * @param filename The input CSV file name
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created cv::ml::TrainData
 */
cv::Ptr<cv::ml::TrainData> loadTrainData(
    const std::string& filename,
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

#endif
