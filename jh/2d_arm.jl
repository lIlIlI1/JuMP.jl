using JuMP, Ipopt
##################
##let a 2-link arm move along the negative x direction, i.e. y maintain the same level, while x decreases with smooth velocity
model = Model(with_optimizer(Ipopt.Optimizer,print_level = 0))

dt = 0.1 
steps = 40
@variables model begin
    position[1:2, 1:steps]
    velocity[1:2, 1:steps]
    var[1:2]
    x[1:steps]
    y[1:steps]
end
# not consider acc now
#@constraint(model, [i=2:steps, j=1:2], velocity[j, i] == velocity[j, i-1] + acc[j, i-1]*dt)
#position integral
@constraint(model, [i=2:steps, j=1:2], position[j, i] == position[j, i-1] + velocity[j, i-1]*dt)
@constraint(model, [i=1:steps, j=1], -360.0 <= position[j, i] <= 360.0)
@constraint(model, [i=1:steps, j=2],    0.0 <= position[j, i] <= 180.0)
#cartesian coordinates
@NLconstraint(model, [i=1:steps], x[i] == cosd(position[1,i]) + cosd(position[1,i]+position[2,i]))
@NLconstraint(model, [i=1:steps], y[i] == sind(position[1,i]) + sind(position[1,i]+position[2,i]))
#@constraint(model, [i=2:steps],  0.0 <= velocity[2,i] <= 10.0) 
#@constraint(model, [i=2:steps],-20.0 <= velocity[1,i] <= 20.0) 
#the object is to have smooth velocity
@constraint(model, [i=1:steps,j=1:2], var[j] == sum(velocity[j,:])/steps)#velocity average
@constraint(model, position[:, 1] .== [30.0, 30.0]) #initial condition
@constraint(model, velocity[:, 1] .== [0.0, 0.0])
#maintain y 
@NLconstraint(model, [i=2:steps, j=2], abs(sind(position[1, i]) + sind(position[1, i] + position[2, i]) - (sqrt(3)+1)/2.0)<=0.001)
#decrease in x 
@constraint(model, [i=2:steps], x[i] - x[i-1] <= 0.0)
@objective(model, Min, sum((velocity[1, i]-var[1]).^2/steps for i in 1:steps))#min the vel variance in joint 1
@objective(model, Min, sum((velocity[2, i]-var[2]).^2/steps for i in 1:steps))#min the vel variance in joint 2
JuMP.optimize!(model)

#obj = JuMP.objective_value(model)
#println("Objective value $obj")
q1 = JuMP.value.(position[1, :])
q2 = JuMP.value.(position[2, :])
v1 = JuMP.value.(velocity[1, :])
v2 = JuMP.value.(velocity[2, :])

println(q1)
println(q2)
println(v1)
println(v2)
