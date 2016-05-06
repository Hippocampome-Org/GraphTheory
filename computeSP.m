function [ SP ] = computeSP( adj_matrix )
% Computes the length of the shortest paths between all pairs of vertices.
  N = size(adj_matrix,1);
  SP = adj_matrix;

  for i=1:N
    for j=1:(i-1)
      if (SP(i,j)==0)
        SP(i,j)=inf;
      end
      if (SP(j,i)==0)
        SP(j,i)=inf;
      end
    end
  end

  for k=1:N
    for i=1:N
      for j=1:N
        if (SP(i,j) > SP(i,k) + SP(k,j)) 
          SP(i,j) = SP(i,k) + SP(k,j);
        end
      end
    end
  end
  
  for i=1:N
      if (adj_matrix(i,i)==1)
          SP(i,i) = 0;
      else
          SP(i,i) = 2;
      end
  end

end    

