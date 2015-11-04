%% High Dynamic Range Imaging
%
% <http://docs.opencv.org/3.0.0/d3/db7/tutorial_hdr_imaging.html>
% <https://github.com/Itseez/opencv/blob/3.0.0/samples/cpp/tutorial_code/photo/hdr_imaging/hdr_imaging.cpp>
%

%% Introduction
% Today most digital images and imaging devices use 8 bits per channel thus
% limiting the dynamic range of the device to two orders of magnitude
% (actually 256 levels), while human eye can adapt to lighting conditions
% varying by ten orders of magnitude. When we take photographs of a real world
% scene bright regions may be overexposed, while the dark ones may be
% underexposed, so we can't capture all details using a single exposure. HDR
% imaging works with images that use more that 8 bits per channel (usually
% 32-bit float values), allowing much wider dynamic range.
%
% There are different ways to obtain HDR images, but the most common one is to
% use photographs of the scene taken with different exposure values. To
% combine this exposures it is useful to know your camera's response function
% and there are algorithms to estimate it. After the HDR image has been
% blended it has to be converted back to 8-bit to view it on usual displays.
% This process is called tonemapping. Additional complexities arise when
% objects of the scene or camera move between shots, since images with
% different exposures should be registered and aligned.
%
% In this tutorial we show how to generate and display HDR image from an
% exposure sequence. In our case images are already aligned and there are no
% moving objects. We also demonstrate an alternative approach called exposure
% fusion that produces low dynamic range image. Each step of HDR pipeline can
% be implemented using different algorithms so take a look at the reference
% manual to see them all.
%

%% Load images and exposure times
% Firstly we load input images and exposure times from user-defined folder.
% The folder should contain images and memorial.txt - file that contains
% file names and inverse exposure times.
use_memorial = true;
if use_memorial
    % samples from OpenCV
    fpath = fullfile(mexopencv.root(),'test');
    files = dir(fullfile(fpath,'memorial*.png'));
else
    % samples from Image Processing Toolbox
    fpath = fileparts(which('office_1.jpg'));
    files = dir(fullfile(fpath,'office_*.jpg'));
end
if isempty(files), error('Failed to find images'); end
files = cellfun(@(f) fullfile(fpath,f), sort({files.name}), 'Uniform',false);

images = cell(size(files));
times = zeros(size(files));
for i=1:numel(files)
    % read image
    images{i} = imread(files{i});

    if ~use_memorial
        % read exposure times from EXIF tags
        info = imfinfo(files{i});
        times(i) = info.DigitalCamera.ExposureTime;
        %info.DigitalCamera.FNumber;    % same f-stop number
    end
end

if use_memorial
    % read exposure times stored in a text file
    fid = fopen(fullfile(fpath,'memorial.txt'),'rt');
    C = textscan(fid, '%s %f');
    fclose(fid);
    [~,ord] = sort(C{1});
    times = C{2}(ord);
    times = 1 ./ times;
end

montage(cat(4,images{:}))

%% Estimate camera response
% It is necessary to know camera response function (CRF) for a lot of HDR
% construction algorithms. We use one of the calibration algorithms to
% estimate inverse CRF for all 256 pixel values.
calibrate = cv.CalibrateDebevec();
response = calibrate.process(images, times);

%% Make HDR image
% We use Debevec's weighting scheme to construct HDR image using response
% calculated in the previous item.
merge = cv.MergeDebevec();
hdr = merge.process(images, times, response);

%% Tonemap HDR image
% Since we want to see our results on common LDR display we have to map our
% HDR image to 8-bit range preserving most details. It is the main goal of
% tonemapping methods. We use tonemapper with bilateral filtering and set
% 2.2 as the value for gamma correction.
tone = cv.TonemapDurand('Gamma',2.2);
%tone = cv.TonemapReinhard('Gamma',2.2, ...
%    'Intensity',-8, 'LightAdaptation',0.6, 'ColorAdaptation',0.5);
ldr = tone.process(hdr);
imshow(ldr)

%% Perform exposure fusion
% There is an alternative way to merge our exposures in case when we don't
% need HDR image. This process is called exposure fusion and produces LDR
% image that doesn't require gamma correction. It also doesn't use exposure
% values of the photographs.
fuse = cv.MergeMertens();
fusion = fuse.process(images);
imshow(fusion)

%% Write results
% Now it's time to look at the results. Note that HDR image can't be stored
% in one of common image formats, so we save it to Radiance image (.hdr).
% Also all HDR imaging functions return results in [0,1] range so we should
% multiply result by 255.
if false
    cv.imwrite('fusion.png', uint8(fusion*255));
    cv.imwrite('ldr.png', uint8(ldr*255));
    cv.imwrite('hdr.hdr', hdr);
end

%% Compare against MATLAB's implementation
%hdr2 = hdrread(which('office.hdr'));
%hdr2 = makehdr(files, 'RelativeExposure',times./times(1));
hdr2 = makehdr(files, 'ExposureValues',times);
ldr2 = tonemap(hdr2);
imshow(ldr2)
