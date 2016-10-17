/** Implementation of mexopencv_aruco.
 * @file mexopencv_aruco.cpp
 * @ingroup aruco
 * @author Amro
 * @date 2016
 */

#include "mexopencv_aruco.hpp"
#include <cstdlib>
using std::vector;
using std::string;
using namespace cv;
using namespace cv::aruco;


// ==================== XXX ====================

DetectorParameters MxArrayToDetectorParameters(const MxArray &s)
{
    DetectorParameters params;
    if (s.isField("adaptiveThreshWinSizeMin"))
        params.adaptiveThreshWinSizeMin = s.at("adaptiveThreshWinSizeMin").toInt();
    if (s.isField("adaptiveThreshWinSizeMax"))
        params.adaptiveThreshWinSizeMax = s.at("adaptiveThreshWinSizeMax").toInt();
    if (s.isField("adaptiveThreshWinSizeStep"))
        params.adaptiveThreshWinSizeStep = s.at("adaptiveThreshWinSizeStep").toInt();
    if (s.isField("adaptiveThreshConstant"))
        params.adaptiveThreshConstant = s.at("adaptiveThreshConstant").toDouble();
    if (s.isField("minMarkerPerimeterRate"))
        params.minMarkerPerimeterRate = s.at("minMarkerPerimeterRate").toDouble();
    if (s.isField("maxMarkerPerimeterRate"))
        params.maxMarkerPerimeterRate = s.at("maxMarkerPerimeterRate").toDouble();
    if (s.isField("polygonalApproxAccuracyRate"))
        params.polygonalApproxAccuracyRate =
            s.at("polygonalApproxAccuracyRate").toDouble();
    if (s.isField("minCornerDistanceRate"))
        params.minCornerDistanceRate = s.at("minCornerDistanceRate").toDouble();
    if (s.isField("minDistanceToBorder"))
        params.minDistanceToBorder = s.at("minDistanceToBorder").toInt();
    if (s.isField("minMarkerDistanceRate"))
        params.minMarkerDistanceRate = s.at("minMarkerDistanceRate").toDouble();
    if (s.isField("doCornerRefinement"))
        params.doCornerRefinement = s.at("doCornerRefinement").toBool();
    if (s.isField("cornerRefinementWinSize"))
        params.cornerRefinementWinSize = s.at("cornerRefinementWinSize").toInt();
    if (s.isField("cornerRefinementMaxIterations"))
        params.cornerRefinementMaxIterations =
            s.at("cornerRefinementMaxIterations").toInt();
    if (s.isField("cornerRefinementMinAccuracy"))
        params.cornerRefinementMinAccuracy =
            s.at("cornerRefinementMinAccuracy").toDouble();
    if (s.isField("markerBorderBits"))
        params.markerBorderBits = s.at("markerBorderBits").toInt();
    if (s.isField("perspectiveRemovePixelPerCell"))
        params.perspectiveRemovePixelPerCell =
            s.at("perspectiveRemovePixelPerCell").toInt();
    if (s.isField("perspectiveRemoveIgnoredMarginPerCell"))
        params.perspectiveRemoveIgnoredMarginPerCell =
            s.at("perspectiveRemoveIgnoredMarginPerCell").toDouble();
    if (s.isField("maxErroneousBitsInBorderRate"))
        params.maxErroneousBitsInBorderRate =
            s.at("maxErroneousBitsInBorderRate").toDouble();
    if (s.isField("minOtsuStdDev"))
        params.minOtsuStdDev = s.at("minOtsuStdDev").toDouble();
    if (s.isField("errorCorrectionRate"))
        params.errorCorrectionRate = s.at("errorCorrectionRate").toDouble();
    return params;
}

Dictionary MxArrayToDictionary(const MxArray &arr)
{
    Dictionary dictionary;
    if (arr.isChar()) {
        string name(arr.toString());
        dictionary = getPredefinedDictionary(PredefinedDictionaryMap[name]);
    }
    else if (arr.isStruct()) {
        dictionary.bytesList = arr.at("bytesList").toMat(CV_8U);
        dictionary.markerSize = arr.at("markerSize").toInt();
        dictionary.maxCorrectionBits = arr.at("maxCorrectionBits").toInt();
    }
    else {
        vector<MxArray> args(arr.toVector<MxArray>());
        size_t len = args.size();
        nargchk(len>=1);
        string type(args[0].toString());
        if (type == "Predefined") {
            nargchk(len==2);
            string name(args[1].toString());
            dictionary = getPredefinedDictionary(PredefinedDictionaryMap[name]);
        }
        else if (type == "Custom") {
            nargchk(len>=3 && (len%2)==1);
            int nMarkers = args[1].toInt();
            int markerSize = args[2].toInt();
            Dictionary baseDictionary;
            for (int i=3; i<len; i+=2) {
                string key(args[i].toString());
                if (key == "BaseDictionary")
                    baseDictionary = MxArrayToDictionary(args[i+1]);
                else if (key == "Seed") {
                    //HACK: In order to get deterministic results, we allow to
                    // seed the rand() PRNG used in generateCustomDictionary().
                    // This is fragile because RNG state is tied to C runtime
                    // and how its library is linked.
                    srand(args[i+1].toInt());
                }
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            dictionary = generateCustomDictionary(nMarkers, markerSize,
                baseDictionary);
        }
        else if (type == "Manual") {
            nargchk(len==4);
            Mat bytesList;
            {
                // bytesList(i,:) = getByteListFromBits(bits{i})
                vector<MxArray> bits(args[1].toVector<MxArray>());
                for (vector<MxArray>::const_iterator it = bits.begin(); it != bits.end(); ++it)
                    bytesList.push_back(Dictionary::getByteListFromBits(it->toMat(CV_8U)));
            }
            int markerSize = args[2].toInt();
            int maxcorr = args[3].toInt();
            dictionary = Dictionary(bytesList, markerSize, maxcorr);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized dictionary type %s", type.c_str());
    }
    return dictionary;
}

Board MxArrayToBoard(const MxArray &arr)
{
    Board board;
    if (arr.isStruct()) {
        board.objPoints = MxArrayToVectorVectorPoint3<float>(arr.at("objPoints"));
        board.dictionary = MxArrayToDictionary(arr.at("dictionary"));
        board.ids = arr.at("ids").toVector<int>();
    }
    else {
        vector<MxArray> args(arr.toVector<MxArray>());
        nargchk(args.size() >= 1);
        string type(args[0].toString());
        if (type == "Board")
            board = create_Board(args.begin() + 1, args.end());
        else if (type == "GridBoard")
            board = create_GridBoard(args.begin() + 1, args.end());
        else if (type == "CharucoBoard")
            board = create_CharucoBoard(args.begin() + 1, args.end());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized board type %s", type.c_str());
    }
    return board;
}

MxArray toStruct(const DetectorParameters &params)
{
    const char *fields[] = {"adaptiveThreshWinSizeMin",
        "adaptiveThreshWinSizeMax", "adaptiveThreshWinSizeStep",
        "adaptiveThreshConstant", "minMarkerPerimeterRate",
        "maxMarkerPerimeterRate", "polygonalApproxAccuracyRate",
        "minCornerDistanceRate", "minDistanceToBorder",
        "minMarkerDistanceRate", "doCornerRefinement",
        "cornerRefinementWinSize", "cornerRefinementMaxIterations",
        "cornerRefinementMinAccuracy", "markerBorderBits",
        "perspectiveRemovePixelPerCell",
        "perspectiveRemoveIgnoredMarginPerCell",
        "maxErroneousBitsInBorderRate", "minOtsuStdDev",
        "errorCorrectionRate"};
    MxArray s = MxArray::Struct(fields, 20);
    s.set("adaptiveThreshWinSizeMin", params.adaptiveThreshWinSizeMin);
    s.set("adaptiveThreshWinSizeMax", params.adaptiveThreshWinSizeMax);
    s.set("adaptiveThreshWinSizeStep", params.adaptiveThreshWinSizeStep);
    s.set("adaptiveThreshConstant", params.adaptiveThreshConstant);
    s.set("minMarkerPerimeterRate", params.minMarkerPerimeterRate);
    s.set("maxMarkerPerimeterRate", params.maxMarkerPerimeterRate);
    s.set("polygonalApproxAccuracyRate", params.polygonalApproxAccuracyRate);
    s.set("minCornerDistanceRate", params.minCornerDistanceRate);
    s.set("minDistanceToBorder", params.minDistanceToBorder);
    s.set("minMarkerDistanceRate", params.minMarkerDistanceRate);
    s.set("doCornerRefinement", params.doCornerRefinement);
    s.set("cornerRefinementWinSize", params.cornerRefinementWinSize);
    s.set("cornerRefinementMaxIterations", params.cornerRefinementMaxIterations);
    s.set("cornerRefinementMinAccuracy", params.cornerRefinementMinAccuracy);
    s.set("markerBorderBits", params.markerBorderBits);
    s.set("perspectiveRemovePixelPerCell", params.perspectiveRemovePixelPerCell);
    s.set("perspectiveRemoveIgnoredMarginPerCell",
        params.perspectiveRemoveIgnoredMarginPerCell);
    s.set("maxErroneousBitsInBorderRate", params.maxErroneousBitsInBorderRate);
    s.set("minOtsuStdDev", params.minOtsuStdDev);
    s.set("errorCorrectionRate", params.errorCorrectionRate);
    return s;
}

MxArray toStruct(const Dictionary &dictionary)
{
    const char *fields[] = {"bytesList", "markerSize", "maxCorrectionBits", "bits"};
    MxArray s = MxArray::Struct(fields, 4);
    s.set("bytesList",         dictionary.bytesList);
    s.set("markerSize",        dictionary.markerSize);
    s.set("maxCorrectionBits", dictionary.maxCorrectionBits);
    if (true) {
        vector<Mat> bits;
        for (int i=0; i<dictionary.bytesList.rows; ++i) {
            // bits{i} = getBitsFromByteList(bytesList(i,:))
            // bits{i} is a markerSize-by-markerSize matrix
            bits.push_back(Dictionary::getBitsFromByteList(
                dictionary.bytesList.row(i), dictionary.markerSize));
        }
        s.set("bits", bits);
    }
    return s;
}

MxArray toStruct(const Board &board)
{
    const char *fields[] = {"objPoints", "dictionary", "ids"};
    MxArray s = MxArray::Struct(fields, 3);
    s.set("objPoints",  board.objPoints);
    s.set("dictionary", toStruct(board.dictionary));
    s.set("ids",        board.ids);
    return s;
}

MxArray toStruct(const GridBoard &board)
{
    const char *fields[] = {"objPoints", "dictionary", "ids",
        "gridSize", "markerLength", "markerSeparation"};
    MxArray s = MxArray::Struct(fields, 6);
    s.set("objPoints",        board.objPoints);
    s.set("dictionary",       toStruct(board.dictionary));
    s.set("ids",              board.ids);
    s.set("gridSize",         board.getGridSize());
    s.set("markerLength",     board.getMarkerLength());
    s.set("markerSeparation", board.getMarkerSeparation());
    return s;
}

MxArray toStruct(const CharucoBoard &board)
{
    const char *fields[] = {"objPoints", "dictionary", "ids",
        "chessboardSize", "squareLength", "markerLength",
        "chessboardCorners", "nearestMarkerIdx", "nearestMarkerCorners"};
    MxArray s = MxArray::Struct(fields, 9);
    s.set("objPoints",            board.objPoints);
    s.set("dictionary",           toStruct(board.dictionary));
    s.set("ids",                  board.ids);
    s.set("chessboardSize",       board.getChessboardSize());
    s.set("squareLength",         board.getSquareLength());
    s.set("markerLength",         board.getMarkerLength());
    s.set("chessboardCorners",    board.chessboardCorners);
    s.set("nearestMarkerIdx",     board.nearestMarkerIdx);
    s.set("nearestMarkerCorners", board.nearestMarkerCorners);
    return s;
}


// ==================== XXX ====================

Board create_Board(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    nargchk(std::distance(first, last) == 3);
    Board board;
    board.objPoints = MxArrayToVectorVectorPoint3<float>(*first); ++first;
    board.dictionary = MxArrayToDictionary(*first); ++first;
    board.ids = first->toVector<int>(); ++first;
    return board;
}

GridBoard create_GridBoard(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    nargchk(std::distance(first, last) == 5);
    int markersX = first->toInt(); ++first;
    int markersY = first->toInt(); ++first;
    float markerLength = first->toFloat(); ++first;
    float markerSeparation = first->toFloat(); ++first;
    Dictionary dictionary = MxArrayToDictionary(*first); ++first;
    return GridBoard::create(markersX, markersY,
        markerLength, markerSeparation, dictionary);
}

CharucoBoard create_CharucoBoard(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    nargchk(std::distance(first, last) == 5);
    int squaresX = first->toInt(); ++first;
    int squaresY = first->toInt(); ++first;
    float squareLength = first->toFloat(); ++first;
    float markerLength = first->toFloat(); ++first;
    Dictionary dictionary = MxArrayToDictionary(*first); ++first;
    return CharucoBoard::create(squaresX, squaresY,
        squareLength, markerLength, dictionary);
}
