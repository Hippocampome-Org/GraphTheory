% builds the dimer (2-node) library (including all possible rotations)
% from a spreadsheet containing edge information.  Edges are excitatory
% or inhibitory.  Weight parameters, for calculating excitability scores, 
% can be set in this function.

function build_motif_lib_2_selfless_from_superpattern_perm()
    superpatternCol = 1;
    A2Bcol = 2;
    B2Acol = 3;
    
    excitatoryWeight = 1.1;
    inhibitoryWeight = 0.9;
    
    input_table = xlsread('_Superpattern permutations 2_selfless (input for Matlab!).xlsx');
    
    bigSuperpatternPermMatrix = zeros(1,10);
    bigPermCounter = 1;
    runningClassTally = 0;

    for curSuperpattern = -1:2
        currentSuperpatternPerms = input_table(input_table(:,superpatternCol)==curSuperpattern,:);
        numCurrentSuperpatternPerms = size(currentSuperpatternPerms,1);
        
        curSuperpatternPermMatrix = zeros(1,10);
        curSuperpatternPermCounter = 1;
        dimerComposition = cell(1,4);
        
        for i = 1:numCurrentSuperpatternPerms
            % loop through node A options
            for excitatoryA = 1:-1:0
                if excitatoryA
                    connectionSignA = 1;
                    connectionWeightA = excitatoryWeight;
                else
                    connectionSignA = -1;
                    connectionWeightA = inhibitoryWeight;
                end
                    
                % loop through node B options
                for excitatoryB = 1:-1:0
                    if excitatoryB
                        connectionSignB = 1;
                        connectionWeightB = excitatoryWeight;
                    else
                        connectionSignB = -1;
                        connectionWeightB = inhibitoryWeight;
                    end

                    curSuperpatternPermMatrix(curSuperpatternPermCounter,1) = curSuperpattern;

                    curSuperpatternPermMatrix(curSuperpatternPermCounter,4) = excitatoryA;
                    curSuperpatternPermMatrix(curSuperpatternPermCounter,5) = connectionSignA*currentSuperpatternPerms(i,A2Bcol);

                    curSuperpatternPermMatrix(curSuperpatternPermCounter,6) = excitatoryB;
                    curSuperpatternPermMatrix(curSuperpatternPermCounter,7) = connectionSignB*currentSuperpatternPerms(i,B2Acol);
                    
                    if currentSuperpatternPerms(i,B2Acol)==0
                        overallWeightA = connectionSignA;
                    else
                        overallWeightA = connectionSignA * connectionWeightB*currentSuperpatternPerms(i,B2Acol);
                    end
                    if currentSuperpatternPerms(i,A2Bcol)==0
                        overallWeightB = connectionSignB;
                    else
                        overallWeightB = connectionSignB * connectionWeightA*currentSuperpatternPerms(i,A2Bcol);
                    end

                    curSuperpatternPermMatrix(curSuperpatternPermCounter,8) = overallWeightA;
                    curSuperpatternPermMatrix(curSuperpatternPermCounter,9) = overallWeightB;
                    curSuperpatternPermMatrix(curSuperpatternPermCounter,10) = overallWeightA + overallWeightB;                    

                    nodeType1 = determineNodeTypeText(excitatoryA);
                    nodeType2 = determineNodeTypeText(excitatoryB);
                    unsignedDimerType = determineUnsignedDimerType(currentSuperpatternPerms(i,A2Bcol), currentSuperpatternPerms(i,B2Acol));
                    dimerComposition{curSuperpatternPermCounter,1} = nodeType1;
                    dimerComposition{curSuperpatternPermCounter,2} = nodeType2;
                    dimerComposition{curSuperpatternPermCounter,3} = unsignedDimerType;
                    dimerComposition{curSuperpatternPermCounter,4} = determineDimerType(nodeType1, nodeType2, unsignedDimerType);

                    curSuperpatternPermCounter = curSuperpatternPermCounter + 1;
                    bigPermCounter = bigPermCounter + 1;                            
                    
                end % for excitatoryB            
            end % for excitatoryA                                        
        end % for i = 1:numCurrentSuperpatternPerms
        
        
        superpatternClassCounter = 0;

        for pots=1:size(curSuperpatternPermMatrix,1)
        
            if (curSuperpatternPermMatrix(pots,2)==0)
                superpatternClassCounter = superpatternClassCounter + 1;

                for pots2=(pots+1):size(curSuperpatternPermMatrix,1)
                    if (curSuperpatternPermMatrix(pots2,2)==0)

                        % if A==B
                        if isequal(dimerComposition(pots,4), dimerComposition(pots2,4))
                            
                            curSuperpatternPermMatrix(pots,2) = superpatternClassCounter;
                            curSuperpatternPermMatrix(pots2,2) = superpatternClassCounter;

                            curSuperpatternPermMatrix(pots,3) = runningClassTally + superpatternClassCounter;
                            curSuperpatternPermMatrix(pots2,3) = runningClassTally + superpatternClassCounter;

                        end % if A==B

                    end % if (curSuperpatternPermMatrix(pots2,2)==0)
                end % for pots2

                % if no matches found, unique pattern, so add it
                if (curSuperpatternPermMatrix(pots,2)==0)
                    curSuperpatternPermMatrix(pots,2) = superpatternClassCounter;
                    curSuperpatternPermMatrix(pots,3) = runningClassTally + superpatternClassCounter;
                end % if (curSuperpatternPermMatrix(pots,2)==0)

            end % if (curSuperpatternPermMatrix(pots,2)==0)
        end % for pots
        


        
        if curSuperpattern~=0
            bigSuperpatternPermMatrix(bigPermCounter-size(curSuperpatternPermMatrix,1):bigPermCounter-1,:) = curSuperpatternPermMatrix;
            runningClassTally = runningClassTally + superpatternClassCounter;
        end        
        
    end % curSuperpattern = -1:2
    
    motif2selflessNodeColors = cell(size(bigSuperpatternPermMatrix,1), 2);
    for z=1:size(bigSuperpatternPermMatrix,1)
        motif2selflessNodeColors{z,1} = determineNodeTypeText(bigSuperpatternPermMatrix(z,4));
        motif2selflessNodeColors{z,2} = determineNodeTypeText(bigSuperpatternPermMatrix(z,6));
    end
    
    motif2selflessIDs = bigSuperpatternPermMatrix(:,1:3);
    motif2selflessConnectionPats = bigSuperpatternPermMatrix(:,4:7);
    motif2selflessNodeWeights = bigSuperpatternPermMatrix(:,8:10);
    
    save motif_lib_2_selfless_EorI motif2selflessIDs motif2selflessConnectionPats motif2selflessNodeColors motif2selflessNodeWeights
end                