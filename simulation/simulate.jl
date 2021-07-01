function simulatemarket(model; adata=[:pos, :p, :r, :ε, :s, :b, :a],  mdata=[:X, :R], T=100)

    dfagent, dfmodel = run!(model, agent_step!, model_step!, T;adata, mdata)

    return dfagent, dfmodel
end