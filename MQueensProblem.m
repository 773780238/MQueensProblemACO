%% I. ��ջ�������
clear all
clc

tic ;


%% II. ��ʼ������
n = 100;                              % ���̸�����
N = sqrt(n);
m = 10;                              % ��������
alpha = 1.5;                           % ��Ϣ����Ҫ�̶�����
beta = 1.5;                            % ����������Ҫ�̶�����
rho = 0.4;                           % ��Ϣ�ػӷ�����
Q = 1;                               % ��ϵ��
Tau = ones(n,n);                     % ��Ϣ�ؾ���
Table = zeros(m,N);                  % ·����¼��
iter = 1;                            % ����������ֵ
iter_max = 200;                      % ���������� 
Route_best = zeros(iter_max,N);      % ������ѷ���˳��       
Collision_best = zeros(iter_max,1);     % �������·���ĳ�ͻ��  
Collision_ave = zeros(iter_max,1);      % ����·����ƽ����ͻ�� 

%% III. ����Ѱ�����·��
while iter <= iter_max
     % ��������������ϵ�������
      start = zeros(m,1);
      for i = 1:m
          temp = randperm(n);
          start(i) = temp(1);
      end
      Table(:,1) = start; 
      board_index = 1:n;
      Contradiction = zeros(m,1);
      % �������·��ѡ��
      for i = 1:m
          % ����ʺ�λ��ѡ��
         for j = 2:N
             tabu = Table(i,1:(j - 1));           % �ѷ��ʵ�λ�ü���(���ɱ�)
             allow_index = ~ismember(board_index,tabu);
             allow = board_index(allow_index);  % �����ʵ�λ�ü���
             P = allow;
             % �������̸��ת�Ƹ���
            
             for k = 1:length(allow)
                 P(k) = Tau(tabu(end),allow(k))^alpha;
             end
             contra =  Eta(tabu,allow,N);
             P = P .* ( 1./(contra+0.1)).^beta;
             P = P/sum(P);
             % ���̶ķ�ѡ����һ���������̸�
             Pc = cumsum(P);     
            target_index = find(Pc >= rand); 
            target = allow(target_index(1));
             % ��������i��εĳ�ͻ��
            Contradiction(i) = Contradiction(i) + contra(target_index(1));
            Table(i,j) = target;
         end
      end
     
      
     
      % ������С��ͻ��ƽ����ͻ
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
      % ������Ϣ��
      Delta_Tau = zeros(n,n);
      % ������ϼ���
      for i = 1:m
          % ����ʺ����
          for j = 1:(N - 1)
              Delta_Tau(Table(i,j),Table(i,j+1)) = Delta_Tau(Table(i,j),Table(i,j+1)) + Q/(Contradiction(i)+0.1);
          end
         
      end
      Tau = (1-rho) * Tau + Delta_Tau;
    % ����������1�����·����¼��
    iter = iter + 1;
    Table = zeros(m,N);
end
toc;
%% IV. �����ʾ
[Shortest_Length,index] = min(Collision_best);
Shortest_Route = Route_best(index,:);
disp(['��С��ͻ:' num2str(Shortest_Length)]);
disp(['����˳��:' num2str(Shortest_Route)]);

%% V. ��ͼ
figure(1)
plot(1:N,1:N);
grid on
for i=Shortest_Route
     row = floor((i-1)/N)+1;
     col = mod(i-1,N)+1;
     text(row,col,'��');
end

xlabel('������')
ylabel('������')
title(['��Ⱥ�㷨�Ż����̻ʺ�(��С��ͻ:' num2str(Shortest_Length) ')'])
figure(2)
plot(1:iter_max,Collision_best,'b',1:iter_max,Collision_ave,'r:')
legend('��С��ͻ','ƽ����ͻ')
xlabel('��������')
ylabel('��ͻ')
title('������С��ͻ��ƽ����ͻ�Ա�')