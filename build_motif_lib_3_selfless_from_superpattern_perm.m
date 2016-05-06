% builds the trimer (2-node) library (including all possible rotations)
% from a spreadsheet containing edge information.  Edges are excitatory
% or inhibitory.  Weight parameters, for calculating excitability scores, 
% can be set in this function.

function build_motif_lib_3_selfless_from_superpattern_perm()    
    superpatternCol = 1;
    A2Bcol = 2;
    A2Ccol = 3;
    B2Acol = 4;
    B2Ccol = 5;
    C2Acol = 6;
    C2Bcol = 7;
    
    excitatoryWeight = 1.1;
    inhibitoryWeight = 0.9;
    
    input_table = xlsread('_Superpattern permutations 3_selfless (input for Matlab!).xlsx');    
       
    bigSuperpatternPermMatrix = zeros(1,16);
    bigPermCounter = 1;
    runningClassTally = 0;
    
    for curSuperpattern = -3:13        
        currentSuperpatternPerms = input_table(input_table(:,superpatternCol)==curSuperpattern,:);
        numCurrentSuperpatternPerms = size(currentSuperpatternPerms,1);
        
        curSuperpatternPermMatrix = zeros(1,16);
        curSuperpatternPermCounter = 1;
        dimerComposition = cell(1,12);
        
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

                    % loop through node C options
                    for excitatoryC = 1:-1:0
                        if excitatoryC
                            connectionSignC = 1;
                            connectionWeightC = excitatoryWeight;
                        else
                            connectionSignC = -1;
                            connectionWeightC = inhibitoryWeight;
                        end

                        curSuperpatternPermMatrix(curSuperpatternPermCounter,1) = curSuperpattern;

                        curSuperpatternPermMatrix(curSuperpatternPermCounter,4) = excitatoryA;
                        curSuperpatternPermMatrix(curSuperpatternPermCounter,5) = connectionSignA*currentSuperpatternPerms(i,A2Bcol);
                        curSuperpatternPermMatrix(curSuperpatternPermCounter,6) = connectionSignA*currentSuperpatternPerms(i,A2Ccol);                                                                        

                        curSuperpatternPermMatrix(curSuperpatternPermCounter,7) = excitatoryB;
                        curSuperpatternPermMatrix(curSuperpatternPermCounter,8) = connectionSignB*currentSuperpatternPerms(i,B2Acol);
                        curSuperpatternPermMatrix(curSuperpatternPermCounter,9) = connectionSignB*currentSuperpatternPerms(i,B2Ccol);                                    

                        curSuperpatternPermMatrix(curSuperpatternPermCounter,10) = excitatoryC;
                        curSuperpatternPermMatrix(curSuperpatternPermCounter,11) = connectionSignC*currentSuperpatternPerms(i,C2Acol);
                        curSuperpatternPermMatrix(curSuperpatternPermCounter,12) = connectionSignC*currentSuperpatternPerms(i,C2Bcol);
                        
                        if currentSuperpatternPerms(i,B2Acol)==0 && currentSuperpatternPerms(i,C2Acol)==0
                            overallWeightA = connectionSignA;
                        elseif currentSuperpatternPerms(i,B2Acol)==0
                            overallWeightA = connectionSignA * (connectionWeightC*currentSuperpatternPerms(i,C2Acol));
                        elseif currentSuperpatternPerms(i,C2Acol)==0
                            overallWeightA = connectionSignA * (connectionWeightB*currentSuperpatternPerms(i,B2Acol));                            
                        else
                            overallWeightA = connectionSignA * (connectionWeightB*currentSuperpatternPerms(i,B2Acol) * connectionWeightC*currentSuperpatternPerms(i,C2Acol));
                        end
                        
                        if currentSuperpatternPerms(i,A2Bcol)==0 && currentSuperpatternPerms(i,C2Bcol)==0
                            overallWeightB = connectionSignB;
                        elseif currentSuperpatternPerms(i,A2Bcol)==0
                            overallWeightB = connectionSignB * (connectionWeightC*currentSuperpatternPerms(i,C2Bcol));
                        elseif currentSuperpatternPerms(i,C2Bcol)==0
                            overallWeightB = connectionSignB * (connectionWeightA*currentSuperpatternPerms(i,A2Bcol));
                        else
                            overallWeightB = connectionSignB * (connectionWeightA*currentSuperpatternPerms(i,A2Bcol) * connectionWeightC*currentSuperpatternPerms(i,C2Bcol));
                        end
                        
                        if currentSuperpatternPerms(i,A2Ccol)==0 && currentSuperpatternPerms(i,B2Ccol)==0
                            overallWeightC = connectionSignC;
                        elseif currentSuperpatternPerms(i,A2Ccol)==0
                            overallWeightC = connectionSignC * (connectionWeightB*currentSuperpatternPerms(i,B2Ccol));
                        elseif currentSuperpatternPerms(i,B2Ccol)==0
                            overallWeightC = connectionSignC * (connectionWeightA*currentSuperpatternPerms(i,A2Ccol));
                        else
                            overallWeightC = connectionSignC * (connectionWeightA*currentSuperpatternPerms(i,A2Ccol) * connectionWeightB*currentSuperpatternPerms(i,B2Ccol));
                        end
                        
                        curSuperpatternPermMatrix(curSuperpatternPermCounter,13) = overallWeightA;
                        curSuperpatternPermMatrix(curSuperpatternPermCounter,14) = overallWeightB;
                        curSuperpatternPermMatrix(curSuperpatternPermCounter,15) = overallWeightC;
                        curSuperpatternPermMatrix(curSuperpatternPermCounter,16) = overallWeightA + overallWeightB + overallWeightC;

                        nodeType1 = determineNodeTypeText(excitatoryA);
                        nodeType2 = determineNodeTypeText(excitatoryB);
                        unsignedDimerType = determineUnsignedDimerType(currentSuperpatternPerms(i,A2Bcol), currentSuperpatternPerms(i,B2Acol));
                        dimerComposition{curSuperpatternPermCounter,1} = nodeType1;
                        dimerComposition{curSuperpatternPermCounter,2} = nodeType2;
                        dimerComposition{curSuperpatternPermCounter,3} = unsignedDimerType;
                        dimerComposition{curSuperpatternPermCounter,4} = determineDimerType(nodeType1, nodeType2, unsignedDimerType);

                        nodeType1 = determineNodeTypeText(excitatoryA);
                        nodeType2 = determineNodeTypeText(excitatoryC);
                        unsignedDimerType = determineUnsignedDimerType(currentSuperpatternPerms(i,A2Ccol), currentSuperpatternPerms(i,C2Acol));
                        dimerComposition{curSuperpatternPermCounter,5} = nodeType1;
                        dimerComposition{curSuperpatternPermCounter,6} = nodeType2;
                        dimerComposition{curSuperpatternPermCounter,7} = unsignedDimerType;
                        dimerComposition{curSuperpatternPermCounter,8} = determineDimerType(nodeType1, nodeType2, unsignedDimerType);

                        nodeType1 = determineNodeTypeText(excitatoryB);
                        nodeType2 = determineNodeTypeText(excitatoryC);
                        unsignedDimerType = determineUnsignedDimerType(currentSuperpatternPerms(i,B2Ccol), currentSuperpatternPerms(i,C2Bcol));
                        dimerComposition{curSuperpatternPermCounter,9} = nodeType1;
                        dimerComposition{curSuperpatternPermCounter,10} = nodeType2;
                        dimerComposition{curSuperpatternPermCounter,11} = unsignedDimerType;
                        dimerComposition{curSuperpatternPermCounter,12} = determineDimerType(nodeType1, nodeType2, unsignedDimerType);                        

                        curSuperpatternPermCounter = curSuperpatternPermCounter + 1;
                        bigPermCounter = bigPermCounter + 1;
                    end % excitatoryC
                end % excitatoryB
            end % excitatoryA
        end % numCurrentSuperpatternPerms
            
        
        superpatternClassCounter = 0;

        for pots=1:size(curSuperpatternPermMatrix,1)
            if (curSuperpatternPermMatrix(pots,2)==0)
                superpatternClassCounter = superpatternClassCounter + 1;

                for pots2=(pots+1):size(curSuperpatternPermMatrix,1)
                    if (curSuperpatternPermMatrix(pots2,2)==0)

                        % if ABC==ACB || ABC==BAC || ABC==BCA || ABC==CAB || ABC==CBA
                        if ( (isequal(dimerComposition(pots,4), dimerComposition(pots2,4)) && ...
                        isequal(dimerComposition(pots,8), dimerComposition(pots2,12)) && ...
                        isequal(dimerComposition(pots,12), dimerComposition(pots2,8))) || ...
                        ...
                        (isequal(dimerComposition(pots,4), dimerComposition(pots2,8)) && ...
                        isequal(dimerComposition(pots,8), dimerComposition(pots2,4)) && ...
                        isequal(dimerComposition(pots,12), dimerComposition(pots2,12))) || ...
                        ...
                        (isequal(dimerComposition(pots,4), dimerComposition(pots2,8)) && ...
                        isequal(dimerComposition(pots,8), dimerComposition(pots2,12)) && ...
                        isequal(dimerComposition(pots,12), dimerComposition(pots2,4))) || ...
                        ...
                        (isequal(dimerComposition(pots,4), dimerComposition(pots2,12)) && ...
                        isequal(dimerComposition(pots,8), dimerComposition(pots2,4)) && ...
                        isequal(dimerComposition(pots,12), dimerComposition(pots2,8))) || ...
                        ...
                        (isequal(dimerComposition(pots,4), dimerComposition(pots2,12)) && ...
                        isequal(dimerComposition(pots,8), dimerComposition(pots2,8)) && ...
                        isequal(dimerComposition(pots,12), dimerComposition(pots2,4))) )

                            curSuperpatternPermMatrix(pots,2) = superpatternClassCounter;
                            curSuperpatternPermMatrix(pots2,2) = superpatternClassCounter;

                            curSuperpatternPermMatrix(pots,3) = runningClassTally + superpatternClassCounter;
                            curSuperpatternPermMatrix(pots2,3) = runningClassTally + superpatternClassCounter;

                        end % massive if

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
        
    end % for curSuperpattern
    
    motif3selflessNodeColors = cell(size(bigSuperpatternPermMatrix,1), 3);
    for z=1:size(bigSuperpatternPermMatrix,1)
        motif3selflessNodeColors{z,1} = determineNodeTypeText(bigSuperpatternPermMatrix(z,4));
        motif3selflessNodeColors{z,2} = determineNodeTypeText(bigSuperpatternPermMatrix(z,7));
        motif3selflessNodeColors{z,3} = determineNodeTypeText(bigSuperpatternPermMatrix(z,10));
    end
    
    motif3selflessIDs = bigSuperpatternPermMatrix(:,1:3);
    motif3selflessConnectionPats = bigSuperpatternPermMatrix(:,4:12);
    motif3selflessNodeWeights = bigSuperpatternPermMatrix(:,13:16);

    save motif_lib_3_selfless_EorI motif3selflessIDs motif3selflessConnectionPats motif3selflessNodeColors motif3selflessNodeWeights
end