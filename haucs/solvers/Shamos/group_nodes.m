function p_groups=group_nodes(nodes,numdiv)
    %Input
    %nodes : node locations in [x,y] coordinates
    %numdiv : number of groups to divide the nodes into
    %Output
    %p_groups : cell array of polygon vertices which outline each group of nodes
    
    [idx,C] = kmeans(nodes,numdiv);

    %find length(nodes)/numdiv closest nodes to C
    pts_clus = ceil(length(nodes)/numdiv);

    idx = [];
    for i=1:size(nodes,1)
        D = pdist2(nodes(i,:),C);     %find the distance between node and all clusters
        x = find(D==min(min(D)));     %find the cluster with the minimum distance
        if sum(idx==x)<=pts_clus     % if the cluster is not full
            idx = [idx, x];     % assign the node to that cluster
        else         % if the cluster is full 
            assigned = false;
            while assigned == false    % while node is not assigned
                D(x) = inf;
                x = find(D==min(min(D)));  % try next closest
                if sum(idx==x)<=pts_clus 
                    idx = [idx,x];        %if node is assigned, mark assigned
                    assigned = true;
                end
            end
        end
    end

    for i=1:length(C)
        group{i} = [nodes(idx==i,1),nodes(idx==i,2)];
        k{i} = boundary(nodes(idx==i,1),nodes(idx==i,2),1);
        p_groups{i}.x = group{i}(k{i},1);
        p_groups{i}.y = group{i}(k{i},2);
    end

end
