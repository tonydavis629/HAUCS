function PXY=DIVIDEXY(p,NX,NY)
%Input
%polygon: a structure consist of polygon.x (vector of x-coordinates) and polygon.y (vector of y-coordinates) 
%NX: Number of divisions in x direction
%NY: Number of divisions in y direction
%Output
%PXY: a cell array where PX{i,j}.x and PX{i,j} are vectors of x and y coordinates of new polygon in (i,j) grid position
DX=(max(p.x)-min(p.x))/NX;
DY=(max(p.y)-min(p.y))/NY;
i=0;
P=p;
for X=min(p.x)+DX:DX:max(p.x)-DX
i=i+1;
[PX{i}, P]=DIVIDEX(P,X);
    
end
PX{NX}=P;
for i=1:1:NX
j=0;
for Y=min(p.y)+DY:DY:max(p.y)-DY
j=j+1;
[PXY{i,j}, PX{i}]=DIVIDEY(PX{i},Y);     
end
PXY{i,NY}=PX{i};
end
