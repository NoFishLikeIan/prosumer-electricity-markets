### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ 0593a9ab-2085-4892-9f77-32296375cbe3
using Colors, GraphPlot, LightGraphs, LinearAlgebra, Plots, SimpleWeightedGraphs

# ╔═╡ 3108ec47-f98d-4199-be28-ad07ca9b2ce3
using Cairo, Compose

# ╔═╡ a8f79c1b-3f67-4cd2-9a74-9d41862eb166
using Latexify, PlutoUI

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

# ╔═╡ 00bbdf8f-5a3e-4a68-851d-ce91972abf2d
digtostring(num) = join(['.', last(split(string(num), '.'))])

# ╔═╡ 40d2a842-c1a3-4d4f-8356-939a0874f8cc
function isconstant(arr)
	notequal = findfirst(x -> x != arr[1], arr)
	
	return isnothing(notequal) ? true : false
end

# ╔═╡ d24b87fe-f297-4529-85d0-60cd6b81fe74
function plotpower(A, G; savepath = nothing, layout = circular_layout, digits = 3)
	
	g = SimpleGraph(A)
	E = map(edgetotuple, edges(g))
	
	if det(2I + G) ≈ 0 # Singular G matrix
		∑ρ = ones(length(E)) / length(E)
	else
		ρ = bargainingpower(G)

		∑ρ = sum(ρ, dims = 2) ./ sum(ρ)
	end

	nodepower = [
		sum(∑ρ[findall(e -> n ∈ e, E)])
		for n in vertices(g)
	] ./ 2
		
	
	alphas = isconstant(nodepower) ? 
		ones(length(nodepower)) : 
		rescaleto(nodepower, 0.5, 1.0)
	
	nodecolor = [RGBA(red..., α) for α in alphas] 
	
	printpower = [digtostring(round(n, digits = digits)) for n in nodepower]
	
	makegplot() = gplot(g, 
		nodefillc=nodecolor, nodelabel=printpower, layout=layout)

	if !isnothing(savepath) 
		draw(PDF(savepath, 16cm, 16cm), makegplot())
	end
	
	return makegplot()
	
end

# ╔═╡ 17dbd9ea-200c-4800-9fe6-9f56d7f01fa6
isconstant([1, 2, 3])

# ╔═╡ 007f05f8-65bb-4511-bf32-b3e1b03112c8
rescaleto

# ╔═╡ 1cbdb317-fe0d-4223-a4dd-6abc3250389f
"""
Computes G matrix for arbitrary A
"""
function makeG(A)
	E = map(edgetotuple, edges(SimpleGraph(A)))
    nₑ = length(E)
    G = zeros(Int64, nₑ, nₑ)

    for (row, e₁) in enumerate(E), (col, e₂) in enumerate(E)

        if row == col || isempty(e₁ ∩ e₂) continue end

        e = first(e₁ ∩ e₂)

        isoptionone = (e == first(e₁))
        iscorrect = (e == first(e₂))

        if isoptionone ⊻ iscorrect
            G[row, col] = -1
        else
            G[row, col] = 1
        end

    end
	
	return G
end

# ╔═╡ a2bdeb45-76e2-49d5-9c02-fe36331c0add
function plotG(A)
	
	G = makeG(A)
	
	graph = SimpleWeightedDiGraph(G)
	
	edgecolor = [
		e.weight > 0 ? colorant"red" : colorant"blue"
		for e in edges(graph)
	]
	
	gplot(
		graph, layout = circular_layout, 
		nodelabel = map(edgetotuple,edges(SimpleGraph(A))),
		nodefillc = RGB(red...), edgestrokec = edgecolor)
	
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
	plotpower(Aₗ, -Gₗ; savepath = joinpath(plotpath, "line.pdf"))
end

# ╔═╡ d7313c18-5c57-4295-95a6-45ad96a4a972
md"""
# Star graph
"""

# ╔═╡ 7924086f-7acd-44c3-bcb7-e73456d50a97
begin
	Aₛ, Gₛ = makestar(n)
	nodepower = plotpower(Aₛ, Gₛ; savepath = joinpath(plotpath, "star.pdf"), layout=spring_layout)
end

# ╔═╡ bd1db161-7ea1-4cbf-9131-a8d325623e93
md"""
# Complete graph
"""

# ╔═╡ 8c925a00-5b3c-4e3b-9ea4-740ae334dcda
function makecircular(n::Int64)
	
	A, G = makeline(n)
	A[1, end] = 1
	A[end, 1] = 1
	
	G = makeG(A)
	
	return A, G
	
end

# ╔═╡ 6b1d3c77-d5d4-48b5-8a0d-ed8375fdfcaa
begin
	Aᵪ, Gᵪ = makecomplete(n)
	plotpower(Aᵪ, Gᵪ, savepath = joinpath(plotpath, "complete.pdf"))
end

# ╔═╡ 13935391-438b-44ac-9bbb-e50cb8400488
md"""
# Large tree
"""

# ╔═╡ c2255603-d2a4-42cb-92bd-bf046421b340
begin
	Atree = adjacency_matrix(BinaryTree(4))
	Gtree = makeG(Atree)
	
	plotpower(
		Atree, Gtree, 
		savepath = joinpath(plotpath, "binarytree.pdf"), 
		layout=spring_layout, digits = 2)
end

# ╔═╡ 59f0021d-ada1-4bbc-9c4f-11bf3f522847
md"""
# Plotting line graphs
"""

# ╔═╡ 57548644-8522-4a44-aae3-518a5ece60b9


# ╔═╡ 20d6c5a3-878e-478a-8b49-c1fc78689416
plotG(Aₗ)

# ╔═╡ be72b402-a989-4ce5-8d69-ad95e38d8083
begin
	Acycle = [
		0 0 1 1 1
		0 0 0 0 0
		0 0 0 0 1
		0 0 0 0 1
		0 0 0 0 0 
	]
	
	Acycle += Acycle'
	
	Gcycle = makeG(Acycle)
	plotG(Acycle)
end

# ╔═╡ 7da1b4b3-a0a6-439b-b854-4bdeb6a2ce41
begin	
	graphcycle = SimpleGraph(Acycle) 
	gplot(graphcycle, nodelabel = vertices(graphcycle))
end

# ╔═╡ 77388e81-29fd-4a99-83e8-427a22f78579
det(2I + Gcycle)

# ╔═╡ Cell order:
# ╠═0593a9ab-2085-4892-9f77-32296375cbe3
# ╠═3108ec47-f98d-4199-be28-ad07ca9b2ce3
# ╠═a8f79c1b-3f67-4cd2-9a74-9d41862eb166
# ╠═ebe113e0-dbd9-11eb-27ba-1d118cccfaea
# ╠═2e7361ed-a41b-4bdb-944f-4e9b68af0032
# ╠═18a5cfee-649c-4225-a37d-07a863850d2e
# ╠═83082736-dbda-11eb-3baa-ef1dc6d139fc
# ╠═00bbdf8f-5a3e-4a68-851d-ce91972abf2d
# ╠═40d2a842-c1a3-4d4f-8356-939a0874f8cc
# ╠═a2bdeb45-76e2-49d5-9c02-fe36331c0add
# ╠═d24b87fe-f297-4529-85d0-60cd6b81fe74
# ╠═17dbd9ea-200c-4800-9fe6-9f56d7f01fa6
# ╠═007f05f8-65bb-4511-bf32-b3e1b03112c8
# ╠═1cbdb317-fe0d-4223-a4dd-6abc3250389f
# ╟─1940905a-68af-4aa0-b4c4-3e413df7130f
# ╠═79cb4d06-0ccc-4ad5-ad80-3298b0432f6f
# ╠═cf6ebce3-f18f-4aab-af1e-63c01df3b058
# ╟─d7313c18-5c57-4295-95a6-45ad96a4a972
# ╠═7924086f-7acd-44c3-bcb7-e73456d50a97
# ╟─bd1db161-7ea1-4cbf-9131-a8d325623e93
# ╠═8c925a00-5b3c-4e3b-9ea4-740ae334dcda
# ╠═6b1d3c77-d5d4-48b5-8a0d-ed8375fdfcaa
# ╠═13935391-438b-44ac-9bbb-e50cb8400488
# ╠═c2255603-d2a4-42cb-92bd-bf046421b340
# ╟─59f0021d-ada1-4bbc-9c4f-11bf3f522847
# ╠═57548644-8522-4a44-aae3-518a5ece60b9
# ╠═20d6c5a3-878e-478a-8b49-c1fc78689416
# ╠═be72b402-a989-4ce5-8d69-ad95e38d8083
# ╠═7da1b4b3-a0a6-439b-b854-4bdeb6a2ce41
# ╠═77388e81-29fd-4a99-83e8-427a22f78579
