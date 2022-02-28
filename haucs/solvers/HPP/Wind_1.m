load optimal_path_1.mat;
load optimal_path_2.mat;
load optimal_path_3.mat;
% assigning Optimal paths
X1=optimal_path_1;
X2=optimal_path_2;
X3=optimal_path_3;
 Lp = 0.5;  % Length of each part between two waypoints.

% Define polygon
P1=[0 0;0 370;740 370; 740 0]; P1shifted=[0 370;740 370;740 0;0 0];
P2=[0 370;0 745;740 745;740 370]; P2shifted=[0 745;740 745;740 370;0 370];
P3=[740 0;740 370;740 745;1320 745]; P3shifted=[740 370;740 745;1320 745;740 0];

X1_start=-5; Y1_start=0; X1_end=740; Y1_end=370; Home_1=[740 370];
X2_start=0;Y2_start=746;X2_end=0;Y2_end=750;
X3_start=742;Y3_start=0;X3_end=1321;Y3_end=746;

% Plot polygon
axis equal;
line([P1(:,1)';P1shifted(:,1)'],[P1(:,2)';P1shifted(:,2)'],'Color','k');
hold on;
% line([P2(:,1)';P2shifted(:,1)'],[P2(:,2)';P2shifted(:,2)'],'Color','k');
% hold on;
% line([P3(:,1)';P3shifted(:,1)'],[P3(:,2)';P3shifted(:,2)'],'Color','k');
title('Coverage path plan');
xlabel('x');
ylabel('y');
hold on;
% Plot optimal paths on Polygon
plot(optimal_path_1(:,1), optimal_path_1(:,2), '-o');
scatter(X1_start, Y1_start, 25, 'filled');
scatter(X1_end, Y1_end, 25, 'filled');
hold on;
% plot(optimal_path_2(:,1), optimal_path_2(:,2), '-o');
% scatter(X2_start, Y2_start, 25, 'filled');
% scatter(X2_end, Y2_end, 25, 'filled');
% hold on;
% plot(optimal_path_3(:,1), optimal_path_3(:,2), '-o');
% scatter(X3_start, Y3_start, 25, 'filled');
% scatter(X3_end, Y3_end, 25, 'filled');

%Distance between waypoints in path
        D1=zeros(1000,2); xy1=zeros(102,2);      % UAV 1
        for i=1:17  
           p = X1(i,:);
           q = X1(i+1,:);
           dc1=sqrt(((q(1,1)-p(1,1))^2)+((q(1,2)-p(1,2))^2)); 
          n=5; %n=dc1/Lp; 
           t = linspace(0,1,n+1)';
           %xy= (1-t).*p + t.*q;
            for j=i
%                 xy(j:j+5,:)= (1-t).*p + t.*q;
%                 D1(j:j+5,:)=xy(j:j+5,:);
                if j==1
                    xy1(1:6,:)=(1-t).*p + t.*q;
                elseif j==2
                    xy1(7:12,:)=(1-t).*p + t.*q;
                elseif j==3
                    xy1(13:18,:)=(1-t).*p + t.*q;
                elseif j==4
                    xy1(19:24,:)=(1-t).*p + t.*q;
                elseif j==5
                    xy1(25:30,:)=(1-t).*p + t.*q;
                elseif j==6
                    xy1(31:36,:)=(1-t).*p + t.*q;
                elseif j==7
                    xy1(37:42,:)=(1-t).*p + t.*q;
                elseif j==8
                    xy1(43:48,:)=(1-t).*p + t.*q;
                elseif j==9
                    xy1(49:54,:)=(1-t).*p + t.*q;
                elseif j==10
                    xy1(55:60,:)=(1-t).*p + t.*q;
                elseif j==11
                    xy1(61:66,:)=(1-t).*p + t.*q;
                elseif j==12
                    xy1(67:72,:)=(1-t).*p + t.*q;
                elseif j==13
                    xy1(73:78,:)=(1-t).*p + t.*q;
                elseif j==14
                    xy1(79:84,:)=(1-t).*p + t.*q;
                elseif j==15
                    xy1(85:90,:)=(1-t).*p + t.*q; 
                elseif j==16
                    xy1(91:96,:)=(1-t).*p + t.*q;
                elseif j==17
                    xy1(97:102,:)=(1-t).*p + t.*q;
                end
                    
            end
           
         
        end
       plot(xy1(:,1),xy1(:,2),'b-o')
        hold on;
        D2=zeros(9,1); xy2=zeros(48,2);     %UAV 2
%         for i=1:9
%            p = X2(i,:);
%            q = X2(i+1,:);
%            dc1=sqrt(((q(1,1)-p(1,1))^2)+((q(1,2)-p(1,2))^2)); 
%            n=5; %n=dc1/Lp; 
%            t = linspace(0,1,n+1)';
%            %xy= (1-t).*p + t.*q;
%             for j=i
% %                 xy(j:j+5,:)= (1-t).*p + t.*q;
% %                 D1(j:j+5,:)=xy(j:j+5,:);
%                 if j==1
%                     xy2(1:6,:)=(1-t).*p + t.*q;
%                 elseif j==2
%                     xy2(7:12,:)=(1-t).*p + t.*q;
%                 elseif j==3
%                     xy2(13:18,:)=(1-t).*p + t.*q;
%                 elseif j==4
%                     xy2(19:24,:)=(1-t).*p + t.*q;
%                 elseif j==5
%                     xy2(25:30,:)=(1-t).*p + t.*q;
%                 elseif j==6
%                     xy2(31:36,:)=(1-t).*p + t.*q;
%                 elseif j==7
%                     xy2(37:42,:)=(1-t).*p + t.*q;
%                 elseif j==8
%                     xy2(43:48,:)=(1-t).*p + t.*q;
%                 end
%                     
%             end
%         end
%         plot(xy2(:,1),xy2(:,2),'r-o')
%         hold on;
%         
%         D3=zeros(13,1);xy3=zeros(60,2);     %UAV 3
%         for i=1:13
%            p = X3(i,:);
%            q = X3(i+1,:);
%            dc1=sqrt(((q(1,1)-p(1,1))^2)+((q(1,2)-p(1,2))^2)); 
% %            D3(i,:)=dc1;
%            n=5; %n=dc1/Lp; 
%            t = linspace(0,1,n+1)';
%            %xy= (1-t).*p + t.*q;
%             for j=i
% %                 xy(j:j+5,:)= (1-t).*p + t.*q;
% %                 D1(j:j+5,:)=xy(j:j+5,:);
%                 if j==1
%                     xy3(1:6,:)=(1-t).*p + t.*q;
%                 elseif j==2
%                     xy3(7:12,:)=(1-t).*p + t.*q;
%                 elseif j==3
%                     xy3(13:18,:)=(1-t).*p + t.*q;
%                 elseif j==4
%                     xy3(19:24,:)=(1-t).*p + t.*q;
%                 elseif j==5
% %                     xy3(25:30,:)=(1-t).*[0 0] + t.*[0 0];
% % %                     xy3(25:30,:)=[0 0;0 0;0 0;0 0;0 0;0 0];
%                         continue
%                 elseif j==6
%                     xy3(25:30,:)=(1-t).*p + t.*q;
%                 elseif j==7
%                     xy3(31:36,:)=(1-t).*p + t.*q;
%                 elseif j==8
%                     xy3(37:42,:)=(1-t).*p + t.*q;
%                 elseif j==9
%                     %xy3(49:54,:)=(1-t).*[0 0] + t.*[0 0];
% %                     xy3(49:54,:)=[0 0;0 0;0 0;0 0;0 0;0 0];
%                         continue
%                 elseif j==10
%                     xy3(43:48,:)=(1-t).*p + t.*q;
%                 elseif j==11
%                     xy3(49:54,:)=(1-t).*p + t.*q;
%                 elseif j==12
%                     xy3(55:60,:)=(1-t).*p + t.*q;
%                 end
%             end
%         end
%         plot(xy3(:,1),xy3(:,2),'g-o')
% 
% % Define Wind model = static wind vector (W) + non-static wind vector % (delta_w)
%    %W=[-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-15.803 12.258;-15.803 12.258;-15.803 12.258;-15.803 12.258;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742];
%   %W=zeros(18,2);
%    
 
%Plot shifted paths of UAVs
% Path_1_1 = optimal_path_1(:,1)+ W(:,1);
% Path_1_2 = optimal_path_1(:,2)+ W(:,2);
% Path_1 = [Path_1_1 Path_1_2];
% 
% plot(Path_1(:,1), Path_1(:,2), '-o');
% scatter(X1_start, Y1_start, 25, 'filled');
% scatter(X1_end, Y1_end, 25, 'filled');


%Assiging initial velocities of 3 UAVs, Vq
   %V1=zeros(height(Path_1),2);
    V1=zeros(17,2);
   %Pos_1 = zeros(height(Path_1),2);
   Pos_1 = zeros(17,2);
 % Assiging disturbed points in x and y
    %DisPt=zeros(height(Path_1),2);
    DisPt=zeros(17,2);
% Assigning Sliding surface or position error
    
% Define control laws 
speed = zeros(18,1); angle = zeros(18,1);
W=[10, -20]; 
Wind = [W(1,1);W(1,2)];
% constants
    Kp=[1 0;0 1];    Ks=[1 0;0 1];   time=0.005;
for i=1:17
    
   if i==5
    
    DisPt_x = optimal_path_1(i,1)+ W(1,1) ;
    DisPt_y = optimal_path_1(i,2)+ W(1,2) ;
   else
    DisPt_x = optimal_path_1(i,1);
    DisPt_y = optimal_path_1(i,2);
   end
    
    S1 = optimal_path_1(i,1)- optimal_path_1(i+1,1);    
%     S1 = xy1(i,1)-xy1(i+1,1);
    S2 = optimal_path_1(i,2)- optimal_path_1(i+1,2);    
%     S2 = xy1(i,2)-xy1(i+1,2);
    
    S=[S1; S2];
    Wind = [W(1,1);W(1,2)];
    %Vq = -Kp.*S - W - (Ks.* sign(S)) + [10,20]';
    Vq = -Kp*S - Wind - (Ks* sign(S)) + [10,20]';
    Vq_1=Vq+Wind;
   speed(i)=norm(Vq);
%     angle(i)= tand(Vq);
%     V1(i,:)=[3.1416, 3.1416];
%     s = (V1(i,:)).^2 - 0 -(2*((V1(i,:)-0)/t));
       %s=V1(i,:).*time;
        s=speed(i).*time;
    Pos_1(i,:)=[DisPt_x; DisPt_y] + s;
    disp(i)
end

%W=[-8.2176, 6.3742]; 
% W=[10, -20]; 
% Wind = [W(1,1);W(1,2)];
% Wind=0;
                                        %         x = (0:0.01:2);
                                        %         p = raylpdf(x,0.5);
% figure(3);
% plot(x,p)

% constants
%     Kp=[1 0;0 1];    Ks=[1 0;0 1];   time=0.05;

% for i=1:(height(xy1)-1)  % Working
%     
%     S1 = xy1(i,1)-xy1(i+1,1);
%     S2 = xy1(i,2)-xy1(i+1,2);    
%     S=[S1; S2];
%     
%     
%     for j=i:(height(xy1)-1)
%         %Vq = -Kp.*S - W - (Ks.* sign(S)) + [10,20]';
%         
%          if j~=16               %at other waypoints, Wind = 0
%             Vq = -Kp*S - Wind - (Ks* sign(S)) + [10,20]';
%             Vq_1 = Vq + [0;0];          % Unknown wind vector
%             %speed(j)=norm(Vq_1);
%             %s=speed(j).*time;
%             s=Vq_1.*time;
%             Pos_1(j,:)=[xy1(j,1); xy1(j,2)] + s;
%             
%          
%         
%         else
%             Vq = -Kp*S - Wind - (Ks* sign(S)) + [10,20]';
%             Vq_1 = Vq + Wind;
% %             speed(j)=norm(Vq_1);           
% %             s=speed(j).*time;
%             s=Vq_1.*time;
%             Pos_1(j,:)=[xy1(j,1); xy1(j,2)] + s;
%         end
%         %disp(i)
%     end
% end
% Euler angles defining orientation of local axes
yaw = 0;
pitch = 0;
roll = 10;

% Create orientation matrix from Euler angles using quaternion class
q = quaternion([yaw pitch roll],'eulerd','zyx','frame');
myRotationMatrix = rotmat(q,'frame');

                                        % figure(2);
                                        % axis equal;
                                        % line([P1(:,1)';P1shifted(:,1)'],[P1(:,2)';P1shifted(:,2)'],'Color','k');
                                        % hold on;
                                        % plot(xy1(:,1), xy1(:,2), 'g-o');
                                        % scatter(X1_start, Y1_start, 25, 'filled');
                                        % scatter(X1_end, Y1_end, 25, 'filled');
                                        % hold on;
                                        % plot(Pos_1(:,1), Pos_1(:,2), 'b-o');
                                        % hold on
                                        % scatter(X1_start, Y1_start, 25, 'filled');
                                        % hold on
                                        % scatter(X1_end, Y1_end, 25, 'filled');
                                        % hold on
                                        % % scatter(800, 400, 25, 'filled');
                                        % hold off

% Error = zeros(101,2);
% for i=1:101
%    Error(i,:) = xy1(i,:)-Pos_1(i,:); 
%    Error_1 = Error(:,1);
% end
%    t1=(1:1:101)';
%    figure(3)
%    plot(t1,Error_1);