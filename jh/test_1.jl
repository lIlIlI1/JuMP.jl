using JuMP
using CPLEX

m = Model(solver = CplexSolver())

@variable(m,x1>=2,Int)
@variable(m,x2>=1)

@constraint(m,myconst,2*x1+3*x2>=6)

@objective(m,Min,x1+x2)

status = solve(m)


obj = getobjectivevalue(m)
println("Objective value $obj")
x1val = getvalue(x1)
x2val = getvalue(x2)

run_time = getsolvetime(m)

println(m)

#look up the command "sum" in JuMP
