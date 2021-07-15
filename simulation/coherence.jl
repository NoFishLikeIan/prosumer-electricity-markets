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

function makeshock(n, T, from, to, params::Dict) 
    lowε, highε = last(params[:ε])
    makeshock(n, T, from, to, lowε, highε)
end
function makeshock(n, T, from, to, ε::Float64, εₛ::Float64)
    εpath = ε * ones(T + 1, n)
    εpath[from:to, 1] .=  εₛ 

    return εpath
end

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

            εpath = makeshock(n, T, T₀, T₀ + 5, parameters)

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
ns = 3:30

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