function [totalTrimerCounts, bigTrimerCollection] = ID_and_locate_struct_motif_patterns_3(Cij, trackTrimerCollection)
    build_motif_lib_2_selfless_from_superpattern_perm();
    load motif_lib_3_selfless_EorI motif3selflessIDs motif3selflessConnectionPats
    
    totalNodes = size(Cij,1);
    rowSums = sum(Cij,2);
    EorIvector = rowSums>0;
    
    numMotifClasses = max(motif3selflessIDs(:,3));
    totalTrimerCounts = zeros(numMotifClasses,1);
    
    bigTrimerCollection = cell(numMotifClasses,1);
    if trackTrimerCollection        
        for i = 1:numMotifClasses
            bigTrimerCollection{i} = zeros(1,3);
        end
    end
        
    for nodeA = 1:totalNodes
        for nodeB = nodeA+1:totalNodes
            for nodeC = nodeB+1:totalNodes
                %current_nodes = [nodeA nodeB nodeC];
                
                excitA = EorIvector(nodeA);
                A2B = Cij(nodeA,nodeB);
                A2C = Cij(nodeA,nodeC);
                
                excitB = EorIvector(nodeB);
                B2A = Cij(nodeB,nodeA);
                B2C = Cij(nodeB,nodeC);
                
                excitC = EorIvector(nodeC);
                C2A = Cij(nodeC,nodeA);
                C2B = Cij(nodeC,nodeB);

                miniConnectionMatrixABC = [excitA A2B A2C excitB B2A B2C excitC C2A C2B];
                indx = ismember(motif3selflessConnectionPats, miniConnectionMatrixABC, 'rows');
                motifClassNum = motif3selflessIDs(indx,3);

                totalTrimerCounts(motifClassNum) = totalTrimerCounts(motifClassNum) + 1;
                if trackTrimerCollection
                    bigTrimerCollection{motifClassNum}(totalTrimerCounts(motifClassNum),1:3) = [nodeA nodeB nodeC];
                end
    
            end % for nodeC
        end % for nodeB
    end % for nodeA
    
    if trackTrimerCollection
        for i = 1:numMotifClasses
            if isequal(bigTrimerCollection{i}(1,1:3), [0 0 0])
                bigTrimerCollection{i} = NaN;
            end
        end
    end
end