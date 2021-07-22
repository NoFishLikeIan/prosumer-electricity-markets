include("src/main.jl")
include("simulate.jl")

resultspath = "simresults/data.jld"
plotpath = "../plots/blackouts"
CACHE = true

makegraphs = Dict(
    "star" => makestar,
    "path" => makepath
)

T = 100 # Simulation time
τ = 10 # Shock init
Δτ = 10 # Shock length

lowε, highε = 2, 4.
parameters = copy(default_params)

endowments = parameters[:ε]

parameters[:ε] = (first(endowments), (lowε, highε))

"""
Computes coherences across binary tree, path, and star of sizes ns and gets cumulative definicits with T and parameters
"""
function simulatedemanddeficits(ns, T, parameters)

    simresults = Dict(
        keys(makegraphs) .=> [
            zeros(length(ns), 3) for _ in 1:length(makegraphs)
        ]
    )
        
    for (gname, makeg) in makegraphs
        println("Simulation for $gname...")
        @threads for i in 1:length(ns)
            n = ns[i]
            A, G = makeg(n)
            shockn = gname == "path" ? ceil(Int64, n / 2) : 1
            εpath = makeshock(n, shockn, τ, τ + Δτ, lowε, highε)

            simresults[gname][i, 1] = coherence(A, G)

            model = initializemodel(A, G, parameters; εpath=εpath)

            _, dfmodel = simulatefromsteady!(model; T=T)

            X = hcat(dfmodel.X...)'[τ + Δτ:end, :]
            ∑X = sum(X, dims=2)
            simresults[gname][i, 2] = count(∑X .> 0)
        end
    end
return simresults
end


results = isfile(resultspath) ? JLD.load(resultspath) : Dict()
excdemand = get(results, "excdemand", nothing)

ns = 5:60

if !CACHE || isnothing(excdemand) 

    excdemand = simulatedemanddeficits(ns, T, parameters)

    JLD.save(resultspath, "excdemand", excdemand)
else
    println("Using cached from $resultspath")
end

figρ = plotcoherences(excdemand, ns; savepath=joinpath(plotpath, "rhos.pdf"))

figblack = compareblackout(excdemand, ns; savepath=joinpath(plotpath, "blackoutsim.pdf"))
