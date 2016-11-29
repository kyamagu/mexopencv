classdef TestDictionaryDump
    %TestDictionaryDump

    methods (Static)
        function test_dict_predefined_string
            d = cv.dictionaryDump('6x6_250');
            validateattributes(d, {'struct'}, {'scalar'});
            validateattributes(d.bytesList, {'uint8'}, {'size',[250 nan nan]});
            validateattributes(d.maxCorrectionBits, {'numeric'}, ...
                {'integer', 'positive'});
            assert(isequal(d.markerSize, 6));
            validateattributes(d.bits, {'cell'}, {'vector', 'numel',250});
            cellfun(@(b) validateattributes(b, {'uint8'}, ...
                {'binary', 'size',[6 6]}), d.bits);
        end

        function test_dict_predefined_string_all
            for ms=4:7
                for len=[50 100 250 1000]
                    d = cv.dictionaryDump(sprintf('%dx%d_%d', ms, ms, len));
                    assert(isequal(d.markerSize, ms));
                    assert(isequal(size(d.bytesList,1), len));
                end
            end
        end

        function test_dict_predefined
            d1 = cv.dictionaryDump('6x6_250');
            d2 = cv.dictionaryDump({'Predefined', '6x6_250'});
            assert(isequal(d1,d2));
        end

        function test_dict_predefined_struct
            d1 = cv.dictionaryDump('6x6_250');
            d2 = cv.dictionaryDump(rmfield(d1,'bits'));
            assert(isequal(d1,d2));
        end

        function test_dict_custom_struct
            d1 = cv.dictionaryDump({'Custom', 10, 6, 'Seed',123});
            d2 = cv.dictionaryDump(rmfield(d1,'bits'));
            assert(isequal(d1,d2));
        end

        function test_dict_manual_struct
            bits = squeeze(num2cell(randi([0 1], [6 6 50], 'uint8'), [1 2]));
            d1 = cv.dictionaryDump({'Manual', bits, 6, 5});
            d2 = cv.dictionaryDump(rmfield(d1,'bits'));
            assert(isequal(d1,d2));
        end

        function test_dict_custom_deterministic
            d1 = cv.dictionaryDump({'Custom', 10, 6, 'Seed',123});
            d2 = cv.dictionaryDump({'Custom', 10, 6, 'Seed',123});
            assert(isequal(d1,d2));
        end

        function test_dict_manual
            bits = squeeze(num2cell(randi([0 1], [6 6 50], 'uint8'), [1 2]));
            d = cv.dictionaryDump({'Manual', bits, 6, 5});
            validateattributes(d, {'struct'}, {'scalar'});
            validateattributes(d.bytesList, {'uint8'}, {'size',[50 nan nan]});
            assert(isequal(d.markerSize, 6));
            assert(isequal(d.bits(:), bits(:)));
        end

        function test_dict_predefined_manual
            d1 = cv.dictionaryDump('6x6_250');
            d2 = cv.dictionaryDump(...
                {'Manual', d1.bits, d1.markerSize, d1.maxCorrectionBits});
            assert(isequal(d1,d2));
        end

        function test_error_argnum
            try
                cv.dictionaryDump();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
