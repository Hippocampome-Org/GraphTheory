function nodeTypeText = determineNodeTypeText(excitatoryX)
    if excitatoryX
        nodeTypeText = 'black';
    elseif ~excitatoryX
        nodeTypeText = 'gray';
    end
end