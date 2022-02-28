    % Configuration
n_vertices = 5;
%polygon_radius = 5;
polygon_radius = 50; 
% rad_var = 1 ;%5
% ang_var = 1 ;%1
dx = 70;
transl_spd = 10;
rot_spd = pi/4;


% M=[0 0;0 370;740 370; 740 0];   % need to get PXY like M
% Mshifted=[0 370;740 370;740 0;0 0];

M =[0.9179656279287012 0.3980481357594894;0.7689605138306261 0.4088954949383255;0.7702552678351018 0.3496854537326516;0.5878513820289831 0.37151732444166746;0.5815476216368374 0.21278377503360835;0.45520222560214335 0.3873940653343971;0.2872319578176761 0.40749838028921725;0.25844823569632935 0.4460600585819847;0.22447268284226052 0.4485334302332761;0.08378120862184935 0.47904278832700886;0.22542348896692938 0.49030345607277676;0.03658933255383301 0.7432854005061418;0.18792156318033626 0.7567779568095042;0.05323028359050619 0.9429223211336845;0.6085534922398697 0.8928124292025078;0.6046266200825349 0.7939307590834971;0.7602375100591187 0.8078047942822995;0.7680207126638493 0.45187328501863355;0.9179656279287012 0.3980481357594894].*1000;
Mshifted = circshift(M,-1);

x_start=-1;
y_start=0;
x_end=1300;
y_end=750;
% dividing polygon into partitions
p.x=(M(:,1))';
p.y=(M(:,2))';
NX=2;                     %Number of divisions in x direction
NY=2;                     %Number of divisions in y direction
PXY=DIVIDEXY(p,NX,NY); %Divide Polygon, 'p' to smaller polygons set by grid
subplot(1,2,1);   %Plot original Polygon
for i=0:1:NX
    plot([i/NX*(max(p.x)-min(p.x))+min(p.x) i/NX*(max(p.x)-min(p.x))+min(p.x)],[min(p.y) max(p.y)],'g');
    hold on
end
for i=0:1:NY
    plot([min(p.x) max(p.x)],[i/NY*(max(p.y)-min(p.y))+min(p.y) i/NY*(max(p.y)-min(p.y))+min(p.y)],'g');
    hold on
end
plot([p.x p.x(1)],[p.y p.y(1)],'b*-');
hold off
daspect([1 1 1]);
figure(1)
%subplot(1,2,2);   %Plot smaller polygons set by grid
for i=1:1:NX
for j=1:1:NY
    if not(isempty(PXY{i,j}))
    %plot([PXY{i,j}.x PXY{i,j}.x(1)],[PXY{i,j}.y PXY{i,j}.y(1)],'ro-');
    plot([PXY{i,j}.x],[PXY{i,j}.y],'bo-');
    
    
    M = [PXY{i,j}.x.', PXY{i,j}.y.'];
      Mshifted = circshift(M,-1);
                   tic;
            % Compute Antipodal pairs
            A = antipodalPoints(M);
            [m, ~] = size(A);
            sz = 25; c = linspace(1,10,m); 

            min_cost = Inf;
            optimal_path = [];
            best_antipodal_pair = 0;
            for k=1:m 
                Path = bestPathForAntipodalPair(M, A(k,:), dx);

                %check if the path should be inverted
                FullPath1 = [x_start y_start; Path;  x_end y_end];
                FullPath2 = [x_start y_start; flipud(Path); x_end y_end];

                cost1 = timeCost2D(FullPath1, transl_spd, rot_spd, [x_start y_start 0]);

                cost2 =  timeCost2D(FullPath2, transl_spd, rot_spd, [x_start y_start 0]);

                if (cost1 < cost2)
                   FullPath = FullPath1;
                   Cost(k) = cost1;
                else
                   FullPath = FullPath2;
                   Cost(k) = cost2;
                end

                if Cost(k)<min_cost
                    min_cost = Cost(k);
                    optimal_path = FullPath;
                    best_antipodal_pair = k;
                end


            end

            time = toc;

            % figure('Position',[10+500 100 500 500]);
            axis equal;
            line([M(:,1)';Mshifted(:,1)'],[M(:,2)';Mshifted(:,2)'],'Color','k');
            title('Coverage path plan');
            xlabel('East (x)');
            ylabel('North (y)');
            hold on;
            k = best_antipodal_pair;
            scatter( M(A(i,1),1), M(A(i,1),2), sz, c(i), 'filled' );
            scatter( M(A(i,2),1), M(A(i,2),2), sz, c(i), 'filled' );

            plot(optimal_path(:,1), optimal_path(:,2), '-o');
            scatter(x_start, y_start, 25, 'filled');
            scatter(x_end, y_end, 25, 'filled');
            txt1 = ['cost = ', num2str(min_cost)];
            text(x_start,y_start,txt1);
            hold off;

    
    end
hold on
end
end
% hold off
daspect([1 1 1]);



    
