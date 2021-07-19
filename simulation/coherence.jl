include("src/main.jl")
include("simulate.jl")

resultspath = "simresults/data.jld"
plotpath = "../plots/blackouts"
CACHE = false

makegraphs = Dict(
    "star" => makestar,
    "path" => makepath,
    "binary" => makebinarytree
)

T = 150 # Simulation time
τ = 70 # Shock init
Δτ = 10 # Shock length
nodes = 7

lowε, highε = 0.5, 1.5
parameters = copy(default_params)

endowments = parameters[:ε]

parameters[:ε] = (first(endowments), (lowε, highε))

"""
Computes coherences across binary tree, path, and star of sizes ns and gets cumulative definicits with T and parameters
"""
function simulatedemanddeficits(ns, T, parameters; T₀=20)

    simresults = Dict(
        keys(makegraphs) .=> [
            zeros(length(ns), 3) for _ in 1:length(makegraphs)
        ]
    )
        
    for (gname, makeg) in makegraphs
        println("Simulation for $gname...")
        @threads for i in 1:length(ns)
            n = ns[i]

            if !isrepresentable(n) && gname == "binary"
                simresults[gname][i, :] = [NaN, NaN, NaN]
                continue
            end

            shocknode = gname == "path" ? n ÷ 2 : 1

            εpath = makeshock(n, shocknode, τ, τ + Δτ, lowε, highε)

            A, G = makeg(n) 
            simresults[gname][i, 1] = coherence(A, G)

            model = initializemodel(A, G, parameters; εpath=εpath)
            _, dfmodel = simulatemarket!(model; T=T)

            X = hcat(dfmodel.X...)'[T₀:end, :]
            ∑X = sum(X, dims=2)
            ∑Xₚ = @. positive(∑X) / n

            simresults[gname][i, 2] = mean(∑Xₚ)
            simresults[gname][i, 3] = std(∑Xₚ)
        end
    end


    return simresults
end

T = 250
T₀ = 150
ns = 3:127

results = isfile(resultspath) ? JLD.load(resultspath) : Dict()
excdemand = get(results, "excdemand", nothing)

if !CACHE || isnothing(excdemand) 

    excdemand = simulatedemanddeficits(ns, T, default_params; T₀=T₀)

    JLD.save(resultspath, "excdemand", excdemand)
else
    println("Using cached from $resultspath")
end

figρ = plotcoherences(excdemand, ns; savepath=joinpath(plotpath, "rhos.pdf"))

figblack = compareblackout(excdemand; savepath=joinpath(plotpath, "blackoutsim.pdf"))
