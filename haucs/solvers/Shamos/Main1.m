% Get polygon vertices, starting and end point

% M=[0 745;0 0;740 0;1320 745]
% Mshifted=[0 0;740 0;1320 745;0 745]
% x_start=-1;
% y_start=0;
% x_end=1300;
% y_end=750;

clf

P1=[0 0;0 370;740 370; 740 0];
P1shifted=[0 370;740 370;740 0;0 0];

P2=[0 370;0 745;740 745;740 370];
P2shifted=[0 745;740 745;740 370;0 370];

P3=[740 0;740 370;740 745;1320 745];
P3shifted=[740 370;740 745;1320 745;740 0];





% X1_start=-5;
% Y1_start=0;
% X1_end=-5;
% Y1_end=0;
% 
% X2_start=0;
% Y2_start=746;
% X2_end=0;
% Y2_end=750;
% 
% X3_start=742;
% Y3_start=0;
% X3_end=1321;
% Y3_end=746;

X1_start=740;
Y1_start=370;
X1_end=740;
Y1_end=370;

X2_start=740;
Y2_start=370;
X2_end=740;
Y2_end=370;

X3_start=740;
Y3_start=370;
X3_end=740;
Y3_end=370;


% to get Best path for Antipodal point 
dx = 100;
transl_spd = 10;
rot_spd = pi/4;
tic;

% P=zeros(4,2);
% Pshift=zeros(4,2);
for b=1:3
% P1 polygon

if (b==1)
%         % dividing polygon into partitions
%         p.x=(P1(:,1))';
%         p.y=(P1(:,2))';
%         NX=5;                     %Number of divisions in x direction
%         NY=4;                     %Number of divisions in y direction
%         PXY=DIVIDEXY(p,NX,NY); %Divide Polygon, 'p' to smaller polygons set by grid
%         subplot(1,2,1);   %Plot original Polygon
%         for i=0:1:NX
%             plot([i/NX*(max(p.x)-min(p.x))+min(p.x) i/NX*(max(p.x)-min(p.x))+min(p.x)],[min(p.y) max(p.y)],'g');
%             hold on
%         end
%         for i=0:1:NY
%             plot([min(p.x) max(p.x)],[i/NY*(max(p.y)-min(p.y))+min(p.y) i/NY*(max(p.y)-min(p.y))+min(p.y)],'g');
%             hold on
%         end
%         plot([p.x p.x(1)],[p.y p.y(1)],'b*-');
%         hold off
%         daspect([1 1 1]);
%         figure(1)
% % subplot(1,2,2);   %Plot smaller polygons set by grid
% for i=1:1:NX
% for j=1:1:NY
%     if not(isempty(PXY{i,j}))
%     plot([PXY{i,j}.x PXY{i,j}.x(1)],[PXY{i,j}.y PXY{i,j}.y(1)],'ro-');
%     end
% hold on
% end
% end
% hold off
daspect([1 1 1]);
% Compute Antipodal pairs
A1 = antipodalPoints(P1)
[m, ~] = size(A1);

% Graph polygon and antipodal points
% figure('Position',[10 100 500 500],'Renderer','zbuffer');
% axis equal; hold on;
% line([M(:,1)';Mshifted(:,1)'],[M(:,2)';Mshifted(:,2)'],'Color','k');
% title('Antipodal pairs');
% xlabel('East (x)'); ylabel('North (y)');
% hold on;
sz = 25; c = linspace(1,10,m);  % don't comment later
for i=1:m
   scatter( P1(A1(i,1),1), P1(A1(i,1),2), sz, c(i), 'filled' );
   scatter( P1(A1(i,2),1), P1(A1(i,2),2), sz, c(i), 'filled' );
   %line([P1(A1(i,1),1); P1(A1(i,2),1)],[P1(A1(i,1),2);P1(A1(i,2),2)],'Color',[rand() rand() rand()],'LineStyle','--');
end
% %hold off;
% scatter(x_start, y_start, 25, 'filled');
% scatter(x_end, y_end, 25, 'filled');
% hold off;

% To find Best path for antipodal pairs

min_cost_1 = Inf;
optimal_path_1 = [];
best_antipodal_pair_1 = 0;

for i=1:m 
    Path = bestPathForAntipodalPair(P1, A1(i,:), dx);
         
    %check if the path should be inverted
    FullPath1 = [X1_start Y1_start; Path;  X1_end Y1_end];
    FullPath2 = [X1_start Y1_start; flipud(Path); X1_end Y1_end];
    
    cost1 = timeCost2D(FullPath1, transl_spd, rot_spd, [X1_start Y1_start 0]);
    
    cost2 =  timeCost2D(FullPath2, transl_spd, rot_spd, [X1_start Y1_start 0]);
    
    if (cost1 < cost2)
       FullPath = FullPath1;
       Cost(i) = cost1;
    else
       FullPath = FullPath2;
       Cost(i) = cost2;
    end
    
    if Cost(i)<min_cost_1
        min_cost_1 = Cost(i);
        optimal_path_1 = FullPath;
        best_antipodal_pair_1 = i;
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
line([P1(:,1)';P1shifted(:,1)'],[P1(:,2)';P1shifted(:,2)'],'Color','k');
title('Coverage path plan');
xlabel('East (x)');
ylabel('North (y)');
hold on;
i = best_antipodal_pair_1;
    scatter( P1(A1(i,1),1), P1(A1(i,1),2), sz, c(i), 'filled' );
    scatter( P1(A1(i,2),1), P1(A1(i,2),2), sz, c(i), 'filled' );

plot(optimal_path_1(:,1), optimal_path_1(:,2), '-o');
scatter(X1_start, Y1_start, 25, 'filled');
scatter(X1_end, Y1_end, 25, 'filled');
txt1 = ['cost = ', num2str(min_cost_1)];
text(X1_start,Y1_start,txt1);
hold on;


elseif (b==2)
    % Polygon P2

%             % dividing polygon into partitions
%             p.x=(P2(:,1))';
%             p.y=(P2(:,2))';
%             NX=5;                     %Number of divisions in x direction
%             NY=4;                     %Number of divisions in y direction
%             PXY=DIVIDEXY(p,NX,NY); %Divide Polygon, 'p' to smaller polygons set by grid
%             subplot(1,2,1);   %Plot original Polygon
%             for i=0:1:NX
%                 plot([i/NX*(max(p.x)-min(p.x))+min(p.x) i/NX*(max(p.x)-min(p.x))+min(p.x)],[min(p.y) max(p.y)],'g');
%                 hold on
%             end
%             for i=0:1:NY
%                 plot([min(p.x) max(p.x)],[i/NY*(max(p.y)-min(p.y))+min(p.y) i/NY*(max(p.y)-min(p.y))+min(p.y)],'g');
%                 hold on
%             end
%             plot([p.x p.x(1)],[p.y p.y(1)],'b*-');
%             hold on
%             daspect([1 1 1]);
%             
%             subplot(1,2,2);   %Plot smaller polygons set by grid
%             for i=1:1:NX
%             for j=1:1:NY
%                 if not(isempty(PXY{i,j}))
%                 plot([PXY{i,j}.x PXY{i,j}.x(1)],[PXY{i,j}.y PXY{i,j}.y(1)],'ro-');
%                 end
%             hold on
%             end
%             end
            % hold off
            daspect([1 1 1]);
            % Compute Antipodal pairs
            A2 = antipodalPoints(P2)
            [m, ~] = size(A2);
            
            % Graph polygon and antipodal points
            % figure('Position',[10 100 500 500],'Renderer','zbuffer');
            % axis equal; hold on;
            % line([M(:,1)';Mshifted(:,1)'],[M(:,2)';Mshifted(:,2)'],'Color','k');
            % title('Antipodal pairs');
            % xlabel('East (x)'); ylabel('North (y)');
            % hold on;
            sz = 25; c = linspace(1,10,m);  % don't comment later
            for i=1:m
               scatter( P2(A2(i,1),1), P2(A2(i,1),2), sz, c(i), 'filled' );
               scatter( P2(A2(i,2),1), P2(A2(i,2),2), sz, c(i), 'filled' );
               %line([P1(A1(i,1),1); P1(A1(i,2),1)],[P1(A1(i,1),2);P1(A1(i,2),2)],'Color',[rand() rand() rand()],'LineStyle','--');
            end
            % %hold off;
            % scatter(x_start, y_start, 25, 'filled');
            % scatter(x_end, y_end, 25, 'filled');
            % hold off;
            
            % To find Best path for antipodal pairs
            
            min_cost_2 = Inf;
            optimal_path_2 = [];
            best_antipodal_pair_2 = 0;
            
            for i=1:m 
                Path = bestPathForAntipodalPair(P2, A2(i,:), dx);
                     
                %check if the path should be inverted
                FullPath1 = [X2_start Y2_start; Path;  X2_end Y2_end];
                FullPath2 = [X2_start Y2_start; flipud(Path); X2_end Y2_end];
                
                cost1 = timeCost2D(FullPath1, transl_spd, rot_spd, [X2_start Y2_start 0]);
                
                cost2 =  timeCost2D(FullPath2, transl_spd, rot_spd, [X2_start Y2_start 0]);
                
                if (cost1 < cost2)
                   FullPath = FullPath1;
                   Cost(i) = cost1;
                else
                   FullPath = FullPath2;
                   Cost(i) = cost2;
                end
                
                if Cost(i)<min_cost_2
                    min_cost_2 = Cost(i);
                    optimal_path_2 = FullPath;
                    best_antipodal_pair_2 = i;
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
            % figure(2)
            axis equal;
            line([P2(:,1)';P2shifted(:,1)'],[P2(:,2)';P2shifted(:,2)'],'Color','k');
            title('Coverage path plan');
            xlabel('East (x)');
            ylabel('North (y)');
            hold on;
            i = best_antipodal_pair_2;
            scatter( P2(A2(i,1),1), P2(A2(i,1),2), sz, c(i), 'filled' );
            scatter( P2(A2(i,2),1), P2(A2(i,2),2), sz, c(i), 'filled' );
            
            plot(optimal_path_2(:,1), optimal_path_2(:,2), '-o');
            scatter(X2_start, Y2_start, 25, 'filled');
            scatter(X2_end, Y2_end, 25, 'filled');
            txt1 = ['cost = ', num2str(min_cost_2)];
            text(X2_start,Y2_start,txt1);
            hold on;

else
      % Polygon P3

            % dividing polygon into partitions
%             p.x=(P3(:,1))';
%             p.y=(P3(:,2))';
%             NX=5;                     %Number of divisions in x direction
%             NY=4;                     %Number of divisions in y direction
%             PXY=DIVIDEXY(p,NX,NY); %Divide Polygon, 'p' to smaller polygons set by grid
%             subplot(1,2,1);   %Plot original Polygon
%             for i=0:1:NX
%                 plot([i/NX*(max(p.x)-min(p.x))+min(p.x) i/NX*(max(p.x)-min(p.x))+min(p.x)],[min(p.y) max(p.y)],'g');
%                 hold on
%             end
%             for i=0:1:NY
%                 plot([min(p.x) max(p.x)],[i/NY*(max(p.y)-min(p.y))+min(p.y) i/NY*(max(p.y)-min(p.y))+min(p.y)],'g');
%                 hold on
%             end
%             plot([p.x p.x(1)],[p.y p.y(1)],'b*-');
%             hold off
%             daspect([1 1 1]);
% %             figure(3)
%             subplot(1,2,2);   %Plot smaller polygons set by grid
%             for i=1:1:NX
%             for j=1:1:NY
%                 if not(isempty(PXY{i,j}))
%                 plot([PXY{i,j}.x PXY{i,j}.x(1)],[PXY{i,j}.y PXY{i,j}.y(1)],'ro-');
%                 end
%             hold on
%             end
%             end
            % hold off
            daspect([1 1 1]);
            % Compute Antipodal pairs
            A3 = antipodalPoints(P3)
            [m, ~] = size(A3);
            
            % Graph polygon and antipodal points
            % figure('Position',[10 100 500 500],'Renderer','zbuffer');
            % axis equal; hold on;
            % line([M(:,1)';Mshifted(:,1)'],[M(:,2)';Mshifted(:,2)'],'Color','k');
            % title('Antipodal pairs');
            % xlabel('East (x)'); ylabel('North (y)');
            % hold on;
            sz = 25; c = linspace(1,10,m);  % don't comment later
            for i=1:m
               scatter( P3(A3(i,1),1), P3(A3(i,1),2), sz, c(i), 'filled' );
               scatter( P3(A3(i,2),1), P3(A3(i,2),2), sz, c(i), 'filled' );
               %line([P1(A1(i,1),1); P1(A1(i,2),1)],[P1(A1(i,1),2);P1(A1(i,2),2)],'Color',[rand() rand() rand()],'LineStyle','--');
            end
            % %hold off;
            % scatter(x_start, y_start, 25, 'filled');
            % scatter(x_end, y_end, 25, 'filled');
            % hold off;
            
            % To find Best path for antipodal pairs
            
            min_cost_3 = Inf;
            optimal_path_3 = [];
            best_antipodal_pair_3 = 0;
            
            for i=1:m 
                Path = bestPathForAntipodalPair(P3, A3(i,:), dx);
                     
                %check if the path should be inverted
                FullPath1 = [X3_start Y3_start; Path;  X3_end Y3_end];
                FullPath2 = [X3_start Y3_start; flipud(Path); X3_end Y3_end];
                
                cost1 = timeCost2D(FullPath1, transl_spd, rot_spd, [X3_start Y3_start 0]);
                
                cost2 =  timeCost2D(FullPath2, transl_spd, rot_spd, [X3_start Y3_start 0]);
                
                if (cost1 < cost2)
                   FullPath = FullPath1;
                   Cost(i) = cost1;
                else
                   FullPath = FullPath2;
                   Cost(i) = cost2;
                end
                
                if Cost(i)<min_cost_3
                    min_cost_3 = Cost(i);
                    optimal_path_3 = FullPath;
                    best_antipodal_pair_3 = i;
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
            % figure(2)
            axis equal;
            line([P3(:,1)';P3shifted(:,1)'],[P3(:,2)';P3shifted(:,2)'],'Color','k');
            title('Coverage path plan');
            xlabel('East (x)');
            ylabel('North (y)');
            hold on;
            i = best_antipodal_pair_3;
            scatter( P3(A3(i,1),1), P3(A3(i,1),2), sz, c(i), 'filled' );
            scatter( P3(A3(i,2),1), P3(A3(i,2),2), sz, c(i), 'filled' );
            
            plot(optimal_path_3(:,1), optimal_path_3(:,2), '-o');
            scatter(X3_start, Y3_start, 25, 'filled');
            scatter(X3_end, Y3_end, 25, 'filled');
            txt1 = ['cost = ', num2str(min_cost_3)];
            text(X3_start,Y3_start,txt1);
            hold on;
            
end


end

