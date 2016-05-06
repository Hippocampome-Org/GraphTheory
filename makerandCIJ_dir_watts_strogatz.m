% Random graph construction (Watts-Strogatz routine)
% INPUTS:  N - number of nodes
%          k - number of edges
%          p - the probability that a rewire will occur 
%          d - the probability that a node pair will have directed edges in both directions
% OUTPUTS: adj - adjacency matrix of generated graph (symmetric)

function adj = makerandCIJ_dir_watts_strogatz(N, k, p, d)

    adj=zeros(N); % initialize adjacency matrix

    % create ring lattice
    for i=1:N
        for j=i+1:i+k/N/2 % make sure loop connects around to the beginning
            if j>N
                j = j - N; %#ok<FXSET>
            end
            
            adj(i,j) = 1;
            adj(j,i) = 1;
        end
    end

    % rewire edges randomly with probability p
    for i=1:N
        for l=i+1:i+k/N/2
            if l>N % make sure loop connects around to the beginning
                l = l - N; %#ok<FXSET>
            end
            
            % disconnect node i and node l
            if (rand <= p)
                matchFound = 0;
                
                while ~matchFound
                    m = randi(N);
                    if adj(i,m)==0 && adj(m,i)==0% && m~=i
                        matchFound = 1;
                    end
                end
                
                % disconnect nodes i and l in both directions
                adj(i,l) = 0;
                adj(l,i) = 0;
                
                if (rand <= d) % create a bidirectional edge
                    adj(i,m) = 1;
                    adj(m,i) = 1;
                else % create 2 uni-directional edges
                    adj(i,m) = 1;
                    
                    matchFound2 = 0;
                
                    while ~matchFound2
                        h = randi(N);
                        if adj(h,i)==0% && h~=i
                            matchFound2 = 1;
                        end
                    end
                    
                    adj(h,i) = 1;
                end
            end
        end
    end
end

