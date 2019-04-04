using JuMP, Ipopt
##################
##using a 2-link arm for grinding, given the start and end position, also considering the size of the grinding pad, find the optimized 
##joint angles using objective functions:
##1. minimal time
##2. minimal control effor (sum of torques)
##assume link length is 1 and mass is 1 for both links
model = Model(with_optimizer(Ipopt.Optimizer,print_level = 0))

dt = 0.1 
steps = 40
final_x = 0.9 #final x position 
R = 0.01#radius of grinding tool 
y_l = (sqrt(3)+1)/2.0 - R
y_u = (sqrt(3)+1)/2.0 + R

@variables model begin
    theta[1:2, 1:steps]
    theta_dot[1:2, 1:steps]
    theta_ddot[1:2, 1:steps]
    var[1:2]
    x[1:steps]
    y[1:steps]
    tau[1:2, 1:steps]
    B[1:2, 1:2, 1:steps]#B matrix in EOM
    C[1:2, 1:steps]#C in EOM
end
#position, velocity and accelaration 
@constraint(model, [i=2:steps, j=1:2], theta_dot[j, i] == theta_dot[j, i-1] + theta_ddot[j, i-1]*dt)
@constraint(model, [i=2:steps, j=1:2], theta[j, i] == theta[j, i-1] + theta_dot[j, i-1]*dt)
#cartesian coordinates
@NLconstraint(model, [i=1:steps], x[i] == cosd(theta[1,i]) + cosd(theta[1,i]+theta[2,i]))
@NLconstraint(model, [i=1:steps], y[i] == sind(theta[1,i]) + sind(theta[1,i]+theta[2,i]))
#joint angle constraints
@constraint(model, [i=1:steps, j=1], -360.0 <= theta[j, i] <= 360.0)
@constraint(model, [i=1:steps, j=2],    0.0 <= theta[j, i] <= 180.0)
#joint velocity constraints
#@constraint(model, [i=2:steps],  0.0 <= theta_dot[2,i] <= 10.0) 
#@constraint(model, [i=2:steps],-20.0 <= theta_dot[1,i] <= 20.0) 
#joint accelaration constraints

#calculating torques
@NLconstraint(model, [i=1:steps], C[1, i] == -sind(theta[2, i])*(2*theta_ddot[1, i]*theta_ddot[2, i]+theta_ddot[2,i]^2))
@NLconstraint(model, [i=1:steps], C[2, i] == -sind(theta[2, i])*(theta_dot[1, i]*theta[2, i]))
@constraint(model, [i=1:steps, j=1:2], tau[j, i] == B[j, 1, i] * theta_ddot[1, i] + B[j, 2, i] * theta_ddot[2, i] + C[j,i])
#the object is to have smooth theta_dot
@constraint(model, [i=1:steps,j=1:2], var[j] == sum(theta_dot[j,:])/steps)#theta_dot average
#initial condition
@constraint(model, theta[:, 1] .== [30.0, 30.0]) 
@constraint(model, theta_dot[:, 1] .== [0.0, 0.0])
@constraint(model, theta_ddot[:, 1].== [0.0, 0.0])
#@constraint(model, theta[2, steps] == 70.0) #final condition # not using cuz only return all zero values 
#x is decreasing (otherwize won't be fast enough) and reaches the final position
@NLconstraint(model, abs(x[steps]-final_x)<=0.001)#final theta
#decrease in x 
@constraint(model, [i=2:steps], x[i] - x[i-1] <= 0.0)
#maintain y in a range
@NLconstraint(model, [i=1:steps], y_l <= y[i] <= y_u)
#objectives
#@objective(model, Min, sum((theta_dot[1, i]-var[1]).^2/steps for i in 1:steps))#min the vel variance in joint 1
#@objective(model, Min, sum((theta_dot[2, i]-var[2]).^2/steps for i in 1:steps))#min the vel variance in joint 2
@objective(model, Min, sum(tau[1, i]^2 + tau[2, i]^2 for i in 1:steps))
JuMP.optimize!(model)

#obj = JuMP.objective_value(model)
#println("Objective value $obj")
q1 = JuMP.value.(theta[1, :])
q2 = JuMP.value.(theta[2, :])
v1 = JuMP.value.(theta_dot[1, :])
v2 = JuMP.value.(theta_dot[2, :])
a1 = JuMP.value.(theta_ddot[1, :])
a2 = JuMP.value.(theta_ddot[2, :])
tau1 = JuMP.value.(tau[1,:])
tau2 = JuMP.value.(tau[2,:])
println(q1)
println(q2)
println(v1)
println(v2)
println(a1)
println(a2)
println(tau1)
println(tau2)
