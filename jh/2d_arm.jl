using JuMP, Ipopt

model = Model(with_optimizer(Ipopt.Optimizer,print_level = 0))

dt = 0.1 
steps = 40
#max_acc = 0.5
@variables model begin
    #-360.0 <= position[1, 1:steps] <= 360.0
       #0.0 <= position[2, 1:steps] <= 360.0
    position[1:2, 1:steps]
    velocity[1:2, 1:steps]
    #-max_acc <= acc[1:2, 1:steps] <= max_acc
    #acc[1:2, 1:steps]
end
#@constraint(model, [i=2:steps, j=1:2], velocity[j, i] == velocity[j, i-1] + acc[j, i-1]*dt)

@constraint(model, [i=2:steps, j=1:2], position[j, i] == position[j, i-1] + velocity[j, i-1]*dt)
@constraint(model, [i=1:steps, j=1], -360.0 <= position[j, i] <= 360.0)
@constraint(model, [i=1:steps, j=2],    0.0 <= position[j, i] <= 180.0)
#@constraint(model, [i=2:steps, j=2], position[j, i] >= position[j, i-1])
@constraint(model, [i=2:steps], 0.0 <= velocity[2,i] <= 10.0) 

@constraint(model, position[:, 1] .== [30.0, 30.0]) #initial condition
@constraint(model, velocity[:, 1] .== [0.0, 0.0])
@NLconstraint(model, [i=2:steps, j=2], abs(sind(position[1, i]) + sind(position[1, i] + position[2, i]) - (sqrt(3)+1)/2.0)<=0.001)


#@NLobjective(model, Min, sum(abs(sind(position[1, i]) + sind(position[1, i] + position[2, i]) - (sqrt(3)+1)/2.0) for i in 1:steps) )
@NLobjective(model, Max, cosd(position[1,end]) + cosd(position[1,end]+position[2,end]) - (cosd(position[1,1]) + cosd(position[1,1]+position[2,1])) )

JuMP.optimize!(model)

obj = JuMP.objective_value(model)
#println("Objective value $obj")
q1 = JuMP.value.(position[1,:])
q2 = JuMP.value.(position[2,:])
#v = JuMP.value(velocity)
#u = JuMP.value(acc)

println(q1)
println(q2)
#println(v)
#println(u)