### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 51fd2e41-3da6-4c42-8f09-eed8cdb4775b
import Pkg; Pkg.add("JLD")

# ╔═╡ 321f5b93-604c-4ad0-b41c-345cfbfa4f2f
using Plots

# ╔═╡ 0a384684-66ff-4c23-8ff5-3bf9074307f8
using DataFrames, LinearAlgebra

# ╔═╡ 9c1e1856-7ebf-4330-b4a4-d077cace9fb1
begin
	Plots.resetfontsizes(); default()
	default(size = (800, 600), margin = 10Plots.mm)
	Plots.scalefontsizes(0.8)
end

# ╔═╡ 5d095408-ab8f-4209-bd0a-97660b854696
function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	name = Symbol(basename(path))
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
end

# ╔═╡ 4de328e3-21e1-4a98-b69b-3e05471b89e1
begin
	plotpath = "../plots/two"
	simpath = "../simulation"
end

# ╔═╡ 1781deee-e3af-11eb-0651-fbbc9df7a22b
begin
	include(joinpath(simpath, "src/main.jl"))
	include(joinpath(simpath, "simulate.jl"))
end

# ╔═╡ 8a855dc7-9301-4262-90f1-1d1749f9c83f
md"""

# Two providers

"""

# ╔═╡ d54ae3c4-62cf-4e79-9bfa-8ba7fac06d7a
begin
	A = [
		0 1;
		1 0
	]
	
	G = hcat(0) # 1x1 matrix
end

# ╔═╡ 64e04d91-9b0a-4afa-bad1-381a5fe4e0ee
begin
	T = 2_000
	lowε, highε = last(default_params[:ε])
end

# ╔═╡ b53abb61-94df-47ac-b15a-57bd635ab2f0
begin
	makeshock(from, to) = makeshock(from, to, lowε, highε)
	function makeshock(from, to, ε, εₛ)
		εpath = ε * ones(T+1, 2)
		εpath[from:to, 2] .=  εₛ

		return εpath
	end
end

# ╔═╡ f6c51ca8-bf2d-428c-9872-2ab0a8ffe52c
begin
	model = initializemodel(A, G, default_params; εpath = makeshock(50, 48))
	dfagent, dfmodel = simulatemarket!(model; T = T)
	_ = "Done with simulation"
end

# ╔═╡ c9580e63-7f3c-4630-80d3-04ef1c78cc19
begin
	plotexcessdemand(dfagent, dfmodel, savepath = joinpath(plotpath, "demand.pdf"))
	plotexcessdemand(dfagent, dfmodel)
end

# ╔═╡ c3ad6d28-3dfe-40c4-a77b-919368366953
pricesupplyplot(dfagent, model; savepath = joinpath(plotpath, "pricesupply.pdf"))

# ╔═╡ c4230c07-433f-4654-8708-b600fecdcb61
begin
	Ns = 2
	shocks = highε * range(1., 10., length = Ns)
	prices = []
	
	for (j, εₛ) in enumerate(shocks)
		
		model = initializemodel(
			A, G, default_params; 
			εpath = makeshock(10, 15, lowε, εₛ))
	
		dfagent, dfmodel = simulatemarket!(model; T = T)
		
		prov = dfagent[2, :].agent_type
		providers = dfagent[dfagent.agent_type .== prov, :]
		prov₁, prov₂ = groupby(providers, :pos)

		x = prov₂.p
		y = prov₁.p
		push!(prices, (x, y))
		
	end
end

# ╔═╡ 43256d6c-e50f-4c0d-b66f-2237355c8a1f
plotproviderbeliefs(dfagent, model)

# ╔═╡ Cell order:
# ╠═321f5b93-604c-4ad0-b41c-345cfbfa4f2f
# ╠═0a384684-66ff-4c23-8ff5-3bf9074307f8
# ╠═9c1e1856-7ebf-4330-b4a4-d077cace9fb1
# ╟─5d095408-ab8f-4209-bd0a-97660b854696
# ╠═51fd2e41-3da6-4c42-8f09-eed8cdb4775b
# ╠═4de328e3-21e1-4a98-b69b-3e05471b89e1
# ╠═1781deee-e3af-11eb-0651-fbbc9df7a22b
# ╟─8a855dc7-9301-4262-90f1-1d1749f9c83f
# ╠═d54ae3c4-62cf-4e79-9bfa-8ba7fac06d7a
# ╠═b53abb61-94df-47ac-b15a-57bd635ab2f0
# ╠═64e04d91-9b0a-4afa-bad1-381a5fe4e0ee
# ╠═f6c51ca8-bf2d-428c-9872-2ab0a8ffe52c
# ╠═c9580e63-7f3c-4630-80d3-04ef1c78cc19
# ╠═c3ad6d28-3dfe-40c4-a77b-919368366953
# ╠═c4230c07-433f-4654-8708-b600fecdcb61
# ╠═43256d6c-e50f-4c0d-b66f-2237355c8a1f
