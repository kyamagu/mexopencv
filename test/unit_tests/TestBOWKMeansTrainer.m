classdef TestBOWKMeansTrainer
    %TestBOWKMeansTrainer

    methods (Static)
        function test_1
            K = 5;
            trainer = cv.BOWKMeansTrainer(K);
            desc = randn(100,4);
            centers = trainer.cluster(desc);
            validateattributes(centers, {'numeric'}, {'size',[K 4]});
        end

        function test_2
            K = 2;    % number of clusters
            trainer = cv.BOWKMeansTrainer(K);

            dim = 3;  % dimensionality
            N = [];   % number of samples added
            for i=1:5
                desc = [randn(50,dim)-1; randn(50,dim)+1];
                trainer.add(desc);
                N(end+1) = size(desc,1);
            end

            assert(trainer.descriptorsCount() == sum(N));

            descs = trainer.getDescriptors();
            validateattributes(descs, {'cell'}, {'vector', 'numel',numel(N)});
            cellfun(@(x,n) validateattributes(x, {'numeric'}, ...
                {'size',[n dim]}), descs, num2cell(N));

            centers = trainer.cluster();
            validateattributes(centers, {'numeric'}, {'size',[K dim]});

            trainer.clear();
            assert(trainer.descriptorsCount() == 0);
            assert(isempty(trainer.getDescriptors()));
        end
    end

end
