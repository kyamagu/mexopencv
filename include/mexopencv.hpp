/**
 * @file mexopencv.hpp
 * @brief Global constant definitions
 * @author Kota Yamaguchi
 * @date 2012
 *
 * The header file for a Matlab mex function that uses OpenCV library.
 * The file includes definition of MxArray class that converts between mxArray
 * and a couple of std:: and cv:: data types including cv::Mat.
 */
#ifndef __MEXOPENCV_HPP__
#define __MEXOPENCV_HPP__

#include "MxArray.hpp"

// Global constants

/** BorderType map for option processing
 */
const ConstMap<std::string,int> BorderType = ConstMap<std::string,int>
    ("Replicate",   cv::BORDER_REPLICATE)
    ("Constant",    cv::BORDER_CONSTANT)
    ("Reflect",     cv::BORDER_REFLECT)
    ("Wrap",        cv::BORDER_WRAP)
    ("Reflect101",  cv::BORDER_REFLECT_101)
    ("Transparent", cv::BORDER_TRANSPARENT)
    ("Default",     cv::BORDER_DEFAULT)
    ("Isolated",    cv::BORDER_ISOLATED);

/** Interpolation type map for option processing
 */
const ConstMap<std::string,int> InterType = ConstMap<std::string,int>
    ("Nearest",  cv::INTER_NEAREST)  //!< nearest neighbor interpolation
    ("Linear",   cv::INTER_LINEAR)   //!< bilinear interpolation
    ("Cubic",    cv::INTER_CUBIC)    //!< bicubic interpolation
    ("Area",     cv::INTER_AREA)     //!< area-based (or super) interpolation
    ("Lanczos4", cv::INTER_LANCZOS4) //!< Lanczos interpolation over 8x8 neighborhood
    ("Max",      cv::INTER_MAX);
    //("WarpInverseMap",    cv::WARP_INVERSE_MAP);

/** Thresholding type map for option processing
 */
const ConstMap<std::string,int> ThreshType = ConstMap<std::string,int>
    ("Binary",    cv::THRESH_BINARY)
    ("BinaryInv", cv::THRESH_BINARY_INV)
    ("Trunc",     cv::THRESH_TRUNC)
    ("ToZero",    cv::THRESH_TOZERO)
    ("ToZeroInv", cv::THRESH_TOZERO_INV)
    ("Mask",      cv::THRESH_MASK);
    //("Otsu",    cv::THRESH_OTSU);

/** Distance types for Distance Transform and M-estimators
 */
const ConstMap<std::string,int> DistType = ConstMap<std::string,int>
    ("User",   CV_DIST_USER)
    ("L1",     CV_DIST_L1)
    ("L2",     CV_DIST_L2)
    ("C",      CV_DIST_C)
    ("L12",    CV_DIST_L12)
    ("Fair",   CV_DIST_FAIR)
    ("Welsch", CV_DIST_WELSCH)
    ("Huber",  CV_DIST_HUBER);

/** Line type for drawing
 */
const ConstMap<std::string,int> LineType = ConstMap<std::string,int>
    ("8",  8)
    ("4",  4)
    ("AA", CV_AA);

/** Font faces for drawing
 */
const ConstMap<std::string,int> FontFace = ConstMap<std::string,int>
    ("HersheySimplex",       cv::FONT_HERSHEY_SIMPLEX)
    ("HersheyPlain",         cv::FONT_HERSHEY_PLAIN)
    ("HersheyDuplex",        cv::FONT_HERSHEY_DUPLEX)
    ("HersheyComplex",       cv::FONT_HERSHEY_COMPLEX)
    ("HersheyTriplex",       cv::FONT_HERSHEY_TRIPLEX)
    ("HersheyComplexSmall",  cv::FONT_HERSHEY_COMPLEX_SMALL)
    ("HersheyScriptSimplex", cv::FONT_HERSHEY_SCRIPT_SIMPLEX)
    ("HersheyScriptComplex", cv::FONT_HERSHEY_SCRIPT_COMPLEX);

/** Font styles for drawing
 */
const ConstMap<std::string,int> FontStyle = ConstMap<std::string,int>
    ("Regular", 0)
    ("Italic",  cv::FONT_ITALIC);
#endif
