function t = tree(K,costs,collective,counters,root)

  if nargin == 4 || nargin == 5
    % Set names
    t.names  = {};
    for i = 1:K
      t.names{i} = num2str(i);
    end

    t.K = K;
    t.collective = collective;
    t.counters   = counters;
    t.costs      = costs;
    t.branches = [];
    t.root = false;
    if nargin == 5
      t.root = root == true;
      t.path = zeros(1,0);
    end
  end

endfunction