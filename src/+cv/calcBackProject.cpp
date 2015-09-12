/**
 * @file calcBackProject.cpp
 * @brief mex interface for cv::calcBackProject
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
void check_arguments(int hist_dims, bool uniform,
    const vector<vector<float> > &ranges, const vector<int> &channels)
{
    // some sanity checks not covered in cv::calcBackProject
    if (!channels.empty() && channels.size() < hist_dims)
        mexErrMsgIdAndTxt("mexopencv:error",
            "Channels must match histogram dimensionality");
    if ((!ranges.empty() || !uniform) && ranges.size() != hist_dims)
        mexErrMsgIdAndTxt("mexopencv:error",
            "Ranges must match histogram dimensionality");
    if (!uniform) {
        for (vector<vector<float> >::const_iterator it = ranges.begin(); it != ranges.end(); ++it)
            if (it->empty())
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Ranges cannot be empty for non-uniform histogram");
    }
}

/// determine histogram dimensionality: 1-D, 2-D, or N-D
int histogram_dims(const SparseMat &hist)
{
    return ((hist.dims() > 2) ? hist.dims() :
        ((hist.size(0) == 1 || hist.size(1) == 1) ? 1 : 2));
}

/// determine histogram dimensionality: 1-D, 2-D, or N-D
int histogram_dims(const MatND &hist)
{
    return ((hist.dims > 2) ? hist.dims :
        ((hist.rows == 1 || hist.cols == 1) ? 1 : 2));
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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // source arrays (cell array of images)
    vector<Mat> arrays;
    {
        vector<MxArray> arrays_(rhs[0].toVector<MxArray>());
        arrays.reserve(arrays_.size());
        for (vector<MxArray>::const_iterator it = arrays_.begin(); it != arrays_.end(); ++it)
            arrays.push_back(it->toMat(it->isUint8() ? CV_8U :
                (it->isUint16() ? CV_16U : CV_32F)));
    }

    // channels: default to use all channels from all images
    int total_channels = 0;
    for (vector<Mat>::const_iterator it = arrays.begin(); it != arrays.end(); ++it)
        total_channels += it->channels();
    vector<int> channels(total_channels);
    for (int i=0; i<total_channels; ++i)
        channels[i] = i;

    // ranges (cell array of vectors): bin boundaries in each hist dimension
    vector<vector<float> > ranges(MxArrayToVectorVectorPrimitive<float>(rhs[2]));
    mwSize dims = ranges.size();
    vector<const float*> ranges_ptr(dims);
    for (mwIndex i=0; i<dims; ++i)
        ranges_ptr[i] = (!ranges[i].empty() ? &ranges[i][0] : NULL);

    // Option processing
    double scale = 1.0;
    bool uniform = false;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Channels")
            channels = rhs[i+1].toVector<int>();
        else if (key == "Scale")
            scale = rhs[i+1].toDouble();
        else if (key == "Uniform")
            uniform = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat backProject;
    if (rhs[1].isSparse()) {
        SparseMat hist(rhs[1].toSparseMat());  // 2D sparse matrix
        check_arguments(histogram_dims(hist), uniform, ranges, channels);
        calcBackProject((arrays.empty() ? NULL : &arrays[0]), arrays.size(),
            (channels.empty() ? NULL : &channels[0]), hist, backProject,
            (ranges_ptr.empty() ? NULL : &ranges_ptr[0]), scale, uniform);
    }
    else {
        MatND hist(rhs[1].toMatND(CV_32F));  // multi-dim dense array
        check_arguments(histogram_dims(hist), uniform, ranges, channels);
        calcBackProject((arrays.empty() ? NULL : &arrays[0]), arrays.size(),
            (channels.empty() ? NULL : &channels[0]), hist, backProject,
            (ranges_ptr.empty() ? NULL : &ranges_ptr[0]), scale, uniform);
    }
    plhs[0] = MxArray(backProject);
}
