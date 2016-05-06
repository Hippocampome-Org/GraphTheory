function unsignedDimerType = determineUnsignedDimerType(conn1, conn2)
    if ~conn1 && ~conn2
        unsignedDimerType = 1;    % 2 disconnected nodes (X    Y)
    elseif conn1 && ~conn2
        unsignedDimerType = 2;    % X -> Y
    elseif ~conn1 && conn2
        unsignedDimerType = 3;    % X <- Y
    elseif conn1 && conn2
        unsignedDimerType = 4;    % 2 bi-connected nodes (X <-> Y)
    end
end

