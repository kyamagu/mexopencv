%CALCOPTICALFLOWSF  Calculate an optical flow using “SimpleFlow” algorithm.

%    flow = cv.calcOpticalFlowSF(prevImg, nextImg, layers, ...
%                                  averaging_block_size, max_flow)
%    flow = cv.calcOpticalFlowSF(prevImg, nextImg, layers, ...
%                                  averaging_block_size, max_flow, ...
%                                  sigma_dist, sigma_color, ...
%                                  postprocess_window, sigma_dist_fix, ...
%                                  sigma_color_fix, occ_thr, ...
%                                  upscale_averaging_radius, ...
%                                  upscale_sigma_dist, ...
%                                  upscale_sigma_color, speed_up_thr);
% ## Input
% * __prevImg__ First 8-bit single-channel input image.
% * __nextImg__ Second input image of the same size and the same type as prevImg.
% * __layers__ Number of layers
% * __averaging_block_size__ Size of block through which we sum up when calculate cost function for pixel
% * __max_flow__ maximal flow that we search at each level
% 
% ## Additional parameters (must specify all if used)
% * __sigma_dist__ vector smooth spatial sigma parameter
% * __sigma_color__ vector smooth color sigma parameter
% * __postprocess_window__ window size for postprocess cross bilateral filter
% * __sigma_dist_fix__ spatial sigma for postprocess cross bilateralf filter
% * __sigma_color_fix__ color sigma for postprocess cross bilateral filter
% * __occ_thr__ threshold for detecting occlusions
% * __upscale_averaging_radius__ window size for bilateral upscale operation
% * __upscale_sigma_dist__ spatial sigma for bilateral upscale operation
% * __upscale_sigma_color__ color sigma for bilateral upscale operation
% * __speed_up_thr__ threshold to detect point with irregular flow - where flow should be recalculated after upscale
%
% ## Output
% * __flow__ Computed flow image that has the same size as prevImg and single
%         type. flow for (x,y) is stored in the third dimension.
%
%
% See also cv.calcOpticalFlowPyrLK, cv.calcOpticalFlowFarneback
%
