/**
 * @file findCirclesGrid.cpp
 * @brief mex interface for cv::findCirclesGrid
 * @ingroup calib3d
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
#include "mexopencv_features2d.hpp"  // createFeatureDetector
#include "opencv2/calib3d.hpp"
using namespace std;
using namespace cv;

namespace {
/// grid types for option processing
const ConstMap<string,cv::CirclesGridFinderParameters::GridType> GridTypesMap =
    ConstMap<string,cv::CirclesGridFinderParameters::GridType>
    ("Symmetric",  cv::CirclesGridFinderParameters::SYMMETRIC_GRID)
    ("Asymmetric", cv::CirclesGridFinderParameters::ASYMMETRIC_GRID);

/** Convert MxArray to cv::CirclesGridFinderParameters2
 * @param arr MxArray object. In one of the following forms:
 * - a scalar struct
 * - a cell-array of the form: <tt>{GridType, ...}</tt> starting with the grid
 *   type ("Symmetric" or "Asymmetric") followed by pairs of key-value options
 * @return instance of CirclesGridFinderParameters2 object
 */
CirclesGridFinderParameters2 MxArrayToFinderParameters(const MxArray &arr)
{
    CirclesGridFinderParameters2 params;
    if (arr.isStruct()) {
        params.gridType = GridTypesMap[arr.at("gridType").toString()];
        if (arr.isField("densityNeighborhoodSize"))
            params.densityNeighborhoodSize = arr.at("densityNeighborhoodSize").toSize_<float>();
        if (arr.isField("minDensity"))
            params.minDensity = arr.at("minDensity").toFloat();
        if (arr.isField("kmeansAttempts"))
            params.kmeansAttempts = arr.at("kmeansAttempts").toInt();
        if (arr.isField("minDistanceToAddKeypoint"))
            params.minDistanceToAddKeypoint = arr.at("minDistanceToAddKeypoint").toInt();
        if (arr.isField("keypointScale"))
            params.keypointScale = arr.at("keypointScale").toInt();
        if (arr.isField("minGraphConfidence"))
            params.minGraphConfidence = arr.at("minGraphConfidence").toFloat();
        if (arr.isField("vertexGain"))
            params.vertexGain = arr.at("vertexGain").toFloat();
        if (arr.isField("vertexPenalty"))
            params.vertexPenalty = arr.at("vertexPenalty").toFloat();
        if (arr.isField("existingVertexGain"))
            params.existingVertexGain = arr.at("existingVertexGain").toFloat();
        if (arr.isField("edgeGain"))
            params.edgeGain = arr.at("edgeGain").toFloat();
        if (arr.isField("edgePenalty"))
            params.edgePenalty = arr.at("edgePenalty").toFloat();
        if (arr.isField("convexHullFactor"))
            params.convexHullFactor = arr.at("convexHullFactor").toFloat();
        if (arr.isField("minRNGEdgeSwitchDist"))
            params.minRNGEdgeSwitchDist = arr.at("minRNGEdgeSwitchDist").toFloat();
        if (arr.isField("squareSize"))
            params.squareSize = arr.at("squareSize").toFloat();
        if (arr.isField("maxRectifiedDistance"))
            params.maxRectifiedDistance = arr.at("maxRectifiedDistance").toFloat();
    }
    else {
        vector<MxArray> args(arr.toVector<MxArray>());
        nargchk(args.size() >= 1 && (args.size()%2)==1);
        params.gridType = GridTypesMap[args[0].toString()];
        for (size_t i = 1; i < args.size(); i+=2) {
            string key(args[i].toString());
            if (key == "DensityNeighborhoodSize")
                params.densityNeighborhoodSize = args[i+1].toSize_<float>();
            else if (key == "MinDensity")
                params.minDensity = args[i+1].toFloat();
            else if (key == "KmeansAttempts")
                params.kmeansAttempts = args[i+1].toInt();
            else if (key == "MinDistanceToAddKeypoint")
                params.minDistanceToAddKeypoint = args[i+1].toInt();
            else if (key == "KeypointScale")
                params.keypointScale = args[i+1].toInt();
            else if (key == "MinGraphConfidence")
                params.minGraphConfidence = args[i+1].toFloat();
            else if (key == "VertexGain")
                params.vertexGain = args[i+1].toFloat();
            else if (key == "VertexPenalty")
                params.vertexPenalty = args[i+1].toFloat();
            else if (key == "ExistingVertexGain")
                params.existingVertexGain = args[i+1].toFloat();
            else if (key == "EdgeGain")
                params.edgeGain = args[i+1].toFloat();
            else if (key == "EdgePenalty")
                params.edgePenalty = args[i+1].toFloat();
            else if (key == "ConvexHullFactor")
                params.convexHullFactor = args[i+1].toFloat();
            else if (key == "MinRNGEdgeSwitchDist")
                params.minRNGEdgeSwitchDist = args[i+1].toFloat();
            else if (key == "SquareSize")
                params.squareSize = args[i+1].toFloat();
            else if (key == "MaxRectifiedDistance")
                params.maxRectifiedDistance = args[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized CirclesGridFinderParameters2 option %s", key.c_str());
        }
    }
    return params;
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    bool symmetricGrid = true;
    bool clustering = false;
    Ptr<FeatureDetector> blobDetector;
    CirclesGridFinderParameters2 params;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "SymmetricGrid")
            symmetricGrid = rhs[i+1].toBool();
        else if (key == "Clustering")
            clustering = rhs[i+1].toBool();
        else if (key == "BlobDetector") {
            if (rhs[i+1].isChar())
                blobDetector = createFeatureDetector(rhs[i+1].toString(),
                    rhs.end(), rhs.end());
            else if (rhs[i+1].isCell() && rhs[i+1].numel() >= 2) {
                vector<MxArray> args(rhs[i+1].toVector<MxArray>());
                blobDetector = createFeatureDetector(args[0].toString(),
                    args.begin() + 1, args.end());
            }
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Invalid detector arguments");
        }
        else if (key == "FinderParameters")
            params = MxArrayToFinderParameters(rhs[i+1]);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    int flags = (symmetricGrid ? cv::CALIB_CB_SYMMETRIC_GRID :
                                 cv::CALIB_CB_ASYMMETRIC_GRID) |
                (clustering    ? cv::CALIB_CB_CLUSTERING : 0);
    if (blobDetector.empty())
        blobDetector = SimpleBlobDetector::create();

    // Process
    Mat image(rhs[0].toMat(CV_8U));
    Size patternSize(rhs[1].toSize());
    vector<Point2f> centers;
    bool patternFound = findCirclesGrid2(image, patternSize, centers, flags,
        blobDetector, params);
    plhs[0] = MxArray(centers);
    if (nlhs > 1)
        plhs[1] = MxArray(patternFound);
}
