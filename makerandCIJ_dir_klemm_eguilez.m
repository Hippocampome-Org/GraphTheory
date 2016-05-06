% Random graph construction (Barabasi-Albert routine)
% INPUTS:  N - number of nodes
%          m - the number of nodes in the initial network
%          mu - the probability that a node will be chosen for reconnection 
%          d - the probability that a node pair will have directed edges in both directions
% OUTPUTS: adj - adjacency matrix of generated graph (symmetric)

function adj = makerandCIJ_dir_klemm_eguilez(N, m, mu, d)

    % first create the fully connected initial network, and add its nodes
    % to active nodes
    adj = ones(m) - eye(m);
    active_nodes = 1:m;
    deactivated_nodes = [];

    % Second, iteratively, connect remaining nodes to active nodes or a 
    % random node with probability mu, then remove one active node
    for i=m+1:N
        for j=1:length(active_nodes)
            if (rand <= mu) || isempty(deactivated_nodes)
                adj(i,j) = 1;
                adj(j,i) = 1;
            else
                connected = 0;
                while ~connected
                    j = deactivated_nodes(randi(length(deactivated_nodes)));
                    
                    k = sum((adj(j,:)) + sum(adj(:,j)));
                    E = 0;
                    for d=1:length(deactivated_nodes)
                        E = E + sum((adj(deactivated_nodes(d),:)) + sum(adj(:,deactivated_nodes(d))));
                    end
                    
                    if (rand <= k/E)
                        adj(i,j) = 1;
                        adj(j,i) = 1;
                        connected = 1;
                    end
                end
            end
        end
            
        % Replace an active node with node i. Active nodes with lower 
        % degrees are more likely to be replaced.            
        j_chosen = 0;
        while ~j_chosen
            j = active_nodes(randi(length(active_nodes)));

            k = 1/sum((adj(j,:)) + sum(adj(:,j)));
            E = 0;
            for d=1:length(active_nodes)
                E = E + 1/sum((adj(active_nodes(d),:)) + sum(adj(:,active_nodes(d))));
            end

            pd = k / E;
            if (rand <= pd)
                j_chosen = 1;
                active_nodes(active_nodes==j) = i;
                deactivated_nodes(end+1) = j;
            end
        end
    end
    
    % Third, if directed, use d to set undirected equivalency
    for i=1:N
        for j=1:N
            if adj(i,j) == 1
                if (rand <= d)
                    matchFound = 0;

                    while ~matchFound
                        h = randi(N);
                        if adj(i,h)==0
                            matchFound = 1;
                        end
                    end

                    adj(i,j) = 0;
                    adj(i,h) = 1;
                end
            end
        end
    end

end

