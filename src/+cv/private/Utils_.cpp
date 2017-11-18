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

// HAVE_IPP, HAVE_OPENVX, HAVE_OPENCL, HAVE_CUDA, HAVE_TEGRA_OPTIMIZATION
#include "opencv2/cvconfig.h"
#include "opencv2/core/ocl.hpp"
#include "opencv2/core/cuda.hpp"

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
        const char *fields[23] = {"MMX", "SSE", "SSE2", "SSE3", "SSSE3",
            "SSE4_1", "SSE4_2", "POPCNT", "FP16", "AVX", "AVX2", "FMA3",
            "AVX_512F", "AVX_512BW", "AVX_512CD", "AVX_512DQ", "AVX_512ER",
            "AVX_512IFMA512", "AVX_512PF", "AVX_512VBMI", "AVX_512VL", "NEON",
            "VSX"};
        MxArray s = MxArray::Struct(fields, 23);
        s.set(fields[0],  checkHardwareSupport(CV_CPU_MMX));
        s.set(fields[1],  checkHardwareSupport(CV_CPU_SSE));
        s.set(fields[2],  checkHardwareSupport(CV_CPU_SSE2));
        s.set(fields[3],  checkHardwareSupport(CV_CPU_SSE3));
        s.set(fields[4],  checkHardwareSupport(CV_CPU_SSSE3));
        s.set(fields[5],  checkHardwareSupport(CV_CPU_SSE4_1));
        s.set(fields[6],  checkHardwareSupport(CV_CPU_SSE4_2));
        s.set(fields[7],  checkHardwareSupport(CV_CPU_POPCNT));
        s.set(fields[8],  checkHardwareSupport(CV_CPU_FP16));
        s.set(fields[9],  checkHardwareSupport(CV_CPU_AVX));
        s.set(fields[10], checkHardwareSupport(CV_CPU_AVX2));
        s.set(fields[11], checkHardwareSupport(CV_CPU_FMA3));
        s.set(fields[12], checkHardwareSupport(CV_CPU_AVX_512F));
        s.set(fields[13], checkHardwareSupport(CV_CPU_AVX_512BW));
        s.set(fields[14], checkHardwareSupport(CV_CPU_AVX_512CD));
        s.set(fields[15], checkHardwareSupport(CV_CPU_AVX_512DQ));
        s.set(fields[16], checkHardwareSupport(CV_CPU_AVX_512ER));
        s.set(fields[17], checkHardwareSupport(CV_CPU_AVX_512IFMA512));
        s.set(fields[18], checkHardwareSupport(CV_CPU_AVX_512PF));
        s.set(fields[19], checkHardwareSupport(CV_CPU_AVX_512VBMI));
        s.set(fields[20], checkHardwareSupport(CV_CPU_AVX_512VL));
        s.set(fields[21], checkHardwareSupport(CV_CPU_NEON));
        s.set(fields[22], checkHardwareSupport(CV_CPU_VSX));
        plhs[0] = s;
    }
    else if (method == "getBuildInformation") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(getBuildInformation());
    }
    else if (method == "version") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(string(CV_VERSION));
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
    else if (method == "getIppVersion") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(ipp::getIppVersion());
    }
    else if (method == "useIPP") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(ipp::useIPP());
    }
    else if (method == "setUseIPP") {
        nargchk(nrhs==2 && nlhs==0);
        ipp::setUseIPP(rhs[1].toBool());
    }
    else if (method == "useIPP_NE") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(ipp::useIPP_NE());
    }
    else if (method == "setUseIPP_NE") {
        nargchk(nrhs==2 && nlhs==0);
        ipp::setUseIPP_NE(rhs[1].toBool());
    }
    else if (method == "haveOpenVX") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(haveOpenVX());
    }
    else if (method == "useOpenVX") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(useOpenVX());
    }
    else if (method == "setUseOpenVX") {
        nargchk(nrhs==2 && nlhs==0);
        setUseOpenVX(rhs[1].toBool());
    }
    else if (method == "haveOpenCL") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(ocl::haveOpenCL());
    }
    else if (method == "haveAmdBlas") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(ocl::haveAmdBlas());
    }
    else if (method == "haveAmdFft") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(ocl::haveAmdFft());
    }
    else if (method == "haveSVM") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(ocl::haveSVM());
    }
    else if (method == "useOpenCL") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(ocl::useOpenCL());
    }
    else if (method == "setUseOpenCL") {
        nargchk(nrhs==2 && nlhs==0);
        ocl::setUseOpenCL(rhs[1].toBool());
    }
    else if (method == "getCudaEnabledDeviceCount") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(cuda::getCudaEnabledDeviceCount());
    }
    else if (method == "getDevice") {
        nargchk(nrhs==1 && nlhs<=1);
        plhs[0] = MxArray(cuda::getDevice());
    }
    else if (method == "setDevice") {
        nargchk(nrhs==2 && nlhs==0);
        cuda::setDevice(rhs[1].toInt());
    }
    else if (method == "resetDevice") {
        nargchk(nrhs==1 && nlhs==0);
        cuda::resetDevice();
    }
    else if (method == "deviceSupports") {
        nargchk(nrhs==1 && nlhs<=1);
        const char *fields[10] = {"Compute10", "Compute11", "Compute12",
            "Compute13", "Compute20", "Compute21", "Compute30", "Compute32",
            "Compute35", "Compute50"};
        MxArray s = MxArray::Struct(fields, 10);
        s.set(fields[0], cuda::deviceSupports(cv::cuda::FEATURE_SET_COMPUTE_10));
        s.set(fields[1], cuda::deviceSupports(cv::cuda::FEATURE_SET_COMPUTE_11));
        s.set(fields[2], cuda::deviceSupports(cv::cuda::FEATURE_SET_COMPUTE_12));
        s.set(fields[3], cuda::deviceSupports(cv::cuda::FEATURE_SET_COMPUTE_13));
        s.set(fields[4], cuda::deviceSupports(cv::cuda::FEATURE_SET_COMPUTE_20));
        s.set(fields[5], cuda::deviceSupports(cv::cuda::FEATURE_SET_COMPUTE_21));
        s.set(fields[6], cuda::deviceSupports(cv::cuda::FEATURE_SET_COMPUTE_30));
        s.set(fields[7], cuda::deviceSupports(cv::cuda::FEATURE_SET_COMPUTE_32));
        s.set(fields[8], cuda::deviceSupports(cv::cuda::FEATURE_SET_COMPUTE_35));
        s.set(fields[9], cuda::deviceSupports(cv::cuda::FEATURE_SET_COMPUTE_50));
        plhs[0] = s;
    }
    else if (method == "printCudaDeviceInfo") {
        nargchk(nrhs==2 && nlhs==0);
        cuda::printCudaDeviceInfo(rhs[1].toInt());
    }
    else if (method == "printShortCudaDeviceInfo") {
        nargchk(nrhs==2 && nlhs==0);
        cuda::printShortCudaDeviceInfo(rhs[1].toInt());
    }
    else if (method == "useTegra") {
        nargchk(nrhs==1 && nlhs<=1);
#ifdef HAVE_TEGRA_OPTIMIZATION
        plhs[0] = MxArray(tegra::useTegra());
#else
        plhs[0] = MxArray(false);
#endif
    }
    else if (method == "setUseTegra") {
        nargchk(nrhs==2 && nlhs==0);
#ifdef HAVE_TEGRA_OPTIMIZATION
        tegra::setUseTegra(rhs[1].toBool());
#endif
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
