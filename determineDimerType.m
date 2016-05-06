function dimerType = determineDimerType(nodeType1, nodeType2, unsignedDimerType)

    if strcmpi(nodeType1, 'black') && strcmpi(nodeType2, 'black') && (unsignedDimerType==1)
        dimerType = 1;
    elseif strcmpi(nodeType1, 'black') && strcmpi(nodeType2, 'gray') && (unsignedDimerType==1) || ...
    (strcmpi(nodeType1, 'gray') && strcmpi(nodeType2, 'black') && (unsignedDimerType==1))
        dimerType = 2;
    elseif strcmpi(nodeType1, 'gray') && strcmpi(nodeType2, 'gray') && (unsignedDimerType==1)
        dimerType = 3;

    elseif (strcmpi(nodeType1, 'black') && strcmpi(nodeType2, 'black') && (unsignedDimerType==2)) || ...
    (strcmpi(nodeType1, 'black') && strcmpi(nodeType2, 'black') && (unsignedDimerType==3))
        dimerType = 4;
    elseif (strcmpi(nodeType1, 'black') && strcmpi(nodeType2, 'gray') && (unsignedDimerType==2)) || ...
    (strcmpi(nodeType1, 'gray') && strcmpi(nodeType2, 'black') && (unsignedDimerType==3))
        dimerType = 5;
    elseif (strcmpi(nodeType1, 'gray') && strcmpi(nodeType2, 'black') && (unsignedDimerType==2)) || ...
    (strcmpi(nodeType1, 'black') && strcmpi(nodeType2, 'gray') && (unsignedDimerType==3))
        dimerType = 6;
    elseif (strcmpi(nodeType1, 'gray') && strcmpi(nodeType2, 'gray') && (unsignedDimerType==2)) || ...
    (strcmpi(nodeType1, 'gray') && strcmpi(nodeType2, 'gray') && (unsignedDimerType==3))
        dimerType = 7;

        
    elseif (strcmpi(nodeType1, 'black') && strcmpi(nodeType2, 'black') && (unsignedDimerType==4))
        dimerType = 8;
    elseif (strcmpi(nodeType1, 'black') && strcmpi(nodeType2, 'gray') && (unsignedDimerType==4)) || ...
    (strcmpi(nodeType1, 'gray') && strcmpi(nodeType2, 'black') && (unsignedDimerType==4))
        dimerType = 9;
    elseif (strcmpi(nodeType1, 'gray') && strcmpi(nodeType2, 'gray') && (unsignedDimerType==4)) || ...
    (strcmpi(nodeType1, 'gray') && strcmpi(nodeType2, 'gray') && (unsignedDimerType==4))
        dimerType = 10;
        
    else
        dimerType = 999999
        pause
    end
end