### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ 0593a9ab-2085-4892-9f77-32296375cbe3
using Colors, GraphPlot, LightGraphs, LinearAlgebra, Plots

# ╔═╡ 3108ec47-f98d-4199-be28-ad07ca9b2ce3
using Cairo, Compose

# ╔═╡ ebe113e0-dbd9-11eb-27ba-1d118cccfaea
include("../simulation/src/main.jl")

# ╔═╡ 2e7361ed-a41b-4bdb-944f-4e9b68af0032
plotpath = "../plots/barg"

# ╔═╡ 18a5cfee-649c-4225-a37d-07a863850d2e
red = [220, 20, 60] ./ 255

# ╔═╡ 83082736-dbda-11eb-3baa-ef1dc6d139fc
function bargainingpower(G::Matrix{Int64})
	inv(2I + G)
end

# ╔═╡ d24b87fe-f297-4529-85d0-60cd6b81fe74
function plotpower(A, G; savepath = nothing)
	g = SimpleGraph(A)
	E = map(edgetotuple, edges(g))
	ρ = abs.(bargainingpower(G))

	∑ρ = sum(ρ, dims = 2) ./ sum(ρ)
	
	nodepower = [
		sum(∑ρ[findall(e -> n ∈ e, E)])
		for n in vertices(g)
	] ./ 2
		
	nodecolor = [RGBA(red..., α * 2) for α in nodepower] 
	
	printpower = [round(n, digits = 2) for n in nodepower]
	
	makegplot() = gplot(g, nodefillc=nodecolor, nodelabel=printpower)

	if !isnothing(savepath) 
		draw(PDF(savepath, 16cm, 16cm), makegplot())
	end
	
	return makegplot()
	
end

# ╔═╡ 1940905a-68af-4aa0-b4c4-3e413df7130f
md"""
## Line graph
"""

# ╔═╡ 79cb4d06-0ccc-4ad5-ad80-3298b0432f6f
n = 7

# ╔═╡ cf6ebce3-f18f-4aab-af1e-63c01df3b058
begin
	Aₗ, Gₗ = makeline(n)
	plotpower(Aₗ, Gₗ; savepath = joinpath(plotpath, "line.pdf"))
end

# ╔═╡ 6e60022c-0945-4b26-b44a-5c95b82f78fe


# ╔═╡ d7313c18-5c57-4295-95a6-45ad96a4a972
md"""
# Star graph
"""

# ╔═╡ 7924086f-7acd-44c3-bcb7-e73456d50a97
begin
	Aₛ, Gₛ = makestar(n)
	nodepower = plotpower(Aₛ, Gₛ; savepath = joinpath(plotpath, "star.pdf"))
end

# ╔═╡ Cell order:
# ╠═ebe113e0-dbd9-11eb-27ba-1d118cccfaea
# ╠═2e7361ed-a41b-4bdb-944f-4e9b68af0032
# ╠═0593a9ab-2085-4892-9f77-32296375cbe3
# ╠═3108ec47-f98d-4199-be28-ad07ca9b2ce3
# ╠═18a5cfee-649c-4225-a37d-07a863850d2e
# ╠═83082736-dbda-11eb-3baa-ef1dc6d139fc
# ╠═d24b87fe-f297-4529-85d0-60cd6b81fe74
# ╟─1940905a-68af-4aa0-b4c4-3e413df7130f
# ╠═79cb4d06-0ccc-4ad5-ad80-3298b0432f6f
# ╠═cf6ebce3-f18f-4aab-af1e-63c01df3b058
# ╠═6e60022c-0945-4b26-b44a-5c95b82f78fe
# ╟─d7313c18-5c57-4295-95a6-45ad96a4a972
# ╠═7924086f-7acd-44c3-bcb7-e73456d50a97
