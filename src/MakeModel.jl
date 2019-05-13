function MakeModel(A,b,C,XLB,XUB,ObjInd;Cuts = [])
    m,n = size(A);
    ObjNum = size(C)[1];
    MyModel = Model();
    @variable(MyModel, XLB[i] <= X[i=1:n] <= XUB[i])
    @objective(MyModel, Min, sum(C[ObjInd,i]*X[i] for i=1:n))
    for i = 1:m
        @constraint(MyModel,sum(A[i,j]*X[j] for j = 1:n) >= b[i] )
    end
    # for c = 1:length(Cuts)
    #     @constraint(MyModel,sum(Cuts[c].Coeff[i]*(sum(C[i,j]*X[j] for j = 1:n )+d[i])  for i = 1:ObjNum) >= Cuts[c].RHS)
    # end
    return MyModel;
end
