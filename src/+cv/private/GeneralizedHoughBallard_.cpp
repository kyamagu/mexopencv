/**
 * @file GeneralizedHoughBallard_.cpp
 * @brief mex interface for cv::GeneralizedHoughBallard
 * @ingroup imgproc
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<GeneralizedHoughBallard> > obj_;
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
    nargchk(nrhs>=2 && nlhs<=2);

    // Arguments vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = createGeneralizedHoughBallard();
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<GeneralizedHoughBallard> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
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
            if (key=="ObjName")
                objname = rhs[i+1].toString();
            else if (key=="FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option %s", key.c_str());
        }
        /*
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<GeneralizedHoughBallard>(rhs[2].toString(), objname) :
            Algorithm::load<GeneralizedHoughBallard>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing GeneralizedHoughBallard::create()
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        obj->read(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (obj.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to load algorithm");
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
    else if (method == "detect") {
        nargchk((nrhs==3 || nrhs==5) && nlhs<=2);
        vector<Vec4f> positions;
        vector<Vec3i> votes;
        if (nrhs == 3) {
            Mat image(rhs[2].toMat(CV_8U));
            obj->detect(image, positions, (nlhs>1) ? votes : noArray());
        }
        else {
            Mat edges(rhs[2].toMat(CV_8U)),
                   dx(rhs[3].toMat(CV_32F)),
                   dy(rhs[4].toMat(CV_32F));
            obj->detect(edges, dx, dy, positions, (nlhs>1) ? votes : noArray());
        }
        plhs[0] = MxArray(positions);
        if (nlhs>1)
            plhs[1] = MxArray(votes);
    }
    else if (method == "setTemplate") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        bool edges_variant = (nrhs>=5 && rhs[3].isNumeric() && rhs[4].isNumeric());
        Point templCenter(-1,-1);
        for (int i=(edges_variant ? 5 : 3); i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Center")
                templCenter = rhs[i+1].toPoint();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        if (edges_variant) {
            Mat edges(rhs[2].toMat(CV_8U)),
                   dx(rhs[3].toMat(CV_32F)),
                   dy(rhs[4].toMat(CV_32F));
            obj->setTemplate(edges, dx, dy, templCenter);
        }
        else {
            Mat templ(rhs[2].toMat(CV_8U));
            obj->setTemplate(templ, templCenter);
        }
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "CannyHighThresh")
            plhs[0] = MxArray(obj->getCannyHighThresh());
        else if (prop == "CannyLowThresh")
            plhs[0] = MxArray(obj->getCannyLowThresh());
        else if (prop == "Dp")
            plhs[0] = MxArray(obj->getDp());
        else if (prop == "MaxBufferSize")
            plhs[0] = MxArray(obj->getMaxBufferSize());
        else if (prop == "MinDist")
            plhs[0] = MxArray(obj->getMinDist());
        else if (prop == "Levels")
            plhs[0] = MxArray(obj->getLevels());
        else if (prop == "VotesThreshold")
            plhs[0] = MxArray(obj->getVotesThreshold());
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "CannyHighThresh")
            obj->setCannyHighThresh(rhs[3].toInt());
        else if (prop == "CannyLowThresh")
            obj->setCannyLowThresh(rhs[3].toInt());
        else if (prop == "Dp")
            obj->setDp(rhs[3].toDouble());
        else if (prop == "MaxBufferSize")
            obj->setMaxBufferSize(rhs[3].toInt());
        else if (prop == "MinDist")
            obj->setMinDist(rhs[3].toDouble());
        else if (prop == "Levels")
            obj->setLevels(rhs[3].toInt());
        else if (prop == "VotesThreshold")
            obj->setVotesThreshold(rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
