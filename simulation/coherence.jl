include("src/main.jl")
include("simulate.jl")

resultspath = "simresults/data.jld"
plotpath = "../plots/"
CACHE = true

makegraphs = Dict(
    "star" => makestar,
    "line" => makeline,
    # "binary" => makebinarytree
)


"""
Computes coherences across binary tree, line, and star of sizes ns and gets average price variance with T and parameters
"""
function simulatepricecoherence(ns, T, parameters)

    coherences = Dict(
        keys(makegraphs) .=> [
            zeros(length(ns), 2) for _ in 1:length(makegraphs)
        ]
    )
        
    for (gname, makeg) in makegraphs
        println("Simulation for $gname...")
        @threads for i in 1:length(ns)
            n = ns[i]
            A, G = makeg(n) 
            coherences[gname][i, 1] = coherence(A, G)

            model = initializemodel(A, G, parameters)
            dfagent, _ = simulatemarket!(model; T=T)

            σₚ = getpricevariance(dfagent, model)
            coherences[gname][i, 2] = maximum(σₚ)

        end
    end


    return coherences
end

results = isfile(resultspath) ? JLD.load(resultspath) : Dict()
cohvprices = get(results, "cohvprice", nothing)

if !CACHE || isnothing(cohvprices) 

    T = 150
    ns = 3:20 # map(ktoninbtree, 2:10)

    cohvprices = simulatepricecoherence(ns, T, default_params)

    JLD.save(resultspath, "cohvprice", cohvprices)
end
    
begin
    Plots.scalefontsizes(0.8); default(size=(1000, 800), margin=5Plots.mm) # Plotting defaults


    Plots.resetfontsizes()
end
