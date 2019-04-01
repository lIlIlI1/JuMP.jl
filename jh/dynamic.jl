using JuMP, Ipopt
#example: https://github.com/rdeits/DynamicWalking2018.jl/blob/master/notebooks/6.%20Optimization%20with%20JuMP.ipynb
model = Model(with_optimizer(Ipopt.Optimizer,print_level = 0))

dt = 0.1 
steps = 20
max_acc = 0.5
@variables model begin
    position[1:2, 1:steps]
    velocity[1:2, 1:steps]
    -max_acc <= acc[1:2, 1:steps] <= max_acc
end
@constraint(model, [i=2:steps, j=1:2], velocity[j, i] == velocity[j, i-1] + acc[j, i-1]*dt)

@constraint(model, [i=2:steps, j=1:2], position[j, i] == position[j, i-1] + velocity[j, i-1]*dt)

@constraint(model, position[:, 1] .== [1, 0])
@constraint(model, velocity[:, 1] .== [0, -1])
@objective(model, Min, 100*sum(position[:, end].^2) + sum(velocity[:, end].^2))

JuMP.optimize!(model)

obj = JuMP.objective_value(model)
println("Objective value $obj")
q = JuMP.value.(position)
#v = JuMP.value(velocity)
#u = JuMP.value(acc)

println(q)
#println(v)
#println(u)