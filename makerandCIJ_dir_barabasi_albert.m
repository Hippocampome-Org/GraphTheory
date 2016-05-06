% Random graph construction (Barabasi-Albert routine)
% INPUTS:  N - number of nodes
%          m0 - the number of nodes in the initial network
%          m - the number of nodes to which each ?new? node is initially
%          connected (m < m0)
%          d - the probability that a node pair will have directed edges in both directions
% OUTPUTS: adj - adjacency matrix of generated graph (symmetric)

function adj = makerandCIJ_dir_barabasi_albert(N, m0, m, d)

    % first create the fully connected initial network
    adj = ones(m0) - eye(m0);
    E = sum(sum(adj==1));

    % second add remaining nodes with a preferential attachment bias
    for i=m0+1:N
        adj(i,i) = 0;
        cur_degree_i = 0;

        while cur_degree_i < m
            cur_degree_i = (sum(adj(i,:)) + sum(adj(:,i)));
            
            matchFound = 0;

            while ~matchFound
                j = randi(i-1);
                if adj(i,j)==0 && adj(j,i)==0
                    matchFound = 1;
                end
            end

            b = (sum(adj(j,:)) + sum(adj(:,j))) / E; % number of nodes adjacent to j / E

            if (rand <= b)
                if (rand <= d)
                    adj(i,j) = 1;
                    adj(j,i) = 1;
                    E = E + 2;
                else
                    adj(i,j) = 1;
                    E = E + 1;

                    matchFound2 = 0;

                    while ~matchFound2
                        h = randi(i-1);
                        if h~=j && adj(h,i)==0
                            matchFound2 = 1;
                        end
                    end

                    b = (sum(adj(h,:)) + sum(adj(:,h))) / E;

                    if (rand <= b)
                        adj(h,i) = 1;
                        E = E + 1;
                    end
                end
            end
        end
    end
end

