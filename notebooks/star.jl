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

# ╔═╡ 56518671-93c3-4b12-9089-1859cfe6cb01
begin
	A = [
		0 1 1 1;
		1 0 0 0;
		1 0 0 0;
		1 0 0 0;
	]
	
	c(x) = x^3
	c′(x) = 2x^2
	
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
end

# ╔═╡ 248bddf9-bfc1-42df-b35d-43035bf64e84
model = initializemodel(A, parameters; b₀ = -20)

# ╔═╡ 59da17f2-caef-45ad-8696-35608bc327d2
begin
	T = 100
	adata = [:pos, :p, :r, :Ep, :ε, :ψ, :s]
	mdata = []

	dfagent, dfmodel = run!(model, agent_step!, model_step!, T; adata, mdata)
	println("Done!")
end

# ╔═╡ 510a3f3b-64fd-47dc-afba-3420ad6c1ca6
function plotnode(df, node; save=false)
	nodedf = df[df.pos .== node, :]
	prosumer, provider, producer = groupby(nodedf, :agent_type)
	
	time = 0:maximum(df[!, :step])
	
	figure = plot(title = "simulation")
	
	for dfprod in groupby(producer, :id)
		plot!(figure, time, dfprod[!, :s])
	end

	
	if save
		savefig("../plots/star/simulation.png")
	else
		return figure
	end
	
end

# ╔═╡ 03452d36-b5fa-4a14-9626-95fef654855e
plotnode(dfagent, 1)

# ╔═╡ Cell order:
# ╠═41809916-cea7-11eb-2af5-8b37c6dbd767
# ╠═c0cf7f69-a656-4bc0-9c24-ad3dc0f31f36
# ╠═ed781afc-5fa5-4817-bd68-382cc99af097
# ╠═56518671-93c3-4b12-9089-1859cfe6cb01
# ╠═248bddf9-bfc1-42df-b35d-43035bf64e84
# ╠═59da17f2-caef-45ad-8696-35608bc327d2
# ╠═510a3f3b-64fd-47dc-afba-3420ad6c1ca6
# ╠═03452d36-b5fa-4a14-9626-95fef654855e
