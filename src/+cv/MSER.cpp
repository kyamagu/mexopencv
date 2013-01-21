/**
 * @file MSER.cpp
 * @brief mex interface for MSER
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
    if (nrhs<1 || ((nrhs%2)!=1) || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Option processing
    int _delta = 5;
    int _min_area = 60;
    int _max_area = 14400;
    double _max_variation = .25f;
    double _min_diversity = .2f;
    int _max_evolution = 200;
    double _area_threshold = 1.01;
    double _min_margin = .003;
    int _edge_blur_size = 5;
    Mat mask;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Delta")
            _delta = rhs[i+1].toInt();
        else if (key=="MinArea")
            _min_area = rhs[i+1].toInt();
        else if (key=="MaxArea")
            _max_area = rhs[i+1].toInt();
        else if (key=="MaxVariation")
            _max_variation = rhs[i+1].toDouble();
        else if (key=="MinDiversity")
            _min_diversity = rhs[i+1].toDouble();
        else if (key=="MaxEvolution")
            _max_evolution = rhs[i+1].toInt();
        else if (key=="AreaThreshold")
            _area_threshold = rhs[i+1].toDouble();
        else if (key=="MinMargin")
            _min_margin = rhs[i+1].toDouble();
        else if (key=="EdgeBlurSize")
            _edge_blur_size = rhs[i+1].toInt();
        else if (key=="Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    MSER mser(_delta, _min_area, _max_area, _max_variation, _min_diversity,
              _max_evolution, _area_threshold, _min_margin, _edge_blur_size);
    Mat image(rhs[0].toMat());
    vector<vector<Point> > msers;
    mser(image, msers, mask);
    plhs[0] = MxArray(msers);
}
