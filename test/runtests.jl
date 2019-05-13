using LMMP
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

# write your own tests here
C = trunc.(Int,readdlm("C.txt"));
A = trunc.(Int,readdlm("A.txt"));
b = trunc.(Int,readdlm("b.txt"));
d = trunc.(Int,readdlm("d.txt"));

temp = LMMPSolver(A,b,C,d,XLB = zeros(400),XUB = ones(400))
@test temp[1] == 6256.816326530623
