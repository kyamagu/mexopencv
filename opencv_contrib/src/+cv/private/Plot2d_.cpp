/**
 * @file Plot2d_.cpp
 * @brief mex interface for cv::plot::Plot2d
 * @ingroup plot
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/plot.hpp"
using namespace std;
using namespace cv;
using namespace cv::plot;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<Plot2d> > obj_;
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Arguments vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk((nrhs==3||nrhs==4) && nlhs<=1);
        Ptr<Plot2d> p;
        if (nrhs == 3) {
            Mat data(rhs[2].toMat(CV_64F));
            p = Plot2d::create(data);
        }
        else {
            Mat dataX(rhs[2].toMat(CV_64F)),
                dataY(rhs[3].toMat(CV_64F));
            p = Plot2d::create(dataX, dataY);
        }
        obj_[++last_id] = p;
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<Plot2d> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "load") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        string objname;
        bool loadFromString = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ObjName")
                objname = rhs[i+1].toString();
            else if (key == "FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        /*
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<Plot2d>(rhs[2].toString(), objname) :
            Algorithm::load<Plot2d>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing Plot2d::create()
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        if (!fs.isOpened())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
        FileNode fn(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (fn.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to get node");
        obj->read(fn);
        //*/
    }
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs==0);
        obj->save(rhs[2].toString());
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "render") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        bool flip = true;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "FlipChannels")
                flip = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat img;
        obj->render(img);
        if (flip && (img.channels() == 3 || img.channels() == 4)) {
            // OpenCV's default is BGR/BGRA while MATLAB's is RGB/RGBA
            cvtColor(img, img, (img.channels()==3 ?
                cv::COLOR_BGR2RGB : cv::COLOR_BGRA2RGBA));
        }
        plhs[0] = MxArray(img);
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "MinX")
            obj->setMinX(rhs[3].toDouble());
        else if (prop == "MinY")
            obj->setMinY(rhs[3].toDouble());
        else if (prop == "MaxX")
            obj->setMaxX(rhs[3].toDouble());
        else if (prop == "MaxY")
            obj->setMaxY(rhs[3].toDouble());
        else if (prop == "PlotLineWidth")
            obj->setPlotLineWidth(rhs[3].toInt());
        else if (prop == "NeedPlotLine")
            obj->setNeedPlotLine(rhs[3].toBool());
        else if (prop == "PlotLineColor")
            obj->setPlotLineColor((rhs[3].isChar()) ?
                ColorType[rhs[3].toString()] : rhs[3].toScalar());
        else if (prop == "PlotBackgroundColor")
            obj->setPlotBackgroundColor((rhs[3].isChar()) ?
                ColorType[rhs[3].toString()] : rhs[3].toScalar());
        else if (prop == "PlotAxisColor")
            obj->setPlotAxisColor((rhs[3].isChar()) ?
                ColorType[rhs[3].toString()] : rhs[3].toScalar());
        else if (prop == "PlotGridColor")
            obj->setPlotGridColor((rhs[3].isChar()) ?
                ColorType[rhs[3].toString()] : rhs[3].toScalar());
        else if (prop == "PlotTextColor")
            obj->setPlotTextColor((rhs[3].isChar()) ?
                ColorType[rhs[3].toString()] : rhs[3].toScalar());
        else if (prop == "PlotSize") {
            Size sz(rhs[3].toSize());
            obj->setPlotSize(sz.width, sz.height);
        }
        else if (prop == "ShowGrid")
            obj->setShowGrid(rhs[3].toBool());
        else if (prop == "ShowText")
            obj->setShowText(rhs[3].toBool());
        else if (prop == "GridLinesNumber")
            obj->setGridLinesNumber(rhs[3].toInt());
        else if (prop == "InvertOrientation")
            obj->setInvertOrientation(rhs[3].toBool());
        else if (prop == "PointIdxToPrint")
            obj->setPointIdxToPrint(rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
