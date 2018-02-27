classdef ImgHash < handle
    %IMGHASH  Base class for Image Hashing algorithms
    %
    % This module brings implementations of different image hashing algorithms.
    % It provides algorithms to extract the hash of images and fast way to
    % figure out most similar images in huge data set.
    %
    % ### Supported Algorithms
    %
    % - Average hash (also called Different hash)
    % - PHash (also called Perceptual hash)
    % - Marr Hildreth Hash
    % - Radial Variance Hash
    % - Block Mean Hash (modes 0 and 1)
    % - Color Moment Hash (this is the one and only hash algorithm resist to
    %   rotation attack (-90~90 degree)
    %
    % You can study more about image hashing from the paper and websites
    % listed in the references section.
    %
    % ### Performance under different attacks
    %
    % ![Performance chart](https://docs.opencv.org/3.3.0/attack_performance.JPG)
    %
    % ### Speed comparison with PHash library (100 images from ukbench)
    %
    % ![Hash Computation chart](https://docs.opencv.org/3.3.1/hash_computation_chart.JPG)
    % ![Hash comparison chart](https://docs.opencv.org/3.3.1/hash_comparison_chart.JPG)
    %
    % As you can see, hash computation speed of img_hash module outperform
    % [PHash library](http://www.phash.org/) a lot.
    %
    % PS: I do not list out the comparison of Average hash, PHash and Color
    % Moment hash, because I cannot find them in PHash.
    %
    % ### Motivation
    %
    % Collects useful image hash algorithms into OpenCV, so we do not need to
    % rewrite them by ourselves again and again or rely on another 3rd party
    % library (ex: PHash library). BOVW or correlation matching are good and
    % robust, but they are very slow compare with image hash, if you need to
    % deal with large scale CBIR (content based image retrieval) problem,
    % image hash is a more reasonable solution.
    %
    % ### More info
    %
    % You can learn more about img_hash modules from following links, these
    % links show you how to find similar image from ukbench dataset, provide
    % thorough benchmark of different attacks (contrast, blur, noise
    % (gaussion, pepper and salt), jpeg compression, watermark, resize).
    %
    % * [Introduction to image hash module of OpenCV](http://qtandopencv.blogspot.my/2016/06/introduction-to-image-hash-module-of.html)
    % * [Speed up image hashing of OpenCV (img_hash) and introduce color moment hash](http://qtandopencv.blogspot.my/2016/06/speed-up-image-hashing-of-opencvimghash.html)
    %
    % ### Contributors
    %
    % [Tham Ngap Wei](mailto:thamngapwei@gmail.com)
    %
    % ## References
    % [lookslikeit]:
    % > Neal Krawetz.
    % > [Looks Like It](http://www.hackerfactor.com/blog/?/archives/432-Looks-Like-It.html).
    %
    % [tang2012perceptual]:
    % > Zhenjun Tang, Yumin Dai, Xianquan Zhang. "Perceptual Hashing for Color
    % > Images Using Invariant Moments. Appl. Math, 6(2S):643S-650S, 2012.
    %
    % [zauner2010implementation]:
    % > Christoph Zauner. "Implementation and benchmarking of perceptual image
    % > hash functions". 2010.
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    %% Constructor/destructor
    methods
        function this = ImgHash(alg, varargin)
            %IMGHASH  Constructor
            %
            %     obj = cv.ImgHash(alg)
            %     obj = cv.ImgHash(alg, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __alg__ image hash algorithm, one of:
            %   * __AverageHash__ Computes average hash value of the input
            %     image. This is a fast image hashing algorithm, but only work
            %     on simple case. For more details, please refer to
            %     [lookslikeit].
            %   * __BlockMeanHash__ Image hash based on block mean. See
            %     [zauner2010implementation] for details.
            %   * __ColorMomentHash__ Image hash based on color moments. See
            %     [tang2012perceptual] for details.
            %   * __MarrHildrethHash__ Marr-Hildreth Operator Based Hash,
            %     slowest but more discriminative. See
            %     [zauner2010implementation] for details.
            %   * __PHash__ Slower than average_hash, but tolerant of minor
            %     modifications. This algorithm can combat more variation than
            %     than AverageHash, for more details please refer to
            %     [lookslikeit].
            %   * __RadialVarianceHash__ Image hash based on Radon transform.
            %     See [tang2012perceptual] for details.
            %
            % ## Options
            % The following are options for the various algorithms:
            %
            % ### `BlockMeanHash`
            % * __Mode__ block mean hash mode. default 'Mode0'
            %
            % ### `MarrHildrethHash`
            % * __Alpha__ scale factor for marr wavelet. default 2
            % * __Scale__ level of scale factor. default 1
            %
            % ### `RadialVarianceHash`
            % * __Sigma__ Gaussian kernel standard deviation. default 1
            % * __NumOfAngleLine__ Number of angles to consider. default 180
            %
            % See also: cv.ImgHash.compute, cv.ImgHash.compare
            %
            this.id = ImgHash_(0, 'new', alg, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.ImgHash
            %
            if isempty(this.id), return; end
            ImgHash_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = ImgHash_(this.id, 'typeid');
        end
    end

    %% ImgHashBase
    methods
        function hash = compute(this, img)
            %COMPUTE  Computes hash of the input image
            %
            %     hash = obj.compute(img)
            %
            % ## Input
            % * __img__ input image wanting to compute its hash value.
            %
            % ## Output
            % * __hash__ hash of the image.
            %
            % See also: cv.ImgHash.compare
            %
            hash = ImgHash_(this.id, 'compute', img);
        end

        function val = compare(this, hashOne, hashTwo)
            %COMPARE  Compare two hash values
            %
            %     val = obj.compare(hashOne, hashTwo)
            %
            % ## Input
            % * __hashOne__ Hash value one.
            % * __hashTwo__ Hash value two.
            %
            % ## Output
            % * __val__ indicate similarity between the two hashes, the
            %   meaning of the value vary from algorithm to algorithm.
            %
            % See also: cv.ImgHash.compute
            %
            val = ImgHash_(this.id, 'compare', hashOne, hashTwo);
        end
    end

    %% Util functions
    methods (Static)
        function hash = averageHash(img)
            %AVERAGEHASH  Calculates the average hash in one call
            %
            %     hash = cv.ImgHash.averageHash(img)
            %
            % ## Input
            % * __img__ input image want to compute hash value, type should be
            %   `uint8` with 1/3/4 channels.
            %
            % ## Output
            % * __hash__ Hash value of input, it will contain 16 hex decimal
            %   number, return type is `uint8`
            %
            % See also: cv.ImgHash.ImgHash, cv.ImgHash.compute
            %
            hash = ImgHash_(0, 'averageHash', img);
        end

        function hash = blockMeanHash(img, varargin)
            %BLOCKMEANHASH  Computes block mean hash of the input image
            %
            %     hash = cv.ImgHash.blockMeanHash(img)
            %     hash = cv.ImgHash.blockMeanHash(img, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ input image want to compute hash value, type should be
            %   `uint8` with 1/3/4 channels.
            %
            % ## Output
            % * __hash__ Hash value of input, it will contain 16 hex decimal
            %   number, return type is `uint8`.
            %
            % ## Options
            % * __Mode__ block mean hash mode, one of:
            %   * __Mode0__ (default) use fewer blocks and generates 16*16/8
            %     `uint8` hash values.
            %   * __Mode1__ use block blocks (step_sizes/2) and generates
            %     `fix(31*31/8)+1` `uint8` hash values.
            %
            % See also: cv.ImgHash.ImgHash, cv.ImgHash.compute
            %
            hash = ImgHash_(0, 'blockMeanHash', img, varargin{:});
        end

        function hash = colorMomentHash(img)
            %COLORMOMENTHASH   Computes color moment hash of the input
            %
            %     hash = cv.ImgHash.colorMomentHash(img)
            %
            % ## Input
            % * __img__ input image want to compute hash value, type should be
            %   `uint8` with 1/3/4 channels.
            %
            % ## Output
            % * __hash__ 42 hash values with type `double`.
            %
            % The algorithm comes from the paper [tang2012perceptual].
            %
            % See also: cv.ImgHash.ImgHash, cv.ImgHash.compute
            %
            hash = ImgHash_(0, 'colorMomentHash', img);
        end

        function hash = marrHildrethHash(img, varargin)
            %MARRHILDRETHHASH  Computes average hash value of the input image
            %
            %     hash = cv.ImgHash.marrHildrethHash(img)
            %     hash = cv.ImgHash.marrHildrethHash(img, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ input image want to compute hash value, type should be
            %   `uint8` with 1/3/4 channels.
            %
            % ## Output
            % * __hash__ Hash value of input, it will contain 16 hex decimal
            %   number, return type is `uint8`.
            %
            % ## Options
            % * __Alpha__ scale factor for marr wavelet. default 2
            % * __Scale__ level of scale factor. default 1
            %
            % See also: cv.ImgHash.ImgHash, cv.ImgHash.compute
            %
            hash = ImgHash_(0, 'marrHildrethHash', img, varargin{:});
        end

        function hash = pHash(img)
            %PHASH  Computes pHash value of the input image
            %
            %     hash = cv.ImgHash.pHash(img)
            %
            % ## Input
            % * __img__ input image want to compute hash value, type should be
            %   `uint8` with 1/3/4 channels.
            %
            % ## Output
            % * __hash__ Hash value of input, it will contain 8 `uint8` values.
            %
            % See also: cv.ImgHash.ImgHash, cv.ImgHash.compute
            %
            hash = ImgHash_(0, 'pHash', img);
        end

        function hash = radialVarianceHash(img, varargin)
            %RADIALVARIANCEHASH  Computes radial variance hash of the input image
            %
            %     hash = cv.ImgHash.radialVarianceHash(img)
            %     hash = cv.ImgHash.radialVarianceHash(img, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ input image want to compute hash value, type should be
            %   `uint8`, with 1/3/4 channels.
            %
            % ## Output
            % * __hash__ Hash value of input, contains 40 `uint8` values.
            %
            % ## Options
            % * __Sigma__ Gaussian kernel standard deviation. default 1
            % * __NumOfAngleLine__ The number of angles to consider.
            %   default 180
            %
            % See also: cv.ImgHash.ImgHash, cv.ImgHash.compute
            %
            hash = ImgHash_(0, 'radialVarianceHash', img, varargin{:});
        end
    end

end
