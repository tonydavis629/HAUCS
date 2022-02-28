

function out = lineSegmentIntersect(XY1,XY2)

validateattributes(XY1,{'numeric'},{'2d','finite'});
validateattributes(XY2,{'numeric'},{'2d','finite'});

[n_rows_1,n_cols_1] = size(XY1);
[n_rows_2,n_cols_2] = size(XY2);

if n_cols_1 ~= 4 || n_cols_2 ~= 4
    error('Arguments must be a Nx4 matrices.');
end

%%% Prepare matrices for vectorized computation of line intersection points.
%-------------------------------------------------------------------------------
X1 = repmat(XY1(:,1),1,n_rows_2);
X2 = repmat(XY1(:,3),1,n_rows_2);
Y1 = repmat(XY1(:,2),1,n_rows_2);
Y2 = repmat(XY1(:,4),1,n_rows_2);

XY2 = XY2';

X3 = repmat(XY2(1,:),n_rows_1,1);
X4 = repmat(XY2(3,:),n_rows_1,1);
Y3 = repmat(XY2(2,:),n_rows_1,1);
Y4 = repmat(XY2(4,:),n_rows_1,1);

X4_X3 = (X4-X3);
Y1_Y3 = (Y1-Y3);
Y4_Y3 = (Y4-Y3);
X1_X3 = (X1-X3);
X2_X1 = (X2-X1);
Y2_Y1 = (Y2-Y1);

numerator_a = X4_X3 .* Y1_Y3 - Y4_Y3 .* X1_X3;
numerator_b = X2_X1 .* Y1_Y3 - Y2_Y1 .* X1_X3;
denominator = Y4_Y3 .* X2_X1 - X4_X3 .* Y2_Y1;

u_a = numerator_a ./ denominator;
u_b = numerator_b ./ denominator;

% Find the adjacency matrix A of intersecting lines.
INT_X = X1+X2_X1.*u_a;
INT_Y = Y1+Y2_Y1.*u_a;
INT_B = (u_a >= 0) & (u_a <= 1) & (u_b >= 0) & (u_b <= 1);
PAR_B = denominator == 0;
COINC_B = (numerator_a == 0 & numerator_b == 0 & PAR_B);


% Arrange output.
out.intAdjacencyMatrix = INT_B;
out.intMatrixX = INT_X .* INT_B;
out.intMatrixY = INT_Y .* INT_B;
out.intNormalizedDistance1To2 = u_a;
out.intNormalizedDistance2To1 = u_b;
out.parAdjacencyMatrix = PAR_B;
out.coincAdjacencyMatrix= COINC_B;

end

