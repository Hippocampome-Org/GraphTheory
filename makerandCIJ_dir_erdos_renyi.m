% Random graph construction (Erdos-Renyi routine)
% INPUTS:  N - number of nodes
%          p - probability, 0<=p<=1, for all other inputs, p is not considered
%          avgInDeg - average in-degree to match
%          avgOutDeg - average out-degree to match
% OUTPUTS: adj - adjacency matrix of generated graph (symmetric)

function adj = makerandCIJ_dir_erdos_renyi(N, p, avgInDeg, avgOutDeg)

    adj=zeros(N); % initialize adjacency matrix
    tempMeanIn = 0;
    tempMeanOut = 0;

    while (tempMeanIn <= avgInDeg) && (tempMeanOut <= avgOutDeg)                
        for i=1:N
            for j=1:N
                if (rand <= p) && (tempMeanIn <= avgInDeg) && (tempMeanOut <= avgOutDeg)
                    adj(i,j)=1;
                    [id,od] = degrees_dir(adj);
                    tempMeanIn = mean(id);
                    tempMeanOut = mean(od);
                end
            end
        end
    end

end

