classdef TestExposureCompensator
    %TestExposureCompensator

    methods (Static)
        function test_1
            etypes = {'GainCompensator', 'BlocksGainCompensator'};
            for i=1:numel(etypes)
                obj = cv.ExposureCompensator(etypes{i});
                typename = obj.typeid();
                validateattributes(typename, {'char'}, {'row', 'nonempty'});

                %{
                %TODO
                obj.feed(corners, images, masks);
                img = obj.apply(index, corner, img, mask);
                if strcmp(etypes{i}, 'GainCompensator')
                    g = obj.gains();
                end
                %}
            end
        end
    end

end
