### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 9270222c-4fa5-4332-b3e0-bf67f860eba5
using Plots, LaTeXStrings

# ╔═╡ cdb46928-3164-42c5-b391-8c8a43146347
using LightGraphs, GraphPlot

# ╔═╡ 3ce1d846-830c-41f5-9fc5-d4fc57627331
using LinearAlgebra

# ╔═╡ b496deda-d96b-11eb-0500-23f0345b125a
begin
	upscale = 1 #8x upscaling in resolution
	fntsm = Plots.font("sans-serif", pointsize=round(10.0*upscale))
	fntlg = Plots.font("sans-serif", pointsize=round(14.0*upscale))
	default(titlefont=fntlg, guidefont=fntlg, tickfont=fntsm, legendfont=fntsm)
	default(size=(800*upscale,600*upscale)) #Plot canvas size
	
	Plots.reset_defaults()
	Plots.resetfontsizes()
	
	plotpath = "../plots/energy"
	
	"Plot path: $plotpath"
end

# ╔═╡ ed6671ce-5e62-46c9-a4f2-f91addcd9350
"""
Find a vector of n quantities xᵢ given their sum ∑xᵢ and a vector of n ratios with respect to one of them xᵢ / xₙ (note that xₙ / xₙ = 1 so one entry of the ratios ought to be 1)
"""
function xs_by_sum_ratio(sumX::Float64, ratios::Vector{Float64})
	n = length(ratios)
	xₙ = sumX / sum(ratios)
	
	return xₙ .* ratios
	
end

# ╔═╡ 1ed8e95b-32e7-4638-ad49-0579fa87d56d
function edgetotuple(edge)
	(edge.src, edge.dst)
end

# ╔═╡ 335433a8-9cf4-4a34-ae33-5cdcd2261d0e
begin
	a, b = -5.0, 1.0
	β = 0.8
	
	function X(p)
		a + b * p
	end
	
	function δ(i, j)
		i < j ? 1 : -1
	end
	
	function sortededge(i, j)
		i < j ? (i, j) : (j, i)
	end
end

# ╔═╡ a33a9c31-1f9d-4b3b-aa65-b398f92d5739
begin
	g = SimpleGraph(4)
	
	for j in 2:4
		add_edge!(g, 1, j)
	end
	
	# add_edge!(g, 2, 3)
	
	G = [
		0 1 1;
		1 0 1;
		1 1 0
	]
end

# ╔═╡ 2160fdfe-9196-4de8-8637-58aa87be550c
begin
	M = length(vertices(g))
	∑p = - M * a / b
	pratios = [rand() + 0.5 for m in 1:(M-1)]
	push!(pratios, 1.)
	
	p = xs_by_sum_ratio(∑p, pratios)
end

# ╔═╡ fdbc67c6-0653-496c-934c-d58ce70be66b
function getbargsolution(p::Vector{Float64}, g::SimpleGraph, G::Matrix{Int64})
		
	E = map(edgetotuple, edges(g))

	Xs = map(X, p)
	Δ = [Xs[i] - Xs[j] for (i, j) in E]
	PY = 0.5*inv(2I + G)*Δ

	PYmap = Dict(E .=> PY)
	
	Y = Dict(e => 0.0 for e in E)

	for i in vertices(g)
		
		basej = last(neighbors(g, i))
		baseedge = sortededge(i, basej)
		
		baseY = PYmap[baseedge] * δ(i, basej)
				
		Ei = [sortededge(i, j) for j in neighbors(g, i)]
		
		ratiosY = [PYmap[e] * δ(i, e[2]) for e in Ei]
		
		∑Y = Xs[i]
		
		Yi = xs_by_sum_ratio(∑Y, ratiosY)
		Ymap = Dict(Ei .=> Yi)
		
		for e in Ei
			if Y[e] == 0.0
				Y[e] = Ymap[e]
			end
		end		
	end
	
	P = Dict(e => PYmap[e] / Y[e] for e in E)
	
	return Y, P
end

# ╔═╡ 8f97a8af-0da0-4ac3-a0c4-300e9e0b327c
Y, P = getbargsolution(p, g, G)

# ╔═╡ b65639e2-29ef-4382-ae74-5a52e4bbfb5f
function p′(p, g, G)
	Y, P = getbargsolution(p, g, G)
	
	Xs = map(X, p)
	
	oneneigh = [sortededge(i, first(neighbors(g, i))) for i in 1:length(p)]
	λ = [-2*P[i] for i in oneneigh]
	
	return  @. max(p + (a / b) + Xs * (1 - β) / (b * β) - λ, 0.0)
end

# ╔═╡ 2cf2565b-59bd-4a0c-8fb1-128b8f59fde2
begin
	newp =  p′(p, g, G)
	newX = map(X, newp)
	
	newp, newX
end

# ╔═╡ caa7bfc5-242a-49c2-80f9-5491e8c8d253
p

# ╔═╡ Cell order:
# ╠═9270222c-4fa5-4332-b3e0-bf67f860eba5
# ╠═cdb46928-3164-42c5-b391-8c8a43146347
# ╠═3ce1d846-830c-41f5-9fc5-d4fc57627331
# ╟─b496deda-d96b-11eb-0500-23f0345b125a
# ╠═ed6671ce-5e62-46c9-a4f2-f91addcd9350
# ╠═1ed8e95b-32e7-4638-ad49-0579fa87d56d
# ╠═335433a8-9cf4-4a34-ae33-5cdcd2261d0e
# ╠═a33a9c31-1f9d-4b3b-aa65-b398f92d5739
# ╠═2160fdfe-9196-4de8-8637-58aa87be550c
# ╠═fdbc67c6-0653-496c-934c-d58ce70be66b
# ╠═8f97a8af-0da0-4ac3-a0c4-300e9e0b327c
# ╠═b65639e2-29ef-4382-ae74-5a52e4bbfb5f
# ╠═2cf2565b-59bd-4a0c-8fb1-128b8f59fde2
# ╠═caa7bfc5-242a-49c2-80f9-5491e8c8d253
