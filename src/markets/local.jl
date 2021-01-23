Prosumer = @with_kw (β = 0.99, 
                     ψ₁ = 0.9, ψ₂ = 1.1,
                     d = 1.,
                     u = x -> d * log(x),
                     u′ = x -> d / x)


weather = [.95 .05; .05 .95] 
prices = [.9 .1; .1 .9]   

transition = kron(weather, prices)
shocks = [(.5, .5); (1., .5); (.5, 1.); (1., 1.)]

Model = @with_kw (prosumer = Prosumer(),
                  nc = 100,                  
                  endchain = MarkovChain(transition, shocks), # State two: endowments
                  policy = range(0., 100., length=nc), # Control

                  n = nc * length(endchain.state_values),
                  states = gridmake(policy, endchain.state_values),
                  states_idx = gridmake(1:nc, 1:length(endchain.state_values)),

                  R = makereward!(fill(-Inf, n, nc), policy, states, prosumer),
                  Q = maketransition!(zeros(n, nc, n), states_idx, endchain))


model = Model()
prosumer_ddp = DiscreteDP(model.R, model.Q, model.prosumer.β)