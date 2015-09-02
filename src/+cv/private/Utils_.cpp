/**
 * @file Utils_.cpp
 * @brief mex interface for some utilities and system functions
 * @ingroup core
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk((nrhs==1 || nrhs==2) && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    string method(rhs[0].toString());

    // Operation switch
    if (method == "checkHardwareSupport") {
        nargchk(nrhs==1 && nlhs<=1);
        MxArray s = MxArray::Struct();
        s.set("MMX",            checkHardwareSupport(cv::CPU_MMX));
        s.set("SSE",            checkHardwareSupport(cv::CPU_SSE));
        s.set("SSE2",           checkHardwareSupport(cv::CPU_SSE2));
        s.set("SSE3",           checkHardwareSupport(cv::CPU_SSE3));
        s.set("SSSE3",          checkHardwareSupport(cv::CPU_SSSE3));
        s.set("SSE4_1",         checkHardwareSupport(cv::CPU_SSE4_1));
        s.set("SSE4_2",         checkHardwareSupport(cv::CPU_SSE4_2));
        s.set("POPCNT",         checkHardwareSupport(cv::CPU_POPCNT));
        s.set("AVX",            checkHardwareSupport(cv::CPU_AVX));
        s.set("AVX2",           checkHardwareSupport(cv::CPU_AVX2));
        s.set("FMA3",           checkHardwareSupport(cv::CPU_FMA3));
        s.set("AVX_512F",       checkHardwareSupport(cv::CPU_AVX_512F));
        s.set("AVX_512BW",      checkHardwareSupport(cv::CPU_AVX_512BW));
        s.set("AVX_512CD",      checkHardwareSupport(cv::CPU_AVX_512CD));
        s.set("AVX_512DQ",      checkHardwareSupport(cv::CPU_AVX_512DQ));
        s.set("AVX_512ER",      checkHardwareSupport(cv::CPU_AVX_512ER));
        s.set("AVX_512IFMA512", checkHardwareSupport(cv::CPU_AVX_512IFMA512));
        s.set("AVX_512PF",      checkHardwareSupport(cv::CPU_AVX_512PF));
        s.set("AVX_512VBMI",    checkHardwareSupport(cv::CPU_AVX_512VBMI));
        s.set("AVX_512VL",      checkHardwareSupport(cv::CPU_AVX_512VL));
        s.set("NEON",           checkHardwareSupport(cv::CPU_NEON));
        plhs[0] = s;
    }
    else if (method == "getBuildInformation") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(getBuildInformation());
    }
    else if (method == "getNumberOfCPUs") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(getNumberOfCPUs());
    }
    else if (method == "getNumThreads") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(getNumThreads());
    }
    else if (method == "setNumThreads") {
        nargchk(nrhs==2 && nlhs==0);
        setNumThreads(rhs[1].toInt());
    }
    else if (method == "useOptimized") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(useOptimized());
    }
    else if (method == "setUseOptimized") {
        nargchk(nrhs==2 && nlhs==0);
        setUseOptimized(rhs[1].toBool());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
