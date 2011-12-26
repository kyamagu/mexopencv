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
#include <map>
#include <string>

// Conversion to cv::Mat
mxArray* cvmxArrayFromMat(const cv::Mat& mat, mxClassID classid=mxUNKNOWN_CLASS);
cv::Mat cvmxArrayToMat(const mxArray *arr, int depth=CV_USRTYPE1);

// Conversion to std::string
namespace cv {
	// Specialized smart pointer for char array generated from mxArray
	template<> inline void Ptr<char>::delete_obj() { mxFree(obj); }
}
std::string inline cvmxArrayToString(const mxArray* arr) {
	return std::string(cv::Ptr<char>(mxArrayToString(arr)));
};

// String to enum mapper
struct BorderType {
	static std::map<std::string, int> const m;
};

#endif