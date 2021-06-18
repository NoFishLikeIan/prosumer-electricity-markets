### A Pluto.jl notebook ###
# v0.14.3

using Markdown
using InteractiveUtils

# ╔═╡ 41809916-cea7-11eb-2af5-8b37c6dbd767
using Plots, DataFrames, InteractiveDynamics

# ╔═╡ c0cf7f69-a656-4bc0-9c24-ad3dc0f31f36
using Agents

# ╔═╡ 40dc6db5-7b14-4150-89cc-ca27992a4b7c
Plots.resetfontsizes(); Plots.scalefontsizes(0.8)

# ╔═╡ 3e067f0a-f882-421a-bdb0-bc4915aa5b35
plotpath = "../plots/energy"

# ╔═╡ 849288c9-0b47-4fda-b8a6-1fe7e93c3c67
begin
	c₀, c₁ = 2.0, 0.8
	
	c(s, r) = log(1 + exp(c₁*s*r - c₀))
	
	∇c(s, r) = c₁ * inv(1 + exp(c₀ - s*r))
	
	∂c∂s(s, r) = ∇c(s, r) * r
	∂c∂r(s, r) = ∇c(s, r) * s
end

# ╔═╡ 56518671-93c3-4b12-9089-1859cfe6cb01
begin
	A = [
		0 1 1 1;
		1 0 0 0;
		1 0 0 0;
		1 0 0 0;
	]
	
	ε = (
		[0.99 0.01; 0.01 0.99],
		[-10.0, 10.0]
	)

	parameters = Dict(
		:c => c, :c′ => (∂c∂s, ∂c∂r),
		:Ψ => [0.9, 1.1],
		:M => 100, :ε => ε,
		:N => 5, :β => 0.99
	)
	b₀ = -1
end

# ╔═╡ b389c106-600b-44dc-a861-d1abcefa6353
begin
	fixeds = 4.0
	r = range(-fixeds, fixeds, length = 100)
	
	fnfig = plot(r, x -> c(fixeds, x),
		ylims = (0., 10.), xlabel = "r", ylabel="c",
		c = :red,
		title = "costs with s = $fixeds; c₀ = $c₀, c₁ = $c₁", label = false)
	
	derfig = plot(
		r, x -> ∂c∂r(fixeds, x),
		ylims = (0., 10.),xlabel = "r",ylabel="∂c/∂r",
		c = :red,
		title = "derivative of marginal costs with s = $fixeds; c₀ = $c₀, c₁ = $c₁", label = false)
	
	jointcosts = plot(fnfig, derfig, size = (1200, 400))
	
	savefig(jointcosts, joinpath(plotpath, "cost.pdf"))
	
	jointcosts
	
end

# ╔═╡ 248bddf9-bfc1-42df-b35d-43035bf64e84
model = initializemodel(A, parameters; b₀ = b₀)

# ╔═╡ 59da17f2-caef-45ad-8696-35608bc327d2
if false
	T = 100
	adata = [:pos, :p, :r, :Ep, :ε, :ψ, :s]
	mdata = []

	dfagent, dfmodel = run!(model, agent_step!, model_step!, T; adata, mdata)
	println("Done!")
end

# ╔═╡ Cell order:
# ╠═41809916-cea7-11eb-2af5-8b37c6dbd767
# ╠═40dc6db5-7b14-4150-89cc-ca27992a4b7c
# ╠═c0cf7f69-a656-4bc0-9c24-ad3dc0f31f36
# ╟─3e067f0a-f882-421a-bdb0-bc4915aa5b35
# ╠═849288c9-0b47-4fda-b8a6-1fe7e93c3c67
# ╟─56518671-93c3-4b12-9089-1859cfe6cb01
# ╟─b389c106-600b-44dc-a861-d1abcefa6353
# ╠═248bddf9-bfc1-42df-b35d-43035bf64e84
# ╠═59da17f2-caef-45ad-8696-35608bc327d2
