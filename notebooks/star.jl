### A Pluto.jl notebook ###
# v0.14.3

using Markdown
using InteractiveUtils

# ╔═╡ 41809916-cea7-11eb-2af5-8b37c6dbd767
using Plots, DataFrames, InteractiveDynamics

# ╔═╡ c0cf7f69-a656-4bc0-9c24-ad3dc0f31f36
using Agents

# ╔═╡ 848401cf-5016-4753-ba92-2e9e2350723b
include("../src/main.jl")

# ╔═╡ 40dc6db5-7b14-4150-89cc-ca27992a4b7c
Plots.resetfontsizes(); Plots.scalefontsizes(0.8)

# ╔═╡ 3e067f0a-f882-421a-bdb0-bc4915aa5b35
plotpath = "../plots/energy"

# ╔═╡ 56518671-93c3-4b12-9089-1859cfe6cb01
begin

	A = [
		0 1 1 1;
		1 0 0 0;
		1 0 0 0;
		1 0 0 0;
	]

	c₁ = 1.0

	c(s, r) = log(1 + exp(c₁ * s * r))
	∇c(s, r) = c₁ * inv(1 + exp(-c₁ * s * r))

	∂c∂s(s, r) = ∇c(s, r) * r
	∂c∂r(s, r) = ∇c(s, r) * s

	ρₗ = 0.9
	ρᵤ = 0.8

	ε = (
		[
			ρₗ 1 - ρₗ; 
			1 - ρᵤ ρᵤ
		],
		[0.0, 10.0]
	)

	parameters = Dict(
		:c => (c, ∂c∂s, ∂c∂r),
		:Ψ => [0.9, 1.1],
		:M => 500, :ε => ε,
		:N => 15, :β => 0.99,
		:βprod => 0.3
	)

	s₀ = 20.0
end

# ╔═╡ b389c106-600b-44dc-a861-d1abcefa6353
begin
	fixeds = 4.0
	rs = range(-fixeds, fixeds, length = 100)
	
	fnfig = plot(rs, x -> c(fixeds, x),
		ylims = (0., 10.), xlabel = "r", ylabel="c",
		c = :red,
		title = "costs with s = $fixeds; c₁ = $c₁",
		label = false)
	
	derfig = plot(
		rs, x -> ∂c∂r(fixeds, x),
		ylims = (0., 10.),xlabel = "r", ylabel="∂c/∂r",
		c = :red,
		title = "derivative of marginal costs with s = $fixeds; c₁ = $c₁",
		label = false)
	
	jointcosts = plot(fnfig, derfig, size = (1200, 400))
	
	savefig(jointcosts, joinpath(plotpath, "cost.pdf"))
	
	jointcosts
	
end

# ╔═╡ 248bddf9-bfc1-42df-b35d-43035bf64e84
model = initializemodel(A, parameters; s₀ = s₀, b₀ = 0.)

# ╔═╡ ad90abb5-2e74-49f2-ab24-76265904afb8
function makeproducer(ψ)
	s -> Producer(1, 1, s, 1.0, ψ, 1.0, [1., 1.])
end

# ╔═╡ c60d5bdf-4052-4bb2-9628-bc4f2be3579f
function drawrampup(ψ)
	supplies = range(0., 20., length = 1000)
	prices = range(0., 20., length = 1000)
	
	producer = makeproducer(ψ)
	
	function safer(s, p)
		try
			return r(p, producer(s), model)
		catch
			println("Error with s=$s and p=$p")
			
			return 0.0
		end

	end
		
	figure = heatmap(
		supplies, prices, safer,
		xlabel = "s", ylabel="p",
		clims = (-10., 10.)
	)
	
	
	return figure
end

# ╔═╡ b20e801b-515b-4142-b278-df4a46201659
drawrampup(0.9)

# ╔═╡ f9e927f1-dbf0-497a-a539-f4897687536d


# ╔═╡ 59da17f2-caef-45ad-8696-35608bc327d2
if false
	T = 5
	adata = [:pos, :p, :r, :Ep, :ε, :ψ, :s]
	mdata = []

	dfagent, dfmodel = run!(model, agent_step!, model_step!, T; adata, mdata)
	println("Done!")
end

# ╔═╡ Cell order:
# ╠═41809916-cea7-11eb-2af5-8b37c6dbd767
# ╠═40dc6db5-7b14-4150-89cc-ca27992a4b7c
# ╠═c0cf7f69-a656-4bc0-9c24-ad3dc0f31f36
# ╠═848401cf-5016-4753-ba92-2e9e2350723b
# ╟─3e067f0a-f882-421a-bdb0-bc4915aa5b35
# ╠═56518671-93c3-4b12-9089-1859cfe6cb01
# ╟─b389c106-600b-44dc-a861-d1abcefa6353
# ╠═248bddf9-bfc1-42df-b35d-43035bf64e84
# ╠═ad90abb5-2e74-49f2-ab24-76265904afb8
# ╠═c60d5bdf-4052-4bb2-9628-bc4f2be3579f
# ╠═b20e801b-515b-4142-b278-df4a46201659
# ╠═f9e927f1-dbf0-497a-a539-f4897687536d
# ╟─59da17f2-caef-45ad-8696-35608bc327d2
