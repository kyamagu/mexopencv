/**
 * @file HOGDescriptor_.cpp
 * @brief mex interface for HOGDescriptor
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,HOGDescriptor> obj_;

/** HistogramNormType map
 */
const ConstMap<std::string,int> HistogramNormType = ConstMap<std::string,int>
    ("L2Hys",HOGDescriptor::L2Hys);
/** HistogramNormType inverse map
 */
const ConstMap<int,std::string> InvHistogramNormType = ConstMap<int,std::string>
    (HOGDescriptor::L2Hys,"L2Hys");

/// Alias for argument number check
inline void nargchk(bool cond)
{
    if (!cond)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
}

}

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
    nargchk(nrhs>=2 && nlhs<=2);
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor call
    if (method == "new") {
        nargchk(nlhs<=1);
        if (nrhs==3 && rhs[2].isChar())
            obj_[++last_id] = HOGDescriptor(rhs[2].toString());
        else {
            nargchk((nrhs%2)==0);
            obj_[++last_id] = HOGDescriptor();
            HOGDescriptor& obj = obj_[last_id];
            for (int i=2; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "WinSize")
                    obj.winSize = rhs[i+1].toSize();
                else if (key == "BlockSize")
                    obj.blockSize = rhs[i+1].toSize();
                else if (key == "BlockStride")
                    obj.blockStride = rhs[i+1].toSize();
                else if (key == "CellSize")
                    obj.cellSize = rhs[i+1].toSize();
                else if (key == "NBins")
                    obj.nbins = rhs[i+1].toInt();
                else if (key == "DerivAperture")
                    obj.derivAperture = rhs[i+1].toInt();
                else if (key == "WinSigma")
                    obj.winSigma = rhs[i+1].toDouble();
                else if (key == "HistogramNormType")
                    obj.histogramNormType = HistogramNormType[rhs[i+1].toString()];
                else if (key == "L2HysThreshold")
                    obj.L2HysThreshold = rhs[i+1].toDouble();
                else if (key == "GammaCorrection")
                    obj.gammaCorrection = rhs[i+1].toBool();
                else if (key == "NLevels")
                    obj.nlevels = rhs[i+1].toInt();
                else
                    mexErrMsgIdAndTxt("mexopencv:error","Unknown option %s",key.c_str());
            }
        }
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    HOGDescriptor& obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "getDescriptorSize") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(static_cast<int>(obj.getDescriptorSize()));
    }
    else if (method == "checkDetectorSize") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj.checkDetectorSize());
    }
    else if (method == "getWinSigma") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj.getWinSigma());
    }
    else if (method == "setSVMDetector") {
        nargchk(nrhs==3 && nlhs==0);
        if (rhs[2].isChar()) {
            string key(rhs[2].toString());
            if (key=="Default")
                obj.setSVMDetector(HOGDescriptor::getDefaultPeopleDetector());
            else if (key=="Daimler")
                obj.setSVMDetector(HOGDescriptor::getDaimlerPeopleDetector());
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option %s", key.c_str());
        }
        else
            obj.setSVMDetector(rhs[2].toVector<float>());
    }
    else if (method == "readALTModel") {
        nargchk(nrhs==3 && nlhs==0);
        obj.readALTModel(rhs[2].toString());
    }
    else if (method == "load") {
        nargchk(nrhs==3 && nlhs<=1);
        plhs[0] = MxArray(obj.load(rhs[2].toString()));
    }
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs==0);
        obj.save(rhs[2].toString());
    }
    else if (method == "compute") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);

        Mat img(rhs[2].isUint8() ? rhs[2].toMat() : rhs[2].toMat(CV_32F));
        Size winStride;
        Size padding;
        vector<Point> locations;
        for (int i=3; i<nrhs; i+=2) {
            string key = rhs[i].toString();
            if (key=="WinStride")
                winStride = rhs[i+1].toSize();
            else if (key=="Padding")
                padding = rhs[i+1].toSize();
            else if (key=="Locations")
                locations = rhs[i+1].toVector<Point>();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option %s", key.c_str());
        }

        // Run
        vector<float> descriptors;
        obj.compute(img,descriptors,winStride,padding,locations);
        Mat m(descriptors);
        plhs[0] = MxArray(m.reshape(0,m.total()/obj.getDescriptorSize()));
    }
    else if (method == "detect") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=2);

        Mat img(rhs[2].isUint8() ? rhs[2].toMat() : rhs[2].toMat(CV_32F));
        double hitThreshold = 0;
        Size winStride;
        Size padding;
        vector<Point> searchLocations;
        for (int i=3; i<nrhs; i+=2) {
            string key = rhs[i].toString();
            if (key=="HitThreshold")
                hitThreshold = rhs[i+1].toDouble();
            else if (key=="WinStride")
                winStride = rhs[i+1].toSize();
            else if (key=="Padding")
                padding = rhs[i+1].toSize();
            else if (key=="Locations")
                searchLocations = rhs[i+1].toVector<Point>();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option %s", key.c_str());
        }

        // Run
        vector<Point> foundLocations;
        vector<double> weights;
        obj.detect(img, foundLocations, weights, hitThreshold, winStride,
            padding, searchLocations);
        plhs[0] = MxArray(foundLocations);
        if (nlhs>1)
            plhs[1] = MxArray(Mat(weights));
    }
    else if (method == "detectMultiScale") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=2);

        Mat img(rhs[2].isUint8() ? rhs[2].toMat() : rhs[2].toMat(CV_32F));
        double hitThreshold = 0;
        Size winStride;
        Size padding;
        double scale = 1.05;
        double finalThreshold = 2.0;
        bool useMeanshiftGrouping = false;
        for (int i=3; i<nrhs; i+=2) {
            string key = rhs[i].toString();
            if (key=="HitThreshold")
                hitThreshold = rhs[i+1].toDouble();
            else if (key=="WinStride")
                winStride = rhs[i+1].toSize();
            else if (key=="Padding")
                padding = rhs[i+1].toSize();
            else if (key=="Scale")
                scale = rhs[i+1].toDouble();
            else if (key=="FinalThreshold")
                finalThreshold = rhs[i+1].toDouble();
            else if (key=="UseMeanshiftGrouping")
                useMeanshiftGrouping = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option %s", key.c_str());
        }

        // Run
        vector<Rect> foundLocations;
        vector<double> weights;
        obj.detectMultiScale(img, foundLocations, weights, hitThreshold, winStride,
            padding, scale, finalThreshold, useMeanshiftGrouping);
        plhs[0] = MxArray(foundLocations);
        if (nlhs>1)
            plhs[1] = MxArray(Mat(weights));
    }
    else if (method == "computeGradient") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=2);

        Mat img(rhs[2].isUint8() ? rhs[2].toMat() : rhs[2].toMat(CV_32F));
        Size paddingTL;
        Size paddingBR;
        for (int i=3; i<nrhs; i+=2) {
            string key = rhs[i].toString();
            if (key=="PaddingTL")
                paddingTL = rhs[i+1].toSize();
            else if (key=="PaddingBR")
                paddingBR = rhs[i+1].toSize();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option %s", key.c_str());
        }

        // Run
        Mat grad, angleOfs;
        obj.computeGradient(img,grad,angleOfs,paddingTL,paddingBR);
        plhs[0] = MxArray(grad);
        if (nlhs>1)
            plhs[1] = MxArray(angleOfs);
    }
    else if (method == "winSize") {
        if (nlhs==1 && nrhs==2)
            plhs[0] = MxArray(obj.winSize);
        else if (nlhs==0 && nrhs==3)
            obj.winSize = rhs[2].toSize();
        else
            nargchk(false);
    }
    else if (method == "blockSize") {
        if (nlhs==1 && nrhs==2)
            plhs[0] = MxArray(obj.blockSize);
        else if (nlhs==0 && nrhs==3)
            obj.blockSize = rhs[2].toSize();
        else
            nargchk(false);
    }
    else if (method == "blockStride") {
        if (nlhs==1 && nrhs==2)
            plhs[0] = MxArray(obj.blockStride);
        else if (nlhs==0 && nrhs==3)
            obj.blockStride = rhs[2].toSize();
        else
            nargchk(false);
    }
    else if (method == "cellSize") {
        if (nlhs==1 && nrhs==2)
            plhs[0] = MxArray(obj.cellSize);
        else if (nlhs==0 && nrhs==3)
            obj.cellSize = rhs[2].toSize();
        else
            nargchk(false);
    }
    else if (method == "nbins") {
        if (nlhs==1 && nrhs==2)
            plhs[0] = MxArray(obj.nbins);
        else if (nlhs==0 && nrhs==3)
            obj.nbins = rhs[2].toInt();
        else
            nargchk(false);
    }
    else if (method == "derivAperture") {
        if (nlhs==1 && nrhs==2)
            plhs[0] = MxArray(obj.derivAperture);
        else if (nlhs==0 && nrhs==3)
            obj.derivAperture = rhs[2].toInt();
        else
            nargchk(false);
    }
    else if (method == "winSigma") {
        if (nlhs==1 && nrhs==2)
            plhs[0] = MxArray(obj.winSigma);
        else if (nlhs==0 && nrhs==3)
            obj.winSigma = rhs[2].toDouble();
        else
            nargchk(false);
    }
    else if (method == "histogramNormType") {
        if (nlhs==1 && nrhs==2)
            plhs[0] = MxArray(InvHistogramNormType[obj.histogramNormType]);
        else if (nlhs==0 && nrhs==3)
            obj.histogramNormType = HistogramNormType[rhs[2].toString()];
        else
            nargchk(false);
    }
    else if (method == "L2HysThreshold") {
        if (nlhs==1 && nrhs==2)
            plhs[0] = MxArray(obj.L2HysThreshold);
        else if (nlhs==0 && nrhs==3)
            obj.L2HysThreshold = rhs[2].toDouble();
        else
            nargchk(false);
    }
    else if (method == "gammaCorrection") {
        if (nlhs==1 && nrhs==2)
            plhs[0] = MxArray(obj.gammaCorrection);
        else if (nlhs==0 && nrhs==3)
            obj.gammaCorrection = rhs[2].toBool();
        else
            nargchk(false);
    }
    else if (method == "nlevels") {
        if (nlhs==1 && nrhs==2)
            plhs[0] = MxArray(obj.nlevels);
        else if (nlhs==0 && nrhs==3)
            obj.nlevels = rhs[2].toInt();
        else
            nargchk(false);
    }
    else if (method == "svmDetector") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(Mat(obj.svmDetector));
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation %s", method.c_str());
}
