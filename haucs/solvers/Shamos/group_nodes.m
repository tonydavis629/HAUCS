function p_groups=group_nodes(nodes,numdiv)
    %Input
    %p: a structure consist of polygon.x (vector of x-coordinates) and polygon.y (vector of y-coordinates) 
    %numdiv: Number of divisions
    %Output
    %PXY: a cell array where PX{i,j}.x and PX{i,j} are vectors of x and y coordinates of new polygon in (i,j) grid position
%     DX=(max(p.x)-min(p.x))/NX;
%     DY=(max(p.y)-min(p.y))/NY;
%     i=0;
%     P=p;
%     for X=min(p.x)+DX:DX:max(p.x)-DX
%         i=i+1;
%         [PX{i}, P]=DIVIDEX(P,X);   
%     end
%     PX{NX}=P;
% 
%     for i=1:1:NX
%         j=0;
%     for Y=min(p.y)+DY:DY:max(p.y)-DY
%         j=j+1;
%         [GXY{i,j}, PX{i}]=DIVIDEY(PX{i},Y);     
%     end
% 
%     GXY{i,NY}=PX{i};
end
