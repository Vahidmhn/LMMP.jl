function LMMPSolver(A,b,C,d;XLB = [],XUB = [],CUTs = [],TimeLim = 2e+10,rEPS = 1e-10,aEPS = 1e-10)

    t0 = time_ns();
    # Initialization
    nObj = size(C)[1];
    nVar = size(A)[2];
    nCons = length(b);
    if XLB == []
        XLB = -1e9.*ones(nVar)
    end
    if XUB == []
        XUB = 1e9.*ones(nVar)
    end

    UB = Inf;
    const EPS = 0.00000001;

    # I1
    YI = zeros(nObj);
    Var = zeros(nVar);
    OptX = [];
    PayoffTable = zeros(nObj,nObj);
    for i = 1:nObj
        SingleObjModel = MakeModel(A,b,C,XLB,XUB,i,Cuts = CUTs);
        # Time commands
        # ----------------------------------------------------------------------
        if TimeLim - (time_ns() - t0)/1e9 < 0.001
            return [],[]
        end
        # ----------------------------------------------------------------------
        setsolver(SingleObjModel,CplexSolver(CPXPARAM_Threads = 1,CPXPARAM_ScreenOutput = 0, CPXPARAM_TimeLimit = TimeLim - (time_ns() - t0)/1e9));
        status = solve(SingleObjModel);
        # Time commands
        # ----------------------------------------------------------------------
        if TimeLim - (time_ns() - t0)/1e9 < 0.001
            return [],[]
        end
        # ----------------------------------------------------------------------


        if status != :Optimal
            return [],[]
        end
        YI[i] = getobjectivevalue(SingleObjModel) + d[i];
        PayoffTable[i,i]= YI[i] ;
        Var = getvalue(getvariable(SingleObjModel,:X))
        for j =1:nObj
            if j==i; continue; end
            PayoffTable[i,j] = sum(Var.*C[j,:]) + d[j];
        end
        if prod(PayoffTable[i,:]) < UB
            UB = prod(PayoffTable[i,:])
            OptX = Var;
        end
    end
    LB = prod(YI);

    MaxVals = maximum(PayoffTable,1);
    S = [VerticeType(YI,[i for i=2:nObj+1],[i for i=1:nObj],prod(YI))]
    temp = [i for i in 1:nObj+1];
    for i = 1:nObj
        point = copy(YI);
        point[i] = MaxVals[i];
        neighbors = copy(temp);
        neighbors = filter!(j -> j!=i+1 ,neighbors)
        Cuts = copy(temp);
        Cuts = filter!(j -> j!=i ,Cuts);
        T = prod(point);
        push!(S,VerticeType(point,neighbors,Cuts,T ))
    end

    Y = zeros(nObj);
    Var = zeros(nVar);
    CutNum = nObj + 1;
    while true
        # K1
        s = MinimalT2(S)[1];
        P_bar,U_cons,LAMBDA_cons = MakeP_bar(A,b,C,d,XLB,XUB,S[s].Point;Cuts = CUTs)

        # ----------------------------------------------------------------------
        if TimeLim - (time_ns() - t0)/1e9 < 0.001
            return [],[]
        end
        # ----------------------------------------------------------------------

        setsolver(P_bar,CplexSolver(CPXPARAM_Threads = 1,CPXPARAM_ScreenOutput = 0,CPXPARAM_TimeLimit = TimeLim - (time_ns() - t0)/1e9));

        status = solve(P_bar);
        # ----------------------------------------------------------------------
        if TimeLim - (time_ns() - t0)/1e9 < 0.001
            return [],[]
        end
        # ----------------------------------------------------------------------
        if status != :Optimal
            return [],[]
        end
        # U = getdual(U_cons);
        LAMBDA = getdual(LAMBDA_cons);
        # K2
        Var = getvalue(getVar(P_bar,:X))
        for j = 1:nObj
            Y[j] = sum(Var.*C[j,:]) + d[j];
        end
        if prod(Y) < UB
            UB = prod(Y)
            OptX = Var;
        end
        # K3
        if (abs(UB-LB) <= aEPS) || ((UB-LB)/UB <= rEPS); break; end
        # K4 & K5
        Cut = copy(LAMBDA);
        CutNum = CutNum + 1;
        push!(Cut,-1*sum(Y.*LAMBDA))

        if ~all(abs(Y-S[s].Point) .< EPS)
            S = Vert(deepcopy(S), Cut,CutNum)
        end
        if isempty(S)
            return -2,-2
        end
        LB = MinimalT2(S)[2];

        # println("LB = ",LB," | UB = ",UB)
        if (abs(UB-LB) <= aEPS) || ((UB-LB)/UB <= rEPS); break; end

    end
    return UB,OptX
end
