classdef TestDescriptorMatcher
    %TestDescriptorMatcher
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            X = randn(50,3);
            Y = randn(10,3);
            matchers = [...
                cv.DescriptorMatcher('BruteForce'),...
                cv.DescriptorMatcher('BruteForce-L1'),...
                cv.DescriptorMatcher('FlannBased'),...
                cv.DescriptorMatcher('FlannBased',...
                    'Index',  {'KDTree','Trees',4},...
                    'Search', {'Checks',32,'EPS',0,'Sorted',true}...
                    )...
                ];
            for i = 1:numel(matchers)
                matchers(i).add(X);
                matchers(i).train();
                matchers(i).match(Y);
                matchers(i).knnMatch(Y,3);
                matchers(i).radiusMatch(Y,0.1);
            end
        end
        
        function test_2
            X = uint8(255*rand(50,3));
            Y = uint8(255*rand(10,3));
            matchers = [...
                cv.DescriptorMatcher('BruteForce-Hamming'),...
                cv.DescriptorMatcher('BruteForce-HammingLUT')...
                ];
            for i = 1:numel(matchers)
                matchers(i).add(X);
                matchers(i).train();
                matchers(i).match(Y);
                matchers(i).knnMatch(Y,3);
                matchers(i).radiusMatch(Y,0.1);
            end
        end
    end
    
end

