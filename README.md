# LMMP

This Package solves a linear multiplicative problem using an algorithm introduced by Shao and Ehrgott [1]. This problem is formulated as follows:

$ min_{x, y} {prod_{i=1}^p  (y_i); y = Cx+d, Ax>=b, x,y>=0}  $

For more information, please refer to [1]. 

This package provides a function called LMMPSolver with four main arguments A, b, C, d which are the same matrices and vectors in the problem. For example:

LMMPSolver(A,b,C,d)

The bounds of the variable x can be both expressed through constraint Ax>=b or using key arguments XLB and XUB which stand for x's lower bound and x's upper bound, respectiely. Ex.:

LMMPSolver(A,b,C,d, XLB = zeros(nVar), XUB = ones(nVar)) which bounds the x between zero and one, where nVar is the size of the variable x. Default values for these bounds are -1e9 and 1e9, respectively. 

Similar to all other algorithms, there are conditions which control the termination of this algorithm. Key arguments TimeLim, rEPS, and aEPS determine the time limit, relative, and absolute optimality gap by which the algorithm will stop and return the best found solution instead of optimal solution. Default value of these parameters is 2e+10, 1e-10, and 1e-10, respectively. 

Please cite the following papers if you use this package:

[1] Shao, Lizhen, and Matthias Ehrgott. "Primal and dual multi-objective linear programming algorithms for linear multiplicative programmes." Optimization 65.2 (2016): 415-431.

[2]


