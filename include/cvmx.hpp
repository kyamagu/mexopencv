/**
 * @file cvmx.hpp
 * @brief data converter for mxArray and cv::Mat
 * @author Kota Yamaguchi
 * @date 2011
 * @details
 * Usage:
 * @code
 * Mat m(cvmxArrayToMat(arr));
 * mxArray* a = cvmxArrayFromMat(m);
 * @endcode
 */
#ifndef __CVMX_HPP__
#define __CVMX_HPP__

#include "mex.h"
#include "cv.h"

mxArray* cvmxArrayFromMat(const cv::Mat& mat, mxClassID classid=mxUNKNOWN_CLASS);
cv::Mat cvmxArrayToMat(const mxArray *arr, int depth=CV_USRTYPE1);

#endif