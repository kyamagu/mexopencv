/**
 * @file InferBbox.cpp
 * @brief mex interface for cv::dnn_objdetect::InferBbox
 * @ingroup dnn_objdetect
 * @author Amro
 * @date 2018
 */
#include "mexopencv.hpp"
#include "opencv2/core_detect.hpp"
using namespace std;
using namespace cv;
using namespace cv::dnn_objdetect;

namespace {
/** Convert detections to struct array
 * @param detections vector of detected objects
 * @return struct-array MxArray object
 */
MxArray toStruct(const vector<cv::dnn_objdetect::object>& detections)
{
    const char *fields[4] = {"bbox", "class_idx", "label_name", "class_prob"};
    MxArray s = MxArray::Struct(fields, 4, 1, detections.size());
    for (mwIndex i = 0; i < detections.size(); ++i) {
        int bbox[4] = {detections[i].xmin, detections[i].ymin,
            detections[i].xmax, detections[i].ymax};
        s.set(fields[0], vector<int>(bbox, bbox+4), i);
        s.set(fields[1], static_cast<int>(detections[i].class_idx), i);
        s.set(fields[2], detections[i].label_name, i);
        s.set(fields[3], detections[i].class_prob, i);
    }
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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    double thresh = 0.8;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Threshold")
            thresh = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    MatND delta_bbox(rhs[0].toMatND(CV_32F)),
        class_scores(rhs[1].toMatND(CV_32F)),
        conf_scores(rhs[2].toMatND(CV_32F));
    InferBbox inf(delta_bbox, class_scores, conf_scores);
    inf.filter(thresh);
    plhs[0] = toStruct(inf.detections);
}
