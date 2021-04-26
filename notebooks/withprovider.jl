### A Pluto.jl notebook ###
# v0.14.3

using Markdown
using InteractiveUtils

# ╔═╡ 9fa7b26b-2106-4891-826a-ffb3792fa5e7
using Distributions, Plots, FiniteDifferences, Roots

# ╔═╡ af6628dd-7fda-4335-8c47-fd90b4393224
using Random; Random.seed!(11148705)

# ╔═╡ fb99a1b9-8b9d-4b5f-aed9-88ffbebc27d6
using PlutoUI

# ╔═╡ 9e5aa96c-a673-11eb-3a45-a1dc9e62b892
include("../src/main.jl")

# ╔═╡ 42870f7a-2ec0-4344-ab35-4829b4766e99
∂ = central_fdm(12, 1) # Numerical derivative

# ╔═╡ e4002429-35cf-4c4b-be91-a2a98e330c7a
md"""

Problem with an unlimited provider of electricity at cost $c$, such that the optimum of the firm is,

$X^\prime (p) \cdot (p - c) + X(p) = 0$
"""

# ╔═╡ d8f89d01-a868-4a44-8545-11c32127718d
begin
	pros = Prosumer(ψ₁=0.95, ψ₂=1.01)
	env = Environment(ω=0.3, γ=0.5)
	grid = (600, 100)

	pess, opt = solvepolicy(grid, pros, env; verbose = true)
end

# ╔═╡ ee5c391c-bf58-466f-bf38-2d1a7ca030ba
begin
	N = 10
	pessimists = 5
	optimists = N - pessimists
	policies = vcat(repeat([pess], pessimists), repeat([opt], optimists))
	
	m = rand(Uniform(0., 10.), N)
end

# ╔═╡ 575d0dfd-fcac-41d3-9971-846cf9180f47
function makedemand(e)
	function X(p)
		m′ = [policies[i](m[i], p, e) for i in 1:N] # Apply each policy 
		x = @. (m - m′) / p # Demand
		return sum(x)
	end
end

# ╔═╡ e75d01df-c9de-4d1c-93e4-e2c976f7aa6d
begin
	title = "Aggregate demand for low and high endowments"
	fig = plot(xlabel = "p", ylabel="X(p)", dpi = 200, title=title, ylims=(-20, 20))

	prices = -6.0:0.05:6.0
	
	
	for e in 0.5:0.2:1.1
		X = makedemand(e)
		plot!(fig, prices, X, label="e = $e")
	end
	fig	
end

# ╔═╡ 15f0425b-7d49-472a-a3b2-613f56296416
function Λ(c, e)
	X = makedemand(e)
	X′(p) = ∂(X, p)
	
	return p -> X′(p)*(p-c) + X(p)
end

# ╔═╡ 4c37dc54-0370-4c52-8e5b-9e755b001b04
function p̄(c, e)
	try
		return find_zero(Λ(c, e), c)
	catch InexactError 
		print("Error with c=$c and e=$e")
		return NaN
	end
end

# ╔═╡ 687808ff-7a77-4e51-8a6d-6c7c55c54ae8
begin
	
	endfig = plot(
		xlabel="costs", ylabel="price",
		legend = :bottomright, title="Equilibrium price with low endowments",
		dpi = 200, ylim = (-2, 5)
	)
	
	for e in 0.2:0.05:0.35
	
		plot!(endfig, range(-1.0, 1.0, length=100), c -> p̄(c, e), label="e = $e")
	end
	
	endfig
end

# ╔═╡ 22ac0c29-625f-426c-bfde-8b0335619077


# ╔═╡ Cell order:
# ╠═9e5aa96c-a673-11eb-3a45-a1dc9e62b892
# ╠═9fa7b26b-2106-4891-826a-ffb3792fa5e7
# ╠═af6628dd-7fda-4335-8c47-fd90b4393224
# ╠═fb99a1b9-8b9d-4b5f-aed9-88ffbebc27d6
# ╠═42870f7a-2ec0-4344-ab35-4829b4766e99
# ╟─e4002429-35cf-4c4b-be91-a2a98e330c7a
# ╠═d8f89d01-a868-4a44-8545-11c32127718d
# ╠═ee5c391c-bf58-466f-bf38-2d1a7ca030ba
# ╠═575d0dfd-fcac-41d3-9971-846cf9180f47
# ╠═e75d01df-c9de-4d1c-93e4-e2c976f7aa6d
# ╠═15f0425b-7d49-472a-a3b2-613f56296416
# ╠═4c37dc54-0370-4c52-8e5b-9e755b001b04
# ╟─687808ff-7a77-4e51-8a6d-6c7c55c54ae8
# ╠═22ac0c29-625f-426c-bfde-8b0335619077
