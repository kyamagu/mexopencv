/**
 * @file cvmx.hpp
 * @brief data converter and utilities for mxArray and cv::Mat
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

/** BorderType helper for option processing
 *
 */
struct BorderType {
	static int get(const mxArray *arr);
	static std::map<std::string, int> const m;
	static std::map<std::string, int> create_border_type() {
		std::map<std::string, int> m;
		m["Replicate"]		= cv::BORDER_REPLICATE;
		m["Constant"]   	= cv::BORDER_CONSTANT;
		m["Reflect"] 		= cv::BORDER_REFLECT;
		m["Wrap"]			= cv::BORDER_WRAP;
		m["Reflect101"] 	= cv::BORDER_REFLECT_101;
		m["Transparent"]	= cv::BORDER_TRANSPARENT;
		m["Default"] 		= cv::BORDER_DEFAULT;
		m["Isolated"]		= cv::BORDER_ISOLATED;
		return m;
	}
};

#endif