function [totalDimerCounts, bigDimerCollection] = ID_and_locate_struct_motif_patterns_2(Cij, trackDimerCollection)
    build_motif_lib_2_selfless_from_superpattern_perm();
    load motif_lib_2_selfless_EorI motif2selflessIDs motif2selflessConnectionPats
    
    totalNodes = size(Cij,1);    
    rowSums = sum(Cij,2);
    EorIvector = rowSums>0;
    
    numMotifClasses = max(motif2selflessIDs(:,3));
    totalDimerCounts = zeros(numMotifClasses,1);
    
    bigDimerCollection = cell(numMotifClasses,1);
    if trackDimerCollection
        for i = 1:numMotifClasses
            bigDimerCollection{i} = zeros(1,2);
        end
    end
        
    
    for nodeA = 1:totalNodes
        for nodeB = nodeA+1:totalNodes      
            
            excitA = EorIvector(nodeA);
            A2B = Cij(nodeA,nodeB);
            
            excitB = EorIvector(nodeB);
            B2A = Cij(nodeB,nodeA);

            miniConnectionMatrixAB = [excitA A2B excitB B2A];
            indx = ismember(motif2selflessConnectionPats, miniConnectionMatrixAB, 'rows')==1;
            motifClassNum = motif2selflessIDs(indx,3);
            
            totalDimerCounts(motifClassNum) = totalDimerCounts(motifClassNum) + 1;

            if trackDimerCollection
                bigDimerCollection{motifClassNum}(totalDimerCounts(motifClassNum),1:2) = [nodeA nodeB];
            end
            
        end % for nodeB
    end % for nodeA    
    
    if trackDimerCollection
        for i = 1:numMotifClasses
            if isequal(bigDimerCollection{i}(1,1:2), [0 0])
                bigDimerCollection{i} = NaN;
            end
        end
    end
end