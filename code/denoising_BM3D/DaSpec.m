% function [group_labels, num_groups, omega_auto, V_picked] = DaSpec(x,omega)
function [num_groups, omega_auto] = DaSpec(x)
%Data Sepctroscopic clustering (DaSpec) algorithm
%  group_lables = DaSpec(x) performs the Data Spectroscopic clustering
%  algorithm with a Gaussian bandwidth chosen data-dependently. 
%  Rows of x correspond to points, columns correspond to variables.
%  The number of groups are determined by the algorithm and the group
%  labels are return.
%
%  [group_labels, num_groups, omega_auto, V_picked] = DaSpec(x) 
%  returns group labels, number of groups, the Guassian bandwidth 
%  omega determined by the algorithm, and the eigenvectors picked as 
%  no sign changes.
%



[N, P] = size(x);

% ---------------- compute distance matrix ---------------------
M = pdist(x,'euclidean');
M = squareform(M);

% ---------------- pick/take omega -----------------------------
if(nargin==1)
  perc_M = quantile(M,0.05);
  omega_auto = (quantile(perc_M,.95))/sqrt(chi2inv(0.95,P)); 
  disp(['Data-dependent choice of omega = ' num2str(omega_auto)]);
else
  omega_auto = omega;
end

% --------------- number of eigenvectors ------------------------
if(N<200)
  num_eig = N-1; 
else
  num_eig = max(floor(sqrt(N)), 200);
end

% --------------- find # of groups ------------------------------
K = exp(-M.^2/(2*omega_auto^2));
opts.disp = 0;
[V,~] = eigs(K,num_eig,'LM',opts);
t = max(abs(V)/N); a = max(V); b = min(V);
index_eig_vec = find((b>-t)|(a < t));  
num_groups = size(index_eig_vec,2);
disp([num2str(num_groups) ' groups are identified.']);

% % --------------- assign clustering labels ----------------------
% ind_mat = ones(N,1)*(1:num_groups);  
% V_abs = abs(V(:,index_eig_vec));
% V_abs_max = max(V_abs,[],2)*ones([1 num_groups]);
% diff_abs = ((V_abs_max-V_abs)==0);
% group_labels = sum(diff_abs.*ind_mat,2);
% if(nargout>3) 
%   V_picked = V(:,index_eig_vec);
% end

