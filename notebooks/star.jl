### A Pluto.jl notebook ###
# v0.14.3

using Markdown
using InteractiveUtils

# ╔═╡ 41809916-cea7-11eb-2af5-8b37c6dbd767
using Plots, DataFrames, InteractiveDynamics

# ╔═╡ c0cf7f69-a656-4bc0-9c24-ad3dc0f31f36
using Agents

# ╔═╡ ed781afc-5fa5-4817-bd68-382cc99af097
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
	
	c(x) = x + x^2
	c′(x) = 1 + 2x
	
	ε = (
		[0.99 0.01; 0.01 0.99],
		[-10.0, 10.0]
	)

	parameters = Dict(
		:c => c, :c′ => c′,
		:Ψ => [0.9, 1.1],
		:M => 100, :ε => ε,
		:N => 5, :β => 0.99
	)
	b₀ = -1
end

# ╔═╡ 248bddf9-bfc1-42df-b35d-43035bf64e84
model = initializemodel(A, parameters; b₀ = b₀)

# ╔═╡ 59da17f2-caef-45ad-8696-35608bc327d2
begin
	T = 100
	adata = [:pos, :p, :r, :Ep, :ε, :ψ, :s]
	mdata = []

	dfagent, dfmodel = run!(model, agent_step!, model_step!, T; adata, mdata)
	println("Done!")
end

# ╔═╡ a0549a1c-f195-4004-ad36-97fcab690f3e
function makefoc(ψ, s, p, cost, ∂cost)
	
	mb = ψ * p - c(s) / model.β 

    f(r) = r * ∂cost(s + r) - cost(s + r) - mb
	
	return f
end

# ╔═╡ 810770db-d3ff-420f-99be-ff09136ada66
begin
	ψ = 1.1
	s = 2.
	
	rs = range(-s*2, s*2, length = 100)
	
	figure = hline([0.],
		c = :red, linestyle=:dash, label=false,
		title = "First order condition with ψ=$ψ and s=$s")
	
	for p ∈ [1,  5., 10.]
		f = makefoc(
			ψ, s, p, 
			(x) -> x^2, (x) -> 2x
		)
		
		plot!(figure, rs, f, label = "p = $p")
		
	end
	
	figure
	
end

# ╔═╡ b7b4cb91-4467-4598-b6c7-20637a6ae395
function plotrampup(ψ, supplies, prices)
		
	mins, maxs = extrema(supplies)
	
	sticks = range(mins, maxs, length = length(supplies) ÷ 100)

	producer(s) = Producer(1, 1, s, 0., ψ, 0., [0., 0.])
		
	title = "r(p, s, ψ = $ψ)"
		
	figure = heatmap(
		supplies, prices, 
		(s, p) -> r(p, producer(s), model), 
		xticks = round.(sticks, digits = 2),
		c = :coolwarm,
		clims = (-maxs, maxs),
		title=title, xlabel = "s", ylabel="p",
		size=(1200, 400)
	)
	
	return figure
end

# ╔═╡ 22b7e3ff-9de9-4aea-b4e0-777266f63624
begin
	prices = 0.01:0.01:5.0
	supplies = range(0.0, 5.0, length = 1000)
	
	
	
	figures = [plotrampup(ψ, supplies, prices) for ψ ∈ model.Ψ]
	
	joint = plot(figures..., layout = (1, 2))
	
	# savefig(joint, joinpath(plotpath, "r.pdf"))
	
	joint
	
end

# ╔═╡ Cell order:
# ╠═41809916-cea7-11eb-2af5-8b37c6dbd767
# ╠═40dc6db5-7b14-4150-89cc-ca27992a4b7c
# ╠═c0cf7f69-a656-4bc0-9c24-ad3dc0f31f36
# ╠═ed781afc-5fa5-4817-bd68-382cc99af097
# ╠═3e067f0a-f882-421a-bdb0-bc4915aa5b35
# ╠═56518671-93c3-4b12-9089-1859cfe6cb01
# ╠═248bddf9-bfc1-42df-b35d-43035bf64e84
# ╠═59da17f2-caef-45ad-8696-35608bc327d2
# ╠═a0549a1c-f195-4004-ad36-97fcab690f3e
# ╠═810770db-d3ff-420f-99be-ff09136ada66
# ╠═b7b4cb91-4467-4598-b6c7-20637a6ae395
# ╠═22b7e3ff-9de9-4aea-b4e0-777266f63624
