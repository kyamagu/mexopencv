/**
 * @file calcHist.cpp
 * @brief mex interface for cv::calcHist
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
int check_arguments(int dims, bool uniform,
    const vector<vector<float> > &ranges, const vector<int> &channels,
    const vector<int> &histSize)
{
    // some defensive checks not covered in cv::calcHist
    // TODO: we could also infer dims/histSize from hist0 if supplied
    if (!histSize.empty() && !ranges.empty()) {
        if (histSize.size() != ranges.size())
            mexErrMsgIdAndTxt("mexopencv:error",
                "HistSize must match histogram dimensionality");
        if (!uniform) {
            for (mwIndex i=0; i<ranges.size(); ++i) {
                if (histSize[i] != (ranges[i].size() - 1))
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "HistSize must match non-uniform ranges");
            }
        }
    }
    else if (!histSize.empty() && ranges.empty()) {
        if (uniform)
            dims = histSize.size();  // infer dims from histSize not ranges
    }
    if (!channels.empty() && channels.size() < dims)
        mexErrMsgIdAndTxt("mexopencv:error",
            "Channels must match histogram dimensionality");
    return dims;
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

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

    // channels: default to use all channels from all images to compute hist
    int total_channels = 0;
    for (vector<Mat>::const_iterator it = arrays.begin(); it != arrays.end(); ++it)
        total_channels += it->channels();
    vector<int> channels(total_channels);
    for (int i=0; i<total_channels; ++i)
        channels[i] = i;

    // ranges (cell array of vectors): bin boundaries in each hist dimension
    vector<vector<float> > ranges(MxArrayToVectorVectorPrimitive<float>(rhs[1]));
    int dims = static_cast<int>(ranges.size());  // histogram dimensionality
    vector<const float*> ranges_ptr(dims);
    for (mwIndex i=0; i<dims; ++i)
        ranges_ptr[i] = (!ranges[i].empty() ? &ranges[i][0] : NULL);

    // histSize: number of levels in each hist dimension (non-uniform case)
    vector<int> histSize(dims);
    for (mwIndex i=0; i<dims; ++i)
        histSize[i] = (!ranges[i].empty() ? ranges[i].size() - 1 : 0);

    // Option processing
    Mat mask;
    bool uniform = false;
    MxArray hist0(static_cast<mxArray*>(NULL));
    bool accumulate = false;
    bool sparse = false;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Channels")
            channels = rhs[i+1].toVector<int>();
        else if (key == "Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else if (key == "HistSize")
            histSize = rhs[i+1].toVector<int>();
        else if (key == "Uniform")
            uniform = rhs[i+1].toBool();
        else if (key == "Hist") {
            hist0 = rhs[i+1];  // either MatND or SparseMat
            accumulate = true;
        }
        else if (key == "Sparse")
            sparse = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    dims = check_arguments(dims, uniform, ranges, channels, histSize);
    if (sparse) {
        SparseMat hist;
        if (accumulate) hist = hist0.toSparseMat();
        calcHist((!arrays.empty() ? &arrays[0] : NULL), arrays.size(),
            (!channels.empty() ? &channels[0] : NULL), mask, hist, dims,
            (!histSize.empty() ? &histSize[0] : NULL),
            (!ranges_ptr.empty() ? &ranges_ptr[0] : NULL),
            uniform, accumulate);
        plhs[0] = MxArray(hist);  // 2D sparse matrix
    }
    else {
        MatND hist;
        if (accumulate) hist = hist0.toMatND(CV_32F);
        calcHist((!arrays.empty() ? &arrays[0] : NULL), arrays.size(),
            (!channels.empty() ? &channels[0] : NULL), mask, hist, dims,
            (!histSize.empty() ? &histSize[0] : NULL),
            (!ranges_ptr.empty() ? &ranges_ptr[0] : NULL),
            uniform, accumulate);
        plhs[0] = MxArray(hist);  // multi-dim dense array
    }
}
