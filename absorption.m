% FUNCTION: "absorption"
% Computes the matrix "absorption" and the vectors "in-" and "out-absorption".
function [A,in,out]=absorption(adj_matrix)

  adj_matrix = adj_matrix';
  
  N = size(adj_matrix,1);  
  A = zeros(N,N);
  
  nrm = ones(N,1)*sum(adj_matrix,1);
  P = adj_matrix./nrm;       % this is T (the transition matrix)
  
  for node = 1:N
  
    W = P;
    W(:,node) = 0;    
    W(node,node) = 1;

    ii=[1:(node-1) (node+1):N];
    Q=W(ii,ii);
    R=W(node,ii);
    I=eye(size(Q));

    Nm=inv(I-Q);
    B=Nm'*ones(N-1,1);

    Be=zeros(N,1);
    Be(1:node-1)=B(1:node-1);
    Be(node)=0;
    Be((node+1):N)=B(node:(N-1));

    A(:,node)=Be;

  end
  %A = A';

  out = sum(A,2)/(N-1);
  in = sum(A,1)/(N-1);
  
end
