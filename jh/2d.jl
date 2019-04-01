using JuMP, Ipopt
#not finished, not using
function test(; verbose = true)
    #define a time series like solving ODE in Matlab?
    model = Model(with_optimizer(Ipopt.optimizer, print_level = 0))
    @variable(model, t, 0.0 <= t <= 5.0)
    @variable(model, theta1_dot, start = 0.0)
    @variable(model, theta2_dot, start = 0.0)
    theta1 = Float64[]
    @expression(model, theta1, theta1_dot + theta1, 30.0)
    @variable(model, theta2, start = 30.0)

    @NLobjective(model, min, )