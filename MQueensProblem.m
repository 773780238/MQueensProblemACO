%% I. 清空环境变量
clear all
clc

tic ;


%% II. 初始化参数
n = 100;                              % 棋盘格子数
N = sqrt(n);
m = 10;                              % 蚂蚁数量
alpha = 1.5;                           % 信息素重要程度因子
beta = 1.5;                            % 启发函数重要程度因子
rho = 0.4;                           % 信息素挥发因子
Q = 1;                               % 常系数
Tau = ones(n,n);                     % 信息素矩阵
Table = zeros(m,N);                  % 路径记录表
iter = 1;                            % 迭代次数初值
iter_max = 200;                      % 最大迭代次数 
Route_best = zeros(iter_max,N);      % 各代最佳放置顺序       
Collision_best = zeros(iter_max,1);     % 各代最佳路径的冲突率  
Collision_ave = zeros(iter_max,1);      % 各代路径的平均冲突率 

%% III. 迭代寻找最佳路径
while iter <= iter_max
     % 随机产生各个蚂蚁的起点城市
      start = zeros(m,1);
      for i = 1:m
          temp = randperm(n);
          start(i) = temp(1);
      end
      Table(:,1) = start; 
      board_index = 1:n;
      Contradiction = zeros(m,1);
      % 逐个蚂蚁路径选择
      for i = 1:m
          % 逐个皇后位置选择
         for j = 2:N
             tabu = Table(i,1:(j - 1));           % 已访问的位置集合(禁忌表)
             allow_index = ~ismember(board_index,tabu);
             allow = board_index(allow_index);  % 待访问的位置集合
             P = allow;
             % 计算棋盘格间转移概率
            
             for k = 1:length(allow)
                 P(k) = Tau(tabu(end),allow(k))^alpha;
             end
             contra =  Eta(tabu,allow,N);
             P = P .* ( 1./(contra+0.1)).^beta;
             P = P/sum(P);
             % 轮盘赌法选择下一个访问棋盘格
             Pc = cumsum(P);     
            target_index = find(Pc >= rand); 
            target = allow(target_index(1));
             % 计算蚂蚁i这次的冲突数
            Contradiction(i) = Contradiction(i) + contra(target_index(1));
            Table(i,j) = target;
         end
      end
     
      
     
      % 计算最小冲突及平均冲突
      if iter == 1
          [min_Contradiction,min_index] = min(Contradiction);
          Collision_best(iter) = min_Contradiction;  
          Collision_ave(iter) = mean(Contradiction);
          Route_best(iter,:) = Table(min_index,:);
      else
          [min_Contradiction,min_index] = min(Contradiction);
          Collision_best(iter) = min(Collision_best(iter - 1),min_Contradiction);
          Collision_ave(iter) = mean(Contradiction);
          if Collision_best(iter) == min_Contradiction
              Route_best(iter,:) = Table(min_index,:);
          else
              Route_best(iter,:) = Route_best((iter-1),:);
          end
      end
      % 更新信息素
      Delta_Tau = zeros(n,n);
      % 逐个蚂蚁计算
      for i = 1:m
          % 逐个皇后计算
          for j = 1:(N - 1)
              Delta_Tau(Table(i,j),Table(i,j+1)) = Delta_Tau(Table(i,j),Table(i,j+1)) + Q/(Contradiction(i)+0.1);
          end
         
      end
      Tau = (1-rho) * Tau + Delta_Tau;
    % 迭代次数加1，清空路径记录表
    iter = iter + 1;
    Table = zeros(m,N);
end
toc;
%% IV. 结果显示
[Shortest_Length,index] = min(Collision_best);
Shortest_Route = Route_best(index,:);
disp(['最小冲突:' num2str(Shortest_Length)]);
disp(['放置顺序:' num2str(Shortest_Route)]);

%% V. 绘图
figure(1)
plot(1:N,1:N);
grid on
for i=Shortest_Route
     row = floor((i-1)/N)+1;
     col = mod(i-1,N)+1;
     text(row,col,'皇');
end

xlabel('横坐标')
ylabel('纵坐标')
title(['蚁群算法优化棋盘皇后(最小冲突:' num2str(Shortest_Length) ')'])
figure(2)
plot(1:iter_max,Collision_best,'b',1:iter_max,Collision_ave,'r:')
legend('最小冲突','平均冲突')
xlabel('迭代次数')
ylabel('冲突')
title('各代最小冲突与平均冲突对比')