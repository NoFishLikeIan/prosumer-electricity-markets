# -- Top level includes, they should only appear here
include("network/types.jl")
include("network/trophic.jl")
include("network/simulate.jl")
include("dynamics/lotkavolterra.jl")

include("utils/plot.jl")
# --

using Random, Plots, Distributions
seed = 11148705
Random.seed!(seed)


N, p = 10, .5

r = rand(Uniform(0.5, 0.55), N)
κ = rand(Uniform(0.5, 0.55), N)

ds, g = dynamicsonerdos(
    N, p,
    lv_evolve,
    (r, κ)
)

tr = trajectory(ds, 100)

T, N = size(tr)
t = collect(1:T)

plot(xaxis="t", yaxis="x", dpi=800)

for i in 1:N
    plot!(t, tr[:, i], label="$i")
end

savefig("plots/lv-dynamics.png")
