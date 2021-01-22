
weather = [
    0.9 0.1;
    0.1 0.9
]

endowments = [0.0; 1.0]

function makereward!(R, policy, states, prosumer)
    
end

Prosumer = @with_kw (β = 0.99, 
                     ψ₁ = 0.9, ψ₂ = 1.1,
                     d = 1.,
                     u = x -> d * log(x),
                     u′ = x -> d / x)

Model = @with_kw (prosumer = Prosumer(),
                  endchain = MarkovChain(weather, endowments),
                  nt = 200,
                  tvalues = range(-10., 10., length=nt),
                  n = nt * length(endchain.state_values),
                  states = gridmake(tvalues, endchain.state_values),
                  states_idx = gridmake(1:nt, 1:length(endchain.state_values)),
                  R = makereward!(fill(-Inf, n, nt), tvalues, states))