% FUNCTION: "driftness"
% Computes the matrix "driftness" and the vectors "in-" and "out-driftness".
function [D,in,out] = driftness(adj_matrix)

  N = size(adj_matrix,1);
  A = absorption(adj_matrix);
  SP = computeSP(adj_matrix);
  
  D = zeros(N,N);
  
  for i=1:N
    for j=1:(i-1)
      D(i,j) = A(i,j)/SP(i,j);
      D(j,i) = A(j,i)/SP(j,i);
    end
  end

  out = sum(D,2)/(N-1);
  in = sum(D,1)/(N-1);

end


