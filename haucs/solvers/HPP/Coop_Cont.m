load optimal_path_1.mat;
load optimal_path_2.mat;
load optimal_path_3.mat;
% assigning Optimal paths
X1=optimal_path_1;
X2=optimal_path_2;
X3=optimal_path_3;

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
% title('Coverage path plan');
% xlabel('x');
% ylabel('y');
% hold on;

% Plot optimal paths on Polygon
% plot(optimal_path_1(:,1), optimal_path_1(:,2), '-o');
% scatter(X1_start, Y1_start, 25, 'filled');
% scatter(X1_end, Y1_end, 25, 'filled');
% hold on;
% plot(optimal_path_2(:,1), optimal_path_2(:,2), '-o');
% scatter(X2_start, Y2_start, 25, 'filled');
% scatter(X2_end, Y2_end, 25, 'filled');
% hold on;
% plot(optimal_path_3(:,1), optimal_path_3(:,2), '-o');
% scatter(X3_start, Y3_start, 25, 'filled');
% scatter(X3_end, Y3_end, 25, 'filled');


% Define Wind model = static wind vector (W) + non-static wind vector % (delta_w)
   W=[-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-15.803 12.258;-15.803 12.258;-15.803 12.258;-15.803 12.258;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742;-8.2176 6.3742];
  %W=zeros(18,2);
   % W=[-8.2176, 6.3742];
    %W=[-15; 20];
    % Magnitude
    Ax=1;
    Ay=1;
    %frequency
%     omega_x=
%     omega_y=
%     %phase
%     phi_x=
%     phi_y=
%     delta_w_x = Ax*sin(omega_x *t + phi_x);
%     delta_w_y = Ay*sin(omega_y *t + phi_y);
%     t=-pi:0.01:pi;
t=10;
%     delta_W=[sin(2*t); sin(3*t)];

% constants
    Kp=[1 0;0 1];    Ks=[1 0;0 1];   time=0.001;
%Plot shifted paths of UAVs
Path_1_1 = optimal_path_1(:,1)+ W(:,1);
Path_1_2 = optimal_path_1(:,2)+ W(:,2);
Path_1 = [Path_1_1 Path_1_2];

% Path_2_1 = optimal_path_2(:,1)+ W(1,1);
% Path_2_2 = optimal_path_2(:,2)+ W(2,1);
% Path_2 = [Path_2_1 Path_2_2];
% 
% Path_3_1 = optimal_path_3(:,1)+ W(1,1);
% Path_3_2 = optimal_path_3(:,2)+ W(2,1);
% Path_3 = [Path_3_1 Path_3_2];


plot(Path_1(:,1), Path_1(:,2), '-o');
scatter(X1_start, Y1_start, 25, 'filled');
scatter(X1_end, Y1_end, 25, 'filled');
% hold on;
% plot(Path_2(:,1), Path_2(:,2), '-o');
% scatter(X2_start, Y2_start, 25, 'filled');
% scatter(X2_end, Y2_end, 25, 'filled');
% hold on;
% plot(Path_3(:,1), Path_3(:,2), '-o');
% scatter(X3_start, Y3_start, 25, 'filled');
% scatter(X3_end, Y3_end, 25, 'filled');

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
for i=1:17
    
    
    DisPt_x = optimal_path_1(i,1)+ W(i,1) ;
    DisPt_y = optimal_path_1(i,2)+ W(i,2) ;
    
    S1 = optimal_path_1(i,1)- optimal_path_1(i+1,1);
    S2 = optimal_path_1(i,2)- optimal_path_1(i+1,2);
    
    S=[S1; S2];
    Wind = [W(i,1);W(i,2)];
    %Vq = -Kp.*S - W - (Ks.* sign(S)) + [10,20]';
    Vq = -Kp*S - Wind - (Ks* sign(S)) + [10,20]';
   speed(i)=norm(Vq);
%     angle(i)= tand(Vq);
%     V1(i,:)=[3.1416, 3.1416];
%     s = (V1(i,:)).^2 - 0 -(2*((V1(i,:)-0)/t));
       %s=V1(i,:).*time;
        s=speed(i).*time;
    Pos_1(i,:)=[DisPt_x; DisPt_y] + s;
    disp(i)
end

% Euler angles defining orientation of local axes
yaw = 0;
pitch = 0;
roll = 10;

% Create orientation matrix from Euler angles using quaternion class
q = quaternion([yaw pitch roll],'eulerd','zyx','frame');
myRotationMatrix = rotmat(q,'frame');

figure(2);
axis equal;
line([P1(:,1)';P1shifted(:,1)'],[P1(:,2)';P1shifted(:,2)'],'Color','k');
hold on;
plot(Pos_1(:,1), Pos_1(:,2), '-o');
hold on
scatter(X1_start, Y1_start, 25, 'filled');
hold on
scatter(X1_end, Y1_end, 25, 'filled');
hold on
scatter(800, 400, 25, 'filled');
hold off
    