classdef MOSSETracker < handle
    %MOSSETRACKER  MOSSE filter based tracker
    %
    % Correlation filter based tracking using MOSSE filters
    % (Minimum Output Sum of Squared Error), described in [Bolme2010].
    %
    % The target object appearance is modeled using adaptive correlation
    % filters, and tracking is performed via convolution.
    %
    % The filters are learnt online in an adaptive manner for visual tracking.
    %
    % ## Sources:
    %
    % * https://github.com/opencv/opencv/blob/3.3.1/samples/python/mosse.py
    %
    % ## References
    % [Bolme2010]:
    % > David S. Bolme et al.
    % > "Visual Object Tracking using Adaptive Correlation Filters"
    % > [PDF](http://www.cs.colostate.edu/~draper/papers/bolme_cvpr10.pdf)
    %

    properties
        % criteria for successful tracking, psr > min_psr
        % A value between [20,60] indicates very strong peaks,
        % less than 7 indicates bad track quality.
        min_psr = 8.0;
    end

    properties (Access = private)
        % Hanning window used when preprocessing images
        win
        % Fourier transform of 2D Gaussian shaped peak centered on target
        G
        % correlation filters/kernels
        H1
        H2
        H
        % last image of target
        last_img
        % last correlation response
        last_resp
    end

    properties (SetAccess = private)
        % center [x,y] of tracked object rectangle
        pos
        % size [w,h] of tracked object rectangle
        siz
        % Peak-to-Sidelobe Ratio (PSR)
        psr
    end

    properties (Dependent, SetAccess = private)
        % tracked object position, as a `[x y w h]` rectangle
        bbox
    end

    methods
        function obj = MOSSETracker(frame, rect)
            %MOSSETRACKER  Constructor
            %
            %     obj = MOSSETracker(frame, rect)
            %
            % ## Input
            % * __frame__ first frame with target to track
            % * __rect__ rectangle around target object `[x,y,w,h]`
            %

            % center and size of object rectangle (after DFT optimal padding)
            obj.siz = arrayfun(@(s) cv.getOptimalDFTSize(s), rect(3:4));
            obj.pos = floor((2*rect(1:2) + rect(3:4) - obj.siz) / 2);
            obj.pos = obj.pos + 0.5 * (obj.siz - 1);

            % create Hanning window of same size as rect
            obj.win = cv.createHanningWindow(obj.siz, 'Type','single');

            % create Gaussian shaped peak, centered and of same size as rect
            % (Kronecker delta with 1 at target center, 0 elsewhere)
            g = zeros(obj.siz(2), obj.siz(1), 'single');
            g(floor(end/2),floor(end/2)) = 1;
            g = cv.GaussianBlur(g, 'KSize',[-1 -1], 'SigmaX',2.0);
            g = g / max(g(:));

            % initialize correlation filters
            obj.G = cv.dft(g, 'ComplexOutput',true);
            obj.H1 = zeros(size(obj.G), class(obj.G));
            obj.H2 = zeros(size(obj.G), class(obj.G));

            % train filters on a bunch of augmented images
            % by applying small random affine perturbations
            img = cv.getRectSubPix(frame, obj.siz, obj.pos);
            for i=1:128
                a = obj.preprocess(random_warp(img));
                obj.update_kernels(a);
            end

            % process first frame
            obj.update(frame);
        end

        function update(obj, frame, rate)
            %UPDATE  Track object in new frame and update filters
            %
            %     obj.update(frame)
            %     obj.update(frame, rate)
            %
            % ## Input
            % * __frame__ new frame in which to track object
            % * __rate__ learning rate in [0,1] range, default 0.125
            %

            % crop and process image from current position
            obj.last_img = cv.getRectSubPix(frame, obj.siz, obj.pos);
            img = obj.preprocess(obj.last_img);

            % track target by correlating filter over image
            [obj.last_resp, d, obj.psr] = obj.correlate(img);

            % check that response peack is strong enough (using PSR)
            if obj.psr <= obj.min_psr
                return;
            end

            % update object position
            obj.pos = obj.pos + d;

            % crop and process image from new position
            obj.last_img = cv.getRectSubPix(frame, obj.siz, obj.pos);
            img = obj.preprocess(obj.last_img);

            % online update (filter training)
            if nargin < 3, rate = 0.125; end
            obj.update_kernels(img, rate);
        end

        function [img, f, resp] = visualize_state(obj)
            %VISUALIZE_STATE  Visualize tracker state
            %
            %     [img, f, resp] = obj.visualize_state()
            %
            % ## Output
            % * __img__ cropped object image
            % * __f__ correlation filter, 0-freq centered and 8-bit normalized
            % * __resp__ correlation response, 8-bit normalized and clipped
            %

            % image
            img = obj.last_img;

            % kernel
            f = cv.dft(obj.H, 'Inverse',true, 'Scale',true, 'RealOutput',true);
            f = circshift(f, floor(-[size(f,1) size(f,2)]/2));
            if true
                f = (f - min(f(:))) / (max(f(:)) - min(f(:)));
            else
                f = cv.normalize(f, 'NormType','MinMax');
            end
            f = uint8(255 * f);

            % response
            if true
                resp = obj.last_resp / max(obj.last_resp(:));
            else
                resp = cv.normalize(obj.last_resp, 'NormType','Inf');
            end
            resp = uint8(255 * min(max(resp, 0), 1));
        end

        function vis = draw_object(obj, vis)
            %DRAW_OBJECT  Draw current location of tracked object
            %
            %     vis = obj.draw_object(vis)
            %
            % ## Input
            % * __vis__ input image
            %
            % ## Output
            % * __vis__ output image with drawn object
            %

            clr = {'Color',[0 0 255]};
            p1 = fix(obj.pos - 0.5 * obj.siz);
            p2 = fix(obj.pos + 0.5 * obj.siz);

            % draw location
            vis = cv.rectangle(vis, p1, p2, 'Thickness',2, clr{:});
            if obj.psr > obj.min_psr
                % good track, draw center
                vis = cv.circle(vis, fix(obj.pos), 2, 'Thickness',-1, clr{:});
            else
                % bad track, draw cross
                vis = cv.line(vis, [p1; p2(1) p1(2)], [p2; p1(1) p2(2)], clr{:});
            end

            % draw PSR value
            vis = cv.putText(vis, sprintf('PSR: %.2f', obj.psr), ...
                [p1(1) p2(2)+16], 'FontFace','HersheyPlain', ...
                'Thickness',2, 'LineType','AA', clr{:});
        end

        function bbox = get.bbox(obj)
            p1 = obj.pos - 0.5 * obj.siz;
            p2 = obj.pos + 0.5 * obj.siz;
            bbox = cv.Rect.from2points(p1, p2);
        end
    end

    methods (Access = private)
        function img = preprocess(obj, img)
            %PREPROCESS  Process input frame
            %
            %     img = obj.preprocess(img)
            %
            % ## Input
            % * __img__ input image
            %
            % ## Output
            % * __img__ output processed image
            %

            % log transform, normalize, and multiply by Hanning window
            img = log(single(img) + 1);
            if true
                img = img / norm(img(:));
            elseif true
                img = cv.normalize(img, 'NormType','L2');
            else
                img = (img - mean(img(:))) / std(img(:));
            end
            img = img .* obj.win;
        end

        function [resp, d, psr] = correlate(obj, img)
            %CORRELATE  Correlate filter over image and find peak in response
            %
            %     [resp, d, psr] = obj.correlate(img)
            %
            % ## Input
            % * __img__ processed image
            %
            % ## Output
            % * __resp__ correlation response
            % * __d__ offset of peak location from center `[x,y]`
            % * __psr__ PSR value, a measure of correlation peak strength. Can
            %   be used to stop the online update if PSR is too low, which is
            %   an indication the the object is occluded or tracking has
            %   failed.
            %

            % correlation (performed in frequency domain)
            resp = cv.mulSpectrums(cv.dft(img, 'ComplexOutput',true), ...
                obj.H, 'ConjB',true);
            resp = cv.dft(resp, 'Inverse',true, 'Scale',true, 'RealOutput',true);

            % max value location in correlation response
            [mval, midx] = max(resp(:));
            [my,mx] = ind2sub(size(resp), midx);
            mloc = [mx my]; %TODO: -1 ??

            % offset from center
            d = mloc - floor([size(resp,2) size(resp,1)] / 2);

            % compute PSR
            sidelobe = cv.rectangle(resp, mloc-5, mloc+5, ...
                'Color',NaN, 'Thickness',-1);
            sidelobe = sidelobe(~isnan(sidelobe));
            psr = (mval - mean(sidelobe)) / std(sidelobe);
        end

        function update_kernels(obj, img, rate)
            %UPDATE_KERNELS  Update correlation kernels
            %
            %     obj.update_kernels(img)
            %     obj.update_kernels(img, rate)
            %
            % ## Input
            % * __img__ processed image
            % * __rate__ learning rate
            %

            F = cv.dft(img, 'ComplexOutput',true);
            H_1 = cv.mulSpectrums(obj.G, F, 'ConjB',true);
            H_2 = cv.mulSpectrums(    F, F, 'ConjB',true);

            if nargin < 3
                % initialization phase
                obj.H1 = obj.H1 + H_1;
                obj.H2 = obj.H2 + H_2;
            else
                % update phase
                obj.H1 = obj.H1 * (1 - rate) + H_1 * rate;
                obj.H2 = obj.H2 * (1 - rate) + H_2 * rate;
            end

            obj.H = complex(obj.H1(:,:,1), obj.H1(:,:,2)) ./ ...
                    complex(obj.H2(:,:,1), obj.H2(:,:,2));
            obj.H = cat(3, real(obj.H), -imag(obj.H));
        end
    end
end

function img = random_warp(img, coef)
    %RANDOM_WARP  Warp image using a random affine transformation
    %
    %     img = random_warp(img)
    %     img = random_warp(img, coef)
    %
    % ## Input
    % * __img__ input image
    %
    % ## Output
    % * __img__ output warped image
    % * __coef__ randomness coefficient, default 0.2
    %

    if nargin < 2, coef = 0.2; end
    ang = (rand() - 0.5) * coef;
    T = [cos(ang) -sin(ang); sin(ang) cos(ang)];
    T = T + (rand(2) - 0.5) * coef;

    sz = [size(img,2); size(img,1)];
    c = fix(sz / 2);
    T(:,3) = c - T * c;

    img = cv.warpAffine(img, T, 'DSize',sz, 'BorderType','Reflect');
end
