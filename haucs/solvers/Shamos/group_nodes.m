function p_groups=group_nodes(nodes,numdiv)
    %Input
    %nodes : node locations in [x,y] coordinates
    %numdiv : number of groups to divide the nodes into
    %Output
    %p_groups : cell array of polygon vertices which outline each group of nodes

    [idx,C] = kmeans(nodes,numdiv);

    for i=1:length(C)
        group{i} = [nodes(idx==i,1),nodes(idx==i,2)];
        k{i} = boundary(nodes(idx==i,1),nodes(idx==i,2),1);
        p_groups{i}.x = group{i}(k{i},1);
        p_groups{i}.y = group{i}(k{i},2);
    end

end
