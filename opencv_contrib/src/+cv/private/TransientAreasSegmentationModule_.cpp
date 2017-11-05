/**
 * @file TransientAreasSegmentationModule_.cpp
 * @brief mex interface for cv::bioinspired::TransientAreasSegmentationModule
 * @ingroup bioinspired
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/bioinspired.hpp"
using namespace std;
using namespace cv;
using namespace cv::bioinspired;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<TransientAreasSegmentationModule> > obj_;

/** Create an instance of SegmentationParameters using options in arguments
 * @param[in,out] params SegmentationParameters struct to fill
 * @param[in] first iterator at the beginning of the vector range
 * @param[in] last iterator at the end of the vector range
 */
void createSegmentationParameters(
    SegmentationParameters &params,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "ThresholdON")
            params.thresholdON = val.toFloat();
        else if (key == "ThresholdOFF")
            params.thresholdOFF = val.toFloat();
        else if (key == "LocalEnergyTemporalConstant")
            params.localEnergy_temporalConstant = val.toFloat();
        else if (key == "LocalEnergySpatialConstant")
            params.localEnergy_spatialConstant = val.toFloat();
        else if (key == "NeighborhoodEnergyTemporalConstant")
            params.neighborhoodEnergy_temporalConstant = val.toFloat();
        else if (key == "NeighborhoodEnergySpatialConstant")
            params.neighborhoodEnergy_spatialConstant = val.toFloat();
        else if (key == "ContextEnergyTemporalConstant")
            params.contextEnergy_temporalConstant = val.toFloat();
        else if (key == "ContextEnergySpatialConstant")
            params.contextEnergy_spatialConstant = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
}

/** Convert segmentation parameters to scalar struct
 * @param[in] params instance of SegmentationParameters
 * @return scalar struct MxArray object
 */
MxArray toStruct(const SegmentationParameters &params)
{
    const char *fields[] = {"ThresholdON", "ThresholdOFF",
        "LocalEnergyTemporalConstant", "LocalEnergySpatialConstant",
        "NeighborhoodEnergyTemporalConstant",
        "NeighborhoodEnergySpatialConstant", "ContextEnergyTemporalConstant",
        "ContextEnergySpatialConstant"};
    MxArray s = MxArray::Struct(fields, 8);
    s.set("ThresholdON",                        params.thresholdON);
    s.set("ThresholdOFF",                       params.thresholdOFF);
    s.set("LocalEnergyTemporalConstant",        params.localEnergy_temporalConstant);
    s.set("LocalEnergySpatialConstant",         params.localEnergy_spatialConstant);
    s.set("NeighborhoodEnergyTemporalConstant", params.neighborhoodEnergy_temporalConstant);
    s.set("NeighborhoodEnergySpatialConstant",  params.neighborhoodEnergy_spatialConstant);
    s.set("ContextEnergyTemporalConstant",      params.contextEnergy_temporalConstant);
    s.set("ContextEnergySpatialConstant",       params.contextEnergy_spatialConstant);
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs==3 && nlhs<=1);
        obj_[++last_id] = TransientAreasSegmentationModule::create(
            rhs[2].toSize());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<TransientAreasSegmentationModule> obj = obj_[id];
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
            Algorithm::loadFromString<TransientAreasSegmentationModule>(rhs[2].toString(), objname) :
            Algorithm::load<TransientAreasSegmentationModule>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing TransientAreasSegmentationModule::create()
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
    else if (method == "getSize") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getSize());
    }
    else if (method == "setup") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        string segmentationParameterFile(rhs[2].toString());
        bool applyDefaultSetupOnFailure = true;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ApplyDefaultSetupOnFailure")
                applyDefaultSetupOnFailure = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj->setup(segmentationParameterFile, applyDefaultSetupOnFailure);
    }
    else if (method == "setupParameters") {
        nargchk(nrhs>=2 && nlhs==0);
        SegmentationParameters newParameters;
        createSegmentationParameters(newParameters, rhs.begin() + 2, rhs.end());
        obj->setup(newParameters);
    }
    else if (method == "getParameters") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = toStruct(obj->getParameters());
    }
    else if (method == "printSetup") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->printSetup());
    }
    else if (method == "write") {
        nargchk(nrhs==3 && nlhs<=1);
        string fname(rhs[2].toString());
        if (nlhs > 0) {
            FileStorage fs(fname, FileStorage::WRITE + FileStorage::MEMORY);
            if (!fs.isOpened())
                mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
            obj->write(fs);
            plhs[0] = MxArray(fs.releaseAndGetString());
        }
        else
            obj->write(fname);
    }
    else if (method == "run") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        int channelIndex = 0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ChannelIndex")
                channelIndex = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat inputToSegment(rhs[2].toMat(CV_32F));
        obj->run(inputToSegment, channelIndex);
    }
    else if (method == "getSegmentationPicture") {
        nargchk(nrhs==2 && nlhs<=1);
        Mat transientAreas;
        obj->getSegmentationPicture(transientAreas);
        plhs[0] = MxArray(transientAreas);
    }
    else if (method == "clearAllBuffers") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clearAllBuffers();
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
