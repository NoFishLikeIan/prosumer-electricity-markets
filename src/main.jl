# -- Top level includes, they should only appear here
include("network/types.jl")
include("network/trophic.jl")
include("network/contagion.jl")

include("utils/plot.jl")
# --

using Random, Plots, Distributions
seed = 11148705
Random.seed!(seed)


n, p = 3, .99

A = adjacency_matrix(erdos_renyi(n, p, is_directed=true, seed=seed))
W = A .* rand(n, n)

g = SimpleWeightedDiGraph(W)

F0, levels = computeincoherence(g)

print("Coherence = ", 1 - F0, "\n\n")

N = nv(g)

x0 = ones(N)
r = rand(Uniform(0.5, 0.55), N)
κ = rand(Uniform(0.5, 0.55), N)

params = (collect(W), r, κ)

ds = ContinuousDynamicalSystem(evolve, SVector{N}(x0), params)
tr = trajectory(ds, 100)

T, N = size(tr)
t = collect(1:T)

plot(xaxis="t", yaxis="x", dpi=800)

for i in 1:N
    plot!(t, tr[:, i], label="$i")
end

savefig("test.png")

λ = eigvals(collect(W))

λ_sorted = sort(
    λ, lt=(x, y) -> real(x) == real(y) ? imag(x) < imag(y) : real(x) < real(y)
)

ρ = λ_sorted[end]

ρ_s = ρ / norm(W)

est = exp(0.5 * (1 - 1 / F0))
