


n_vertices = 4;
%polygon_radius = 5; 
polygon_radius = 50; 
rad_var = 1 ;%5
ang_var = 1 ;%1
dx = 15;
transl_spd = 10;
rot_spd = pi/4;

samplingx0 = -10;
samplingx1 = 10;
samplingy0 = -10;
samplingy1 = 10;
x_start = 100; y_start = 120; x_end = 150; y_end = -50;

% x_start = (samplingx1- samplingx0) * rand() + samplingx0;
% y_start = (samplingy1- samplingy0) * rand() + samplingy0;
% x_end = (samplingx1- samplingx0) * rand() + samplingx0;
% y_end = (samplingy1- samplingy0) * rand() + samplingy0;
% 
% get polygon  % M= Polygon vertex matrix and Mshifted is shifted polygon
% vertex matrix
[M, Mshifted]= getConvexPolygon(n_vertices,polygon_radius,rad_var,ang_var);

% dividing polygon into partitions
% p.x=(M(:,1))';
% p.y=(M(:,2))';
% NX=2;                     %Number of divisions in x direction
% NY=1;                     %Number of divisions in y direction
% PXY=DIVIDEXY(p,NX,NY); %Divide Polygon, 'p' to smaller polygons set by grid
% subplot(1,2,1);   %Plot original Polygon
% for i=0:1:NX
%     plot([i/NX*(max(p.x)-min(p.x))+min(p.x) i/NX*(max(p.x)-min(p.x))+min(p.x)],[min(p.y) max(p.y)],'g');
%     hold on
% end
% for i=0:1:NY
%     plot([min(p.x) max(p.x)],[i/NY*(max(p.y)-min(p.y))+min(p.y) i/NY*(max(p.y)-min(p.y))+min(p.y)],'g');
%     hold on
% end
% plot([p.x p.x(1)],[p.y p.y(1)],'b*-');
% hold off
% daspect([1 1 1]);
% figure(1)
% %subplot(1,2,2);   %Plot smaller polygons set by grid
% for i=1:1:NX
% for j=1:1:NY
%     if not(isempty(PXY{i,j}))
%     plot([PXY{i,j}.x PXY{i,j}.x(1)],[PXY{i,j}.y PXY{i,j}.y(1)],'ro-');
%     end
% hold on
% end
% end
% % hold off
% daspect([1 1 1]);



% %----- Optimal coverage path planning -----
tic;
% Compute Antipodal pairs
A = antipodalPoints(M)
[m, ~] = size(A);

% Graph polygon and antipodal points
% figure('Position',[10 100 500 500],'Renderer','zbuffer');
% axis equal; hold on;
% line([M(:,1)';Mshifted(:,1)'],[M(:,2)';Mshifted(:,2)'],'Color','k');
% title('Antipodal pairs');
% xlabel('East (x)'); ylabel('North (y)');
sz = 25; c = linspace(1,10,m);  
% for i=1:m
%    scatter( M(A(i,1),1), M(A(i,1),2), sz, c(i), 'filled' );
%    scatter( M(A(i,2),1), M(A(i,2),2), sz, c(i), 'filled' );
%    line([M(A(i,1),1); M(A(i,2),1)],[M(A(i,1),2);M(A(i,2),2)],'Color',[rand() rand() rand()],'LineStyle','--');
% end
% hold off;
% scatter(x_start, y_start, 25, 'filled');
% scatter(x_end, y_end, 25, 'filled');

min_cost = Inf;
optimal_path = [];
best_antipodal_pair = 0;

for i=1:m 
    Path = bestPathForAntipodalPair(M, A(i,:), dx);
         
    %check if the path should be inverted
    FullPath1 = [x_start y_start; Path;  x_end y_end];
    FullPath2 = [x_start y_start; flipud(Path); x_end y_end];
    
    cost1 = timeCost2D(FullPath1, transl_spd, rot_spd, [x_start y_start 0]);
    
    cost2 =  timeCost2D(FullPath2, transl_spd, rot_spd, [x_start y_start 0]);
    
    if (cost1 < cost2)
       FullPath = FullPath1;
       Cost(i) = cost1;
    else
       FullPath = FullPath2;
       Cost(i) = cost2;
    end
    
    if Cost(i)<min_cost
        min_cost = Cost(i);
        optimal_path = FullPath;
        best_antipodal_pair = i;
    end
        
%--------- Draw the best path for an antipodal pair
%     figure;
%     axis equal;
%     line([M(:,1)';Mshifted(:,1)'],[M(:,2)';Mshifted(:,2)'],'Color','k');
%     title('Best path for an antipodal pair');
%     ylabel('x(meters)');
%     xlabel('y(meters)');
%     hold on;
%     scatter( M(A(i,1),1), M(A(i,1),2), sz, c(i), 'filled' );
%     scatter( M(A(i,2),1), M(A(i,2),2), sz, c(i), 'filled' );
%     plot(FullPath(:,1), FullPath(:,2));
%     txt1 = ['cost = ', num2str(Cost(i))];
%     text(x_start,y_start,txt1);
%     hold off;
end

time = toc

% figure('Position',[10+500 100 500 500]);
axis equal;
line([M(:,1)';Mshifted(:,1)'],[M(:,2)';Mshifted(:,2)'],'Color','k');
title('Coverage path plan');
xlabel('East (x)');
ylabel('North (y)');
hold on;
i = best_antipodal_pair;
scatter( M(A(i,1),1), M(A(i,1),2), sz, c(i), 'filled' );
scatter( M(A(i,2),1), M(A(i,2),2), sz, c(i), 'filled' );

plot(optimal_path(:,1), optimal_path(:,2), '-o');
scatter(x_start, y_start, 25, 'filled');
scatter(x_end, y_end, 25, 'filled');
% txt1 = ['cost = ', num2str(min_cost)];
% text(x_start,y_start,txt1);
hold off;
%     
%     
