function p_groups=group_nodes(nodes,numdiv)
    %Input
    %nodes : node locations in [x,y] coordinates
    %numdiv : number of groups to divide the nodes into
    %Output
    %p_groups : cell array of polygon vertices which outline each group of nodes

    [idx,C] = kmeans(nodes,numdiv);

    for i=1:length(C)

        while size(nodes(idx==i),1) < 3 %check to make sure group as at least 3 nodes
            idx = swapidx(C,nodes,idx,i); % if not, swap closest nodes into group
        end

        thisgroup = [nodes(idx==i,1),nodes(idx==i,2)];
        
%         k{i} = convhull(thisgroup);
        error = true;
        while error==true
            try
                k{i} = convhull(thisgroup);
                error = false;
            catch
                idx = swapidx(C,nodes,idx,i);
                thisgroup = [nodes(idx==i,1),nodes(idx==i,2)];
                k{i} = convhull(thisgroup);
            end

%             b=(nodes(idx==i,:));
%             b(1,:)=b(1,:)+[.01,.01];
%             k{i} = convhull(b(:,1),b(:,2));
        end

%         k{i} = boundary(nodes(idx==i,1),nodes(idx==i,2),1);
        p_groups{i}.x = thisgroup(k{i},1);
        p_groups{i}.y = thisgroup(k{i},2);
    end

end
