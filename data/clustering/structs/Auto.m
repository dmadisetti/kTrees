function Auto = Auto()

  Auto.activated = false;
  Auto.threshold = Inf;
  Auto.decision  = -1;
  Auto.current   = -1;
  Auto.LB = -1;
  Auto.UB = -1;
  Auto.lb = -1;
  Auto.ub = -1;
  Auto.K  = -1;
  Auto.depth = 0;
  Auto.count = [1];

endfunction