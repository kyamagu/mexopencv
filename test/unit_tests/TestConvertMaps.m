classdef TestConvertMaps
    %TestConvertMaps

    methods (Static)
        function test_conversion
            r = 100; c = 200;
            [Y,X] = ndgrid(single(1:r)-1, single(1:c)-1);  % 0-based indices

            [XX,YY] = cv.convertMaps(X, Y);
            [XX2,YY2] = cv.convertMaps(cat(3,X,Y));
            assert(isequal(XX,XX2) && isequal(YY,YY2));
            validateattributes(XX, {'int16'}, {'size',[r c 2]});
            validateattributes(YY, {'uint16'}, {'size',[r c]});

            XY = cv.convertMaps(XX, YY);      %TODO: contains NaN?
            %assert(isequal(XY, cat(3,X,Y)));
            validateattributes(XY, {'single'}, {'size',[r c 2]});

            [X2,Y2] = cv.convertMaps(XX, YY, 'DstMap1Type','single1');
            assert(isequal(X2,X) && isequal(Y2,Y));
            validateattributes(X, {'single'}, {'size',[r c]});
            validateattributes(Y, {'single'}, {'size',[r c]});
        end

        function test_merge_split
            r = 100; c = 200;
            [Y,X] = ndgrid(single(1:r)-1, single(1:c)-1);  % 0-based indices

            XY = cv.convertMaps(X, Y, 'DstMap1Type','single2');
            assert(isequal(XY, cat(3,X,Y)));
            validateattributes(XY, {'single'}, {'size',[r c 2]});

            [XX,YY] = cv.convertMaps(XY, 'DstMap1Type','single1');
            assert(isequal(XX,X) && isequal(YY,Y));
            validateattributes(XX, {'single'}, {'size',[r c]});
            validateattributes(YY, {'single'}, {'size',[r c]});
        end

        function test_copy
            r = 100; c = 200;
            [Y,X] = ndgrid(single(1:r)-1, single(1:c)-1);  % 0-based indices

            [XX,YY] = cv.convertMaps(X, Y, 'DstMap1Type','single1');
            assert(isequal(XX,X) && isequal(YY,Y));
            validateattributes(XX, {'single'}, {'size',[r c]});
            validateattributes(YY, {'single'}, {'size',[r c]});

            XY = cv.convertMaps(cat(3,X,Y), 'DstMap1Type','single2');
            assert(isequal(XY,cat(3,X,Y)));
            validateattributes(XY, {'single'}, {'size',[r c 2]});

            [XX,YY] = cv.convertMaps(X, Y);
            [XX2,YY2] = cv.convertMaps(XX, YY, 'DstMap1Type','int16');
            assert(isequal(XX,XX2) && isequal(YY,YY2));
            validateattributes(XX, {'int16'}, {'size',[r c 2]});
            validateattributes(YY, {'uint16'}, {'size',[r c]});
        end

        function test_error_1
            try
                cv.convertMaps();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
