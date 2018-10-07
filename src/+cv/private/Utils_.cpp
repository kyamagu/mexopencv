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

namespace {
/** Convert size type to MxArray.
 * @param i value.
 * @return MxArray object, a scalar uint64 array.
 */
MxArray toMxArray(size_t i)
{
    MxArray arr(mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL));
    if (arr.isNull())
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    arr.set(0, static_cast<uint64_t>(i));
    return arr;
}

/** Convert vector of size type to MxArray.
 * @param v vector.
 * @return MxArray object, a vector uint64 array.
 */
MxArray toMxArray(const std::vector<size_t> &v)
{
    MxArray arr(mxCreateNumericMatrix(1, v.size(), mxUINT64_CLASS, mxREAL));
    if (arr.isNull())
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    for (size_t i = 0; i < v.size(); ++i)
        arr.set(i, static_cast<uint64_t>(v[i]));
    return arr;
}

/// OpenCL device type
const ConstMap<int,string> OCLTypeMap = ConstMap<int,string>
    (cv::ocl::Device::TYPE_DEFAULT,     "Default")
    (cv::ocl::Device::TYPE_CPU,         "CPU")
    (cv::ocl::Device::TYPE_GPU,         "GPU")
    (cv::ocl::Device::TYPE_ACCELERATOR, "Accelerator")
    (cv::ocl::Device::TYPE_DGPU,        "DGPU")
    (cv::ocl::Device::TYPE_IGPU,        "IGPU");

/// OpenCL type of global memory cache
const ConstMap<int,string> OCLCacheMap = ConstMap<int,string>
    (cv::ocl::Device::NO_CACHE,         "NoCache")
    (cv::ocl::Device::READ_ONLY_CACHE,  "ReadOnlyCache")
    (cv::ocl::Device::READ_WRITE_CACHE, "ReadWriteCache");

/// OpenCL type of local memory
const ConstMap<int,string> OCLMemMap = ConstMap<int,string>
    (cv::ocl::Device::NO_LOCAL_MEM,    "NoLocalMem")
    (cv::ocl::Device::LOCAL_IS_LOCAL,  "LocalIsLocal")
    (cv::ocl::Device::LOCAL_IS_GLOBAL, "LocalIsGlobal");

/// OpenCL vendor name
const ConstMap<int,string> OCLVendorMap = ConstMap<int,string>
    (cv::ocl::Device::UNKNOWN_VENDOR, "Unknown")
    (cv::ocl::Device::VENDOR_AMD,     "AMD")
    (cv::ocl::Device::VENDOR_INTEL,   "Intel")
    (cv::ocl::Device::VENDOR_NVIDIA,  "Nvidia");

/// CUDA device compute modes
const ConstMap<int,string> CUDAComputeModeMap = ConstMap<int,string>
    (cv::cuda::DeviceInfo::ComputeModeDefault,          "Default")
    (cv::cuda::DeviceInfo::ComputeModeExclusive,        "Exclusive")
    (cv::cuda::DeviceInfo::ComputeModeProhibited,       "Prohibited")
    (cv::cuda::DeviceInfo::ComputeModeExclusiveProcess, "ExclusiveProcess");

/** Convert OpenCL FP config bit-field to MxArray.
 * @param flags int value.
 * @return MxArray object, a scalar struct.
 */
MxArray toFPConfigStruct(int flags)
{
    const char *fields[8] = {"Denorm", "InfNaN", "RoundToNearest",
        "RoundToZero", "RoundToInf", "FMA", "SoftFloat",
        "CorrectlyRoundedDivideSqrt"};
    MxArray s = MxArray::Struct(fields, 8);
    s.set(fields[0], (flags & cv::ocl::Device::FP_DENORM) != 0);
    s.set(fields[1], (flags & cv::ocl::Device::FP_INF_NAN) != 0);
    s.set(fields[2], (flags & cv::ocl::Device::FP_ROUND_TO_NEAREST) != 0);
    s.set(fields[3], (flags & cv::ocl::Device::FP_ROUND_TO_ZERO) != 0);
    s.set(fields[4], (flags & cv::ocl::Device::FP_ROUND_TO_INF) != 0);
    s.set(fields[5], (flags & cv::ocl::Device::FP_FMA) != 0);
    s.set(fields[6], (flags & cv::ocl::Device::FP_SOFT_FLOAT) != 0);
    s.set(fields[7], (flags & cv::ocl::Device::FP_CORRECTLY_ROUNDED_DIVIDE_SQRT) != 0);
    return s;
}

/** Convert OpenCL execution capabilities bit-field to MxArray.
 * @param flags int value.
 * @return MxArray object, a scalar struct.
 */
MxArray toExecCapStruct(int flags)
{
    const char *fields[2] = {"Kernel", "NativeKernel"};
    MxArray s = MxArray::Struct(fields, 2);
    s.set(fields[0], (flags & cv::ocl::Device::EXEC_KERNEL) != 0);
    s.set(fields[1], (flags & cv::ocl::Device::EXEC_NATIVE_KERNEL) != 0);
    return s;
}

/** Convert OpenCL platform info vector to struct array
 * @param vpi vector of platform info
 * @return struct-array MxArray object
 */
MxArray toStruct(const vector<cv::ocl::PlatformInfo> &vpi)
{
    const char *fieldsP[4] = {"name", "vendor", "version", "device"};
    const char *fieldsD[68] = {"name", "extensions", "version", "vendorName",
        "OpenCL_C_Version", "OpenCLVersion", "deviceVersionMajor",
        "deviceVersionMinor", "driverVersion", "type", "addressBits",
        "available", "compilerAvailable", "linkerAvailable", "doubleFPConfig",
        "singleFPConfig", "halfFPConfig", "endianLittle",
        "errorCorrectionSupport", "executionCapabilities",
        "globalMemCacheSize", "globalMemCacheType", "globalMemCacheLineSize",
        "globalMemSize", "localMemSize", "localMemType", "hostUnifiedMemory",
        "imageSupport", "imageFromBufferSupport", "imagePitchAlignment",
        "imageBaseAddressAlignment", "image2DMaxWidth", "image2DMaxHeight",
        "image3DMaxWidth", "image3DMaxHeight", "image3DMaxDepth",
        "imageMaxBufferSize", "imageMaxArraySize", "vendorID",
        "maxClockFrequency", "maxComputeUnits", "maxConstantArgs",
        "maxConstantBufferSize", "maxMemAllocSize", "maxParameterSize",
        "maxReadImageArgs", "maxWriteImageArgs", "maxSamplers",
        "maxWorkGroupSize", "maxWorkItemDims", "maxWorkItemSizes",
        "memBaseAddrAlign", "nativeVectorWidthChar", "nativeVectorWidthShort",
        "nativeVectorWidthInt", "nativeVectorWidthLong",
        "nativeVectorWidthFloat", "nativeVectorWidthDouble",
        "nativeVectorWidthHalf", "preferredVectorWidthChar",
        "preferredVectorWidthShort", "preferredVectorWidthInt",
        "preferredVectorWidthLong", "preferredVectorWidthFloat",
        "preferredVectorWidthDouble", "preferredVectorWidthHalf",
        "printfBufferSize", "profilingTimerResolution"};
    MxArray sp = MxArray::Struct(fieldsP, 4, 1, vpi.size());
    for (size_t i = 0; i < vpi.size(); ++i) {
        const cv::ocl::PlatformInfo &pi = vpi[i];
        MxArray sd = MxArray::Struct(fieldsD, 68, 1, pi.deviceNumber());
        for (int j = 0; j < pi.deviceNumber(); ++j) {
            cv::ocl::Device di;
            pi.getDevice(di, j);
            sd.set(fieldsD[0],  di.name(), j);
            sd.set(fieldsD[1],  di.extensions(), j);
            sd.set(fieldsD[2],  di.version(), j);
            sd.set(fieldsD[3],  di.vendorName(), j);
            sd.set(fieldsD[4],  di.OpenCL_C_Version(), j);
            sd.set(fieldsD[5],  di.OpenCLVersion(), j);
            sd.set(fieldsD[6],  di.deviceVersionMajor(), j);
            sd.set(fieldsD[7],  di.deviceVersionMinor(), j);
            sd.set(fieldsD[8],  di.driverVersion(), j);
            sd.set(fieldsD[9],  OCLTypeMap[di.type()], j);
            sd.set(fieldsD[10], di.addressBits(), j);
            sd.set(fieldsD[11], di.available(), j);
            sd.set(fieldsD[12], di.compilerAvailable(), j);
            sd.set(fieldsD[13], di.linkerAvailable(), j);
            sd.set(fieldsD[14], toFPConfigStruct(di.doubleFPConfig()), j);
            sd.set(fieldsD[15], toFPConfigStruct(di.singleFPConfig()), j);
            sd.set(fieldsD[16], toFPConfigStruct(di.halfFPConfig()), j);
            sd.set(fieldsD[17], di.endianLittle(), j);
            sd.set(fieldsD[18], di.errorCorrectionSupport(), j);
            sd.set(fieldsD[19], toExecCapStruct(di.executionCapabilities()), j);
            sd.set(fieldsD[20], toMxArray(di.globalMemCacheSize()), j);
            sd.set(fieldsD[21], OCLCacheMap[di.globalMemCacheType()], j);
            sd.set(fieldsD[22], di.globalMemCacheLineSize(), j);
            sd.set(fieldsD[23], toMxArray(di.globalMemSize()), j);
            sd.set(fieldsD[24], toMxArray(di.localMemSize()), j);
            sd.set(fieldsD[25], OCLMemMap[di.localMemType()], j);
            sd.set(fieldsD[26], di.hostUnifiedMemory(), j);
            sd.set(fieldsD[27], di.imageSupport(), j);
            sd.set(fieldsD[28], di.imageFromBufferSupport(), j);
            sd.set(fieldsD[29], static_cast<int>(di.imagePitchAlignment()), j);
            sd.set(fieldsD[30], static_cast<int>(di.imageBaseAddressAlignment()), j);
            sd.set(fieldsD[31], toMxArray(di.image2DMaxWidth()), j);
            sd.set(fieldsD[32], toMxArray(di.image2DMaxHeight()), j);
            sd.set(fieldsD[33], toMxArray(di.image3DMaxWidth()), j);
            sd.set(fieldsD[34], toMxArray(di.image3DMaxHeight()), j);
            sd.set(fieldsD[35], toMxArray(di.image3DMaxDepth()), j);
            sd.set(fieldsD[36], toMxArray(di.imageMaxBufferSize()), j);
            sd.set(fieldsD[37], toMxArray(di.imageMaxArraySize()), j);
            sd.set(fieldsD[38], OCLVendorMap[di.vendorID()], j);
            sd.set(fieldsD[39], di.maxClockFrequency(), j);
            sd.set(fieldsD[40], di.maxComputeUnits(), j);
            sd.set(fieldsD[41], di.maxConstantArgs(), j);
            sd.set(fieldsD[42], toMxArray(di.maxConstantBufferSize()), j);
            sd.set(fieldsD[43], toMxArray(di.maxMemAllocSize()), j);
            sd.set(fieldsD[44], toMxArray(di.maxParameterSize()), j);
            sd.set(fieldsD[45], di.maxReadImageArgs(), j);
            sd.set(fieldsD[46], di.maxWriteImageArgs(), j);
            sd.set(fieldsD[47], di.maxSamplers(), j);
            sd.set(fieldsD[48], toMxArray(di.maxWorkGroupSize()), j);
            sd.set(fieldsD[49], di.maxWorkItemDims(), j);
            {
                vector<size_t> mwis(32);  // MAX_DIMS
                di.maxWorkItemSizes(&mwis[0]);
                mwis.resize(di.maxWorkItemDims());
                sd.set(fieldsD[50], toMxArray(mwis), j);
            }
            sd.set(fieldsD[51], di.memBaseAddrAlign(), j);
            sd.set(fieldsD[52], di.nativeVectorWidthChar(), j);
            sd.set(fieldsD[53], di.nativeVectorWidthShort(), j);
            sd.set(fieldsD[54], di.nativeVectorWidthInt(), j);
            sd.set(fieldsD[55], di.nativeVectorWidthLong(), j);
            sd.set(fieldsD[56], di.nativeVectorWidthFloat(), j);
            sd.set(fieldsD[57], di.nativeVectorWidthDouble(), j);
            sd.set(fieldsD[58], di.nativeVectorWidthHalf(), j);
            sd.set(fieldsD[59], di.preferredVectorWidthChar(), j);
            sd.set(fieldsD[60], di.preferredVectorWidthShort(), j);
            sd.set(fieldsD[61], di.preferredVectorWidthInt(), j);
            sd.set(fieldsD[62], di.preferredVectorWidthLong(), j);
            sd.set(fieldsD[63], di.preferredVectorWidthFloat(), j);
            sd.set(fieldsD[64], di.preferredVectorWidthDouble(), j);
            sd.set(fieldsD[65], di.preferredVectorWidthHalf(), j);
            sd.set(fieldsD[66], toMxArray(di.printfBufferSize()), j);
            sd.set(fieldsD[67], toMxArray(di.profilingTimerResolution()), j);
        }
        sp.set(fieldsP[0], pi.name(), i);
        sp.set(fieldsP[1], pi.vendor(), i);
        sp.set(fieldsP[2], pi.version(), i);
        sp.set(fieldsP[3], sd, i);
    }
    return sp;
}

/** Convert CUDA device info to struct array
 * @param di device info object
 * @return scalar struct MxArray object
 */
MxArray toStruct(const cv::cuda::DeviceInfo &di)
{
    const char *fields[57] = {"deviceID", "name", "totalGlobalMem",
        "sharedMemPerBlock", "regsPerBlock", "warpSize", "memPitch",
        "maxThreadsPerBlock", "maxThreadsDim", "maxGridSize", "clockRate",
        "totalConstMem", "majorVersion", "minorVersion", "textureAlignment",
        "texturePitchAlignment", "multiProcessorCount",
        "kernelExecTimeoutEnabled", "integrated", "canMapHostMemory",
        "computeMode", "maxTexture1D", "maxTexture1DMipmap",
        "maxTexture1DLinear", "maxTexture2D", "maxTexture2DMipmap",
        "maxTexture2DLinear", "maxTexture2DGather", "maxTexture3D",
        "maxTextureCubemap", "maxTexture1DLayered", "maxTexture2DLayered",
        "maxTextureCubemapLayered", "maxSurface1D", "maxSurface2D",
        "maxSurface3D", "maxSurface1DLayered", "maxSurface2DLayered",
        "maxSurfaceCubemap", "maxSurfaceCubemapLayered", "surfaceAlignment",
        "concurrentKernels", "ECCEnabled", "pciBusID", "pciDeviceID",
        "pciDomainID", "tccDriver", "asyncEngineCount", "unifiedAddressing",
        "memoryClockRate", "memoryBusWidth", "l2CacheSize",
        "maxThreadsPerMultiProcessor", "freeMemory", "totalMemory",
        "supports", "isCompatible"};
    MxArray s = MxArray::Struct(fields, 57);
    s.set(fields[0],  di.deviceID());
    s.set(fields[1],  di.name());
    s.set(fields[2],  toMxArray(di.totalGlobalMem()));
    s.set(fields[3],  toMxArray(di.sharedMemPerBlock()));
    s.set(fields[4],  di.regsPerBlock());
    s.set(fields[5],  di.warpSize());
    s.set(fields[6],  toMxArray(di.memPitch()));
    s.set(fields[7],  di.maxThreadsPerBlock());
    s.set(fields[8],  di.maxThreadsDim());
    s.set(fields[9],  di.maxGridSize());
    s.set(fields[10], di.clockRate());
    s.set(fields[11], toMxArray(di.totalConstMem()));
    s.set(fields[12], di.majorVersion());
    s.set(fields[13], di.minorVersion());
    s.set(fields[14], toMxArray(di.textureAlignment()));
    s.set(fields[15], toMxArray(di.texturePitchAlignment()));
    s.set(fields[16], di.multiProcessorCount());
    s.set(fields[17], di.kernelExecTimeoutEnabled());
    s.set(fields[18], di.integrated());
    s.set(fields[19], di.canMapHostMemory());
    s.set(fields[20], CUDAComputeModeMap[di.computeMode()]);
    s.set(fields[21], di.maxTexture1D());
    s.set(fields[22], di.maxTexture1DMipmap());
    s.set(fields[23], di.maxTexture1DLinear());
    s.set(fields[24], di.maxTexture2D());
    s.set(fields[25], di.maxTexture2DMipmap());
    s.set(fields[26], di.maxTexture2DLinear());
    s.set(fields[27], di.maxTexture2DGather());
    s.set(fields[28], di.maxTexture3D());
    s.set(fields[29], di.maxTextureCubemap());
    s.set(fields[30], di.maxTexture1DLayered());
    s.set(fields[31], di.maxTexture2DLayered());
    s.set(fields[32], di.maxTextureCubemapLayered());
    s.set(fields[33], di.maxSurface1D());
    s.set(fields[34], di.maxSurface2D());
    s.set(fields[35], di.maxSurface3D());
    s.set(fields[36], di.maxSurface1DLayered());
    s.set(fields[37], di.maxSurface2DLayered());
    s.set(fields[38], di.maxSurfaceCubemap());
    s.set(fields[39], di.maxSurfaceCubemapLayered());
    s.set(fields[40], toMxArray(di.surfaceAlignment()));
    s.set(fields[41], di.concurrentKernels());
    s.set(fields[42], di.ECCEnabled());
    s.set(fields[43], di.pciBusID());
    s.set(fields[44], di.pciDeviceID());
    s.set(fields[45], di.pciDomainID());
    s.set(fields[46], di.tccDriver());
    s.set(fields[47], di.asyncEngineCount());
    s.set(fields[48], di.unifiedAddressing());
    s.set(fields[49], di.memoryClockRate());
    s.set(fields[50], di.memoryBusWidth());
    s.set(fields[51], di.l2CacheSize());
    s.set(fields[52], di.maxThreadsPerMultiProcessor());
    s.set(fields[53], toMxArray(di.freeMemory()));
    s.set(fields[54], toMxArray(di.totalMemory()));
    {
        const char *fieldsFS[15] = {"Compute10", "Compute11", "Compute12",
            "Compute13", "Compute20", "Compute21", "Compute30", "Compute32",
            "Compute35", "Compute50", "GlobalAtomics", "SharedAtomics",
            "NativeDouble", "WarpShuffleFunctions", "DynamicParallelism"};
        MxArray sf = MxArray::Struct(fieldsFS, 15);
        sf.set(fieldsFS[0],  di.supports(cv::cuda::FEATURE_SET_COMPUTE_10));
        sf.set(fieldsFS[1],  di.supports(cv::cuda::FEATURE_SET_COMPUTE_11));
        sf.set(fieldsFS[2],  di.supports(cv::cuda::FEATURE_SET_COMPUTE_12));
        sf.set(fieldsFS[3],  di.supports(cv::cuda::FEATURE_SET_COMPUTE_13));
        sf.set(fieldsFS[4],  di.supports(cv::cuda::FEATURE_SET_COMPUTE_20));
        sf.set(fieldsFS[5],  di.supports(cv::cuda::FEATURE_SET_COMPUTE_21));
        sf.set(fieldsFS[6],  di.supports(cv::cuda::FEATURE_SET_COMPUTE_30));
        sf.set(fieldsFS[7],  di.supports(cv::cuda::FEATURE_SET_COMPUTE_32));
        sf.set(fieldsFS[8],  di.supports(cv::cuda::FEATURE_SET_COMPUTE_35));
        sf.set(fieldsFS[9],  di.supports(cv::cuda::FEATURE_SET_COMPUTE_50));
        sf.set(fieldsFS[10], di.supports(cv::cuda::GLOBAL_ATOMICS));
        sf.set(fieldsFS[11], di.supports(cv::cuda::SHARED_ATOMICS));
        sf.set(fieldsFS[12], di.supports(cv::cuda::NATIVE_DOUBLE));
        sf.set(fieldsFS[13], di.supports(cv::cuda::WARP_SHUFFLE_FUNCTIONS));
        sf.set(fieldsFS[14], di.supports(cv::cuda::DYNAMIC_PARALLELISM));
        s.set(fields[55], sf);
    }
    s.set(fields[56], di.isCompatible());
    return s;
}
}

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
        const char *fields[24] = {"MMX", "SSE", "SSE2", "SSE3", "SSSE3",
            "SSE4_1", "SSE4_2", "POPCNT", "FP16", "AVX", "AVX2", "FMA3",
            "AVX_512F", "AVX_512BW", "AVX_512CD", "AVX_512DQ", "AVX_512ER",
            "AVX_512IFMA", "AVX_512PF", "AVX_512VBMI", "AVX_512VL", "NEON",
            "VSX", "AVX512_SKX"};
        MxArray s = MxArray::Struct(fields, 24);
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
        s.set(fields[17], checkHardwareSupport(CV_CPU_AVX_512IFMA));
        s.set(fields[18], checkHardwareSupport(CV_CPU_AVX_512PF));
        s.set(fields[19], checkHardwareSupport(CV_CPU_AVX_512VBMI));
        s.set(fields[20], checkHardwareSupport(CV_CPU_AVX_512VL));
        s.set(fields[21], checkHardwareSupport(CV_CPU_NEON));
        s.set(fields[22], checkHardwareSupport(CV_CPU_VSX));
        s.set(fields[23], checkHardwareSupport(CV_CPU_AVX512_SKX));
        plhs[0] = s;
    }
    else if (method == "getHardwareFeatureName") {
        nargchk(nrhs==2 && nlhs<=1);
        int feature = rhs[1].toInt();
        string name = getHardwareFeatureName(feature);
        plhs[0] = MxArray(name);
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
    else if (method == "getPlatfomsInfo") {
        nargchk(nrhs==1 && nlhs<=1);
        vector<ocl::PlatformInfo> vpi;
        ocl::getPlatfomsInfo(vpi);
        plhs[0] = toStruct(vpi);
    }
#if 0
    else if (method == "dumpOpenCLInformation") {
        nargchk(nrhs==1 && nlhs==0);
        dumpOpenCLInformation();
    }
#endif
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
    else if (method == "deviceInfo") {
        nargchk(nrhs==2 && nlhs<=1);
        cuda::DeviceInfo di(rhs[1].toInt());
        plhs[0] = toStruct(di);
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
