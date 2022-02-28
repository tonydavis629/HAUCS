
function [Polygon_vertex, shifted_polygon_vertex] = getConvexPolygon(numVert, radius, radVar, angVar)

isConvex = false;

while not(isConvex)
    [Polygon_vertex, shifted_polygon_vertex]= getPolygon(numVert, radius, radVar, angVar);
    isConvex = isAConvexPolygon(Polygon_vertex);
end

end