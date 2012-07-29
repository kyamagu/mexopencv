/**
 * @file calcBackProject.cpp
 * @brief mex interface for calcBackProject
 * @author Kota Yamaguchi
 * @date 2011
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
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Check the number of arguments
    if (nrhs<3 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Prepare arguments
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // arrays
    vector<MxArray> arrays_(rhs[0].toVector<MxArray>());
    vector<Mat> arrays(arrays_.size());
    for (int i=0; i<arrays_.size(); ++i)
        arrays[i] = (arrays_[i].isUint8()) ?
            arrays_[i].toMat(CV_8U) : arrays_[i].toMat(CV_32F);
    
    // channels
    int total_channels = 0;
    for (vector<Mat>::iterator it = arrays.begin(); it < arrays.end(); ++it)
        total_channels += (*it).channels();
    vector<int> channels(total_channels);
    for (int i=0; i<total_channels; ++i)
        channels[i] = i;
    
    // dims, histSize, ranges
    vector<MxArray> ranges_(rhs[2].toVector<MxArray>());
    vector<Mat> ranges(ranges_.size());
    for (int i=0; i<ranges_.size(); ++i)
        ranges[i] = ranges_[i].toMat(CV_32F);
    vector<const float*> ranges_ptr(ranges.size());
    for (int i=0; i<ranges.size(); ++i)
        ranges_ptr[i] = ranges[i].ptr<float>(0);
    
    // Option processing
    bool scale=1;
    bool uniform=false;
    for (int i=3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Uniform")
            uniform = rhs[i+1].toBool();
        else if (key=="Scale")
            scale = rhs[i+1].toDouble();
        else if (key=="Channels")
            channels = rhs[i+1].toVector<int>();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    Mat backProject;
    if (rhs[1].isSparse()) {
        SparseMat hist(rhs[1].toSparseMat());
        calcBackProject(&arrays[0], arrays.size(), &channels[0], hist,
            backProject, &ranges_ptr[0], scale, uniform);
        plhs[0] = MxArray(backProject);
    }
    else {
        MatND hist(rhs[1].toMatND());
        calcBackProject(&arrays[0], arrays.size(), &channels[0], hist,
            backProject, &ranges_ptr[0], scale, uniform);
        plhs[0] = MxArray(backProject);
    }
}
