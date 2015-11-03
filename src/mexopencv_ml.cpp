/** Implementation of mexopencv_ml.
 * @file mexopencv_ml.cpp
 * @author Amro
 * @date 2015
*/

#include "mexopencv_ml.hpp"
using std::vector;
using std::string;
using namespace cv;
using namespace cv::ml;


// ==================== XXX ====================

/// Option values for sample layouts
const ConstMap<string, int> SampleTypesMap = ConstMap<string, int>
    ("Row", cv::ml::ROW_SAMPLE)   // each training sample is a row of samples
    ("Col", cv::ml::COL_SAMPLE);  // each training sample occupies a column of samples

/// Option values for variable types
const ConstMap<string, int> VariableTypeMap = ConstMap<string, int>
    ("Numerical",   cv::ml::VAR_NUMERICAL)     // same as VAR_ORDERED
    ("Ordered",     cv::ml::VAR_ORDERED)       // ordered variables
    ("Categorical", cv::ml::VAR_CATEGORICAL)   // categorical variables
    ("N",           cv::ml::VAR_NUMERICAL)     // shorthand for (N)umerical
    ("O",           cv::ml::VAR_ORDERED)       // shorthand for (O)rdered
    ("C",           cv::ml::VAR_CATEGORICAL);  // shorthand for (C)ategorical


// ==================== XXX ====================

MxArray toStruct(const vector<DTrees::Node>& nodes)
{
    const char* fields[] = {"value", "classIdx", "parent", "left", "right",
        "defaultDir", "split"};
    MxArray s = MxArray::Struct(fields, 7, 1, nodes.size());
    for (size_t i=0; i<nodes.size(); ++i) {
        s.set("value",      nodes[i].value,      i);
        s.set("classIdx",   nodes[i].classIdx,   i);
        s.set("parent",     nodes[i].parent,     i);
        s.set("left",       nodes[i].left,       i);
        s.set("right",      nodes[i].right,      i);
        s.set("defaultDir", nodes[i].defaultDir, i);
        s.set("split",      nodes[i].split,      i);
    }
    return s;
}

MxArray toStruct(const vector<DTrees::Split>& splits)
{
    const char* fields[] = {"varIdx", "inversed", "quality", "next", "c",
        "subsetOfs"};
    MxArray s = MxArray::Struct(fields, 6, 1, splits.size());
    for (size_t i=0; i<splits.size(); ++i) {
        s.set("varIdx",    splits[i].varIdx,    i);
        s.set("inversed",  splits[i].inversed,  i);
        s.set("quality",   splits[i].quality,   i);
        s.set("next",      splits[i].next,      i);
        s.set("c",         splits[i].c,         i);
        s.set("subsetOfs", splits[i].subsetOfs, i);
    }
    return s;
}


// ==================== XXX ====================

Ptr<TrainData> createTrainData(
    const Mat& samples, const Mat& responses,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    nargchk((std::distance(first, last) % 2) == 0);
    int layout = cv::ml::ROW_SAMPLE;
    Mat varIdx, sampleIdx, sampleWeights, varType;
    Mat missing;  //TODO: currently not possible through TrainData interface
    int splitCount = -1;       // [0, nsamples)
    double splitRatio = -1.0;  // [0.0, 1.0)
    bool splitShuffle = true;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "Layout")
            layout = SampleTypesMap[val.toString()];
        else if (key == "VarIdx")
            varIdx = val.toMat(
                (val.isUint8() || val.isLogical()) ? CV_8U : CV_32S);
        else if (key == "SampleIdx")
            sampleIdx = val.toMat(
                (val.isUint8() || val.isLogical()) ? CV_8U : CV_32S);
        else if (key == "SampleWeights")
            sampleWeights = val.toMat(CV_32F);
        else if (key == "VarType") {
            if (val.isCell()) {
                vector<string> vtypes(val.toVector<string>());
                varType.create(1, vtypes.size(), CV_8U);
                for (size_t idx = 0; idx < vtypes.size(); idx++)
                    varType.at<uchar>(idx) = VariableTypeMap[vtypes[idx]];
            }
            else if (val.isChar()) {
                string str(val.toString());
                varType.create(1, str.size(), CV_8U);
                for (size_t idx = 0; idx < str.size(); idx++)
                    varType.at<uchar>(idx) = VariableTypeMap[string(1,str[idx])];
            }
            else if (val.isNumeric())
                varType = val.toMat(CV_8U);
            else
                mexErrMsgIdAndTxt("mexopencv:error", "Invalid VarType value");
        }
        else if (key == "MissingMask")
            missing = val.toMat(CV_8U);  //TODO: unused, see TrainData::setData
        else if (key == "TrainTestSplitCount")
            splitCount = val.toInt();
        else if (key == "TrainTestSplitRatio")
            splitRatio = val.toDouble();
        else if (key == "TrainTestSplitShuffle")
            splitShuffle = val.toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    Ptr<TrainData> p = TrainData::create(samples, layout, responses,
        varIdx, sampleIdx, sampleWeights, varType);
    if (splitCount >= 0)
        p->setTrainTestSplit(splitCount, splitShuffle);
    else if (splitRatio >= 0)
        p->setTrainTestSplitRatio(splitRatio, splitShuffle);
    return p;
}

Ptr<TrainData> loadTrainData(const string& filename,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    nargchk((std::distance(first, last) % 2) == 0);
    int headerLineCount = 1;
    int responseStartIdx = -1;
    int responseEndIdx = -1;
    string varTypeSpec;
    char delimiter = ',';
    char missch = '?';
    int splitCount = -1;       // [0, nsamples)
    double splitRatio = -1.0;  // [0.0, 1.0)
    bool splitShuffle = true;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "HeaderLineCount")
            headerLineCount = val.toInt();
        else if (key == "ResponseStartIdx")
            responseStartIdx = val.toInt();
        else if (key == "ResponseEndIdx")
            responseEndIdx = val.toInt();
        else if (key == "VarTypeSpec")
            varTypeSpec = val.toString();
        else if (key == "Delimiter")
            delimiter = (!val.isEmpty()) ? val.toString()[0] : ' ';
        else if (key == "Missing")
            missch = (!val.isEmpty()) ? val.toString()[0] : '?';
        else if (key == "TrainTestSplitCount")
            splitCount = val.toInt();
        else if (key == "TrainTestSplitRatio")
            splitRatio = val.toDouble();
        else if (key == "TrainTestSplitShuffle")
            splitShuffle = val.toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    Ptr<TrainData> p = TrainData::loadFromCSV(filename, headerLineCount,
        responseStartIdx, responseEndIdx, varTypeSpec, delimiter, missch);
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to load dataset '%s'", filename.c_str());
    if (splitCount >= 0)
        p->setTrainTestSplit(splitCount, splitShuffle);
    else if (splitRatio >= 0)
        p->setTrainTestSplitRatio(splitRatio, splitShuffle);
    return p;

}
