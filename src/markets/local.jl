Prosumer = @with_kw (β = 0.99, 
                     ψ₁ = 0.9, ψ₂ = 1.1,
                     d = 1.,
                     u = x -> d * log(x),
                     u′ = x -> d / x)


weather = [0.9 0.1; 0.1 0.9]
endowments = [0.0; 1.0]

Model = @with_kw (prosumer = Prosumer(),
                  nc = 100,
                  np = nc ÷ 2, 
                  endchain = MarkovChain(weather, endowments), # State two: endowments
                  cvalues = range(0., 100., length=nc), # Control
                  pvalues = range(1., 10., length=np), # State one: prices

                  n = nc * np * length(endchain.state_values),
                  states = gridmake(cvalues, pvalues, endchain.state_values),
                  states_idx = gridmake(1:(nc * np), 1:length(endchain.state_values)),
                  R = makereward!(fill(-Inf, n, nc), cvalues, states, prosumer),
                  Q = maketransition!(zeros(n, nc * np, n), states_idx, endchain))


model = Model()