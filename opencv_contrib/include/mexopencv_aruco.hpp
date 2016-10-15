/**
 * @file mexopencv_aruco.hpp
 * @brief Common definitions for the aruco module
 * @ingroup aruco
 * @author Amro
 * @date 2016
 *
 * Header file for MEX-functions that use aruco module from OpenCV library.
 * This file includes maps for option processing, as well as functions for
 * creating instances of classes from parsed arguments.
 */
#ifndef MEXOPENCV_ARUCO_HPP
#define MEXOPENCV_ARUCO_HPP

#include "mexopencv.hpp"
#include "opencv2/aruco.hpp"
#include "opencv2/aruco/charuco.hpp"


// ==================== XXX ====================

/// Predefined dictionary types
const ConstMap<std::string, cv::aruco::PREDEFINED_DICTIONARY_NAME> PredefinedDictionaryMap =
    ConstMap<std::string, cv::aruco::PREDEFINED_DICTIONARY_NAME>
    ("4x4_50",        cv::aruco::DICT_4X4_50)
    ("4x4_100",       cv::aruco::DICT_4X4_100)
    ("4x4_250",       cv::aruco::DICT_4X4_250)
    ("4x4_1000",      cv::aruco::DICT_4X4_1000)
    ("5x5_50",        cv::aruco::DICT_5X5_50)
    ("5x5_100",       cv::aruco::DICT_5X5_100)
    ("5x5_250",       cv::aruco::DICT_5X5_250)
    ("5x5_1000",      cv::aruco::DICT_5X5_1000)
    ("6x6_50",        cv::aruco::DICT_6X6_50)
    ("6x6_100",       cv::aruco::DICT_6X6_100)
    ("6x6_250",       cv::aruco::DICT_6X6_250)
    ("6x6_1000",      cv::aruco::DICT_6X6_1000)
    ("7x7_50",        cv::aruco::DICT_7X7_50)
    ("7x7_100",       cv::aruco::DICT_7X7_100)
    ("7x7_250",       cv::aruco::DICT_7X7_250)
    ("7x7_1000",      cv::aruco::DICT_7X7_1000)
    ("ArucoOriginal", cv::aruco::DICT_ARUCO_ORIGINAL);


// ==================== XXX ====================

/** Convert MxArray to cv::aruco::DetectorParameters
 * @param s scalar struct MxArray object
 * @return detector parameters object
 */
cv::aruco::DetectorParameters MxArrayToDetectorParameters(const MxArray &s);

/** Convert MxArray to cv::aruco::Dictionary
 * @param arr MxArray object. In one of the following forms:
 * - a string, one of the recognized predefined dictionaries.
 * - a scalar struct with the following fields:
 *   "bytesList", "markerSize", and "maxCorrectionBits".
 * - a cell-array of the form: <tt>{Type, ...}</tt> starting with the
 *   dictionary type ("Predefined", "Custom", or "Manual") followed by
 *   dictionary-specific options.
 * @return instance of created Dictionary object
 */
cv::aruco::Dictionary MxArrayToDictionary(const MxArray &arr);

/** Convert MxArray to cv::aruco::Board
 * @param arr MxArray object. In one of the following forms:
 * - a scalar struct with the following fields:
 *   "objPoints", "dictionary", and "ids".
 * - a cell-array of the form: <tt>{Type, ...}</tt> starting with the
 *    board type ("Board", "GridBoard", or "CharucoBoard") followed by
 *    board-specific options.
 * @return instance of created Board object
 */
cv::aruco::Board MxArrayToBoard(const MxArray &arr);

/** Convert detector parameters to scalar struct
 * @param params instance of detector parameters
 * @return scalar struct MxArray object
 */
MxArray toStruct(const cv::aruco::DetectorParameters &params);

/** Convert Dictionary to scalar struct
 * @param dictionary instance of dictionary
 * @return scalar struct MxArray object
 */
MxArray toStruct(const cv::aruco::Dictionary &dictionary);

/** Convert Board to scalar struct
 * @param board instance of Board
 * @return scalar struct MxArray object
 */
MxArray toStruct(const cv::aruco::Board &board);

/** Convert GridBoard to scalar struct
 * @param board instance of GridBoard
 * @return scalar struct MxArray object
 */
MxArray toStruct(const cv::aruco::GridBoard &board);

/** Convert CharucoBoard to scalar struct
 * @param board instance of CharucoBoard
 * @return scalar struct MxArray object
 */
MxArray toStruct(const cv::aruco::CharucoBoard &board);


// ==================== XXX ====================

/** Create an instance of Board using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return instance of created Board
 */
cv::aruco::Board create_Board(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of GridBoard using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return instance of created GridBoard
 */
cv::aruco::GridBoard create_GridBoard(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

/** Create an instance of CharucoBoard using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return instance of created CharucoBoard
 */
cv::aruco::CharucoBoard create_CharucoBoard(
    std::vector<MxArray>::const_iterator first,
    std::vector<MxArray>::const_iterator last);

#endif
