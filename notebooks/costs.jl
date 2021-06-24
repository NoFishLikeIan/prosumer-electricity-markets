### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ d24cee46-d3f2-11eb-0f8c-93119645edd9
begin
	using Plots
	using Roots
	using LaTeXStrings
end

# ╔═╡ 4509a0c9-374e-4f0f-a5dd-5671f0c67bb4
begin
	Plots.resetfontsizes()
	Plots.scalefontsizes(0.8)
end

# ╔═╡ 805018be-7695-45ae-a671-2f8d8cc4a858
plotpath = "../plots/energy"

# ╔═╡ 4412cc25-bb76-4453-9727-5cf097a883e1
begin
	ψ = 1.1
	s = 10.0
	p = 5.0
	β = 0.5
	k = 2.0
end

# ╔═╡ e572d85f-1839-48e5-b1e2-2ee1123ef22e
function makefoc(c, ∂c∂s, ∂c∂r)
	mc(s, r) = ∂c∂r(s, r)*r + c(s, r)
	mb(s, r) = ψ*(p - k) + (∂c∂r(s+r, r) - ∂c∂s(s+r, r))*r + c(s+r, r)
	
	return mc, mb
end

# ╔═╡ 48506150-b30a-4e05-ac66-886c88171783
begin
	costlabel = latexstring("\$c(r; s = $(s))\$")
	derivlabel = latexstring("\$ \\frac{\\partial c}{\\partial r}(r; s = $(s)) \$")
	
	marlabel = latexstring("\$s = $(s), \\psi=$(ψ), p = $(p)\$")
end

# ╔═╡ 5fdea5b6-10b6-4818-92e2-0d92d8bd0bcc
function plotfoc(c, ∂c∂s, ∂c∂r; rs = range(-s, s, length = 500), s = s)
	l = @layout [a b; c]
	
	mc, mb = makefoc(c, ∂c∂s, ∂c∂r)
	
	costfig = plot(rs, r -> c(s, r), title=costlabel, label = nothing)
	derivfig = plot(rs, r -> ∂c∂r(s, r), title=derivlabel, label = nothing)
	
	marginalfig = plot(title = marlabel, legend= :topleft)
	plot!(marginalfig, rs, r -> mc(s, r), label=L"mc(r)")
	plot!(marginalfig, rs, r -> mb(s, r) * β, label=L"mb(r) \cdot \beta")
	
	try
	
		r = find_zero(r -> mc(s, r) - mb(s, r) * β, 0.0)

		rnice = round(r, digits = 2)
		rlabel = latexstring("\$ r \\approx $(rnice) \$")

		scatter!(
			marginalfig, [r], [mc(s, r)], 
			c = :red, label = nothing,
			markersize = 3, markerstrokewidth = 0)

		vline!(marginalfig, [r], linestyle=:dash, label = nothing, c=:red)
		annotate!(marginalfig, r + 0.5, 0.0, text(rlabel, :left, 8))
		
	catch error
		println("Could not find root")
	end
	
	figure = plot(
		costfig, derivfig, marginalfig, 
		layout = l, figsize = (1200, 800), dpi = 500)
	
	return figure
	
end

# ╔═╡ ff79e521-c7a5-4ad2-96a0-0dc1c2c1c76c
md"""
## Quadratic costs
"""

# ╔═╡ f859798a-8229-4c54-90ed-fc8fdc833cec
figure = plotfoc((s, r) -> r, (s, r) -> 0, (s, r) -> 1)

# ╔═╡ 4fda69af-82b4-4426-bc9d-aa8e9db4ec67
# savefig(figure, joinpath(plotpath, "quadcosts.pdf"))

# ╔═╡ 557dcc62-1cf9-4f70-af29-e42fea678fae
md"""
## Softplus costs
"""

# ╔═╡ 5bf78e23-96c4-4044-ad75-b169aa6e6ec5
c₁ = 100.0

# ╔═╡ b794fc16-e815-42d3-b767-d0630573383a
begin
	c(s, r) = log(1 + exp(c₁ * s * r)) / c₁
	S(s, r) = inv(1 + exp(- c₁ * s * r))
	
	∂c∂r(s, r) = S(s, r) * s
	∂c∂s(s, r) = S(s, r) * r
end

# ╔═╡ dfbdac59-6675-41a3-ab71-ac7f51f72a8a
figuresoft = plotfoc(c, ∂c∂s, ∂c∂r)

# ╔═╡ 93e56234-86d8-423b-8325-42d0ab2fa3de
# savefig(figuresoft, joinpath(plotpath, "cost.pdf"))

# ╔═╡ ddf53627-181f-4fc0-b8dc-39d6243f1f0e
md"""
## A small simulation with oscillating prices
"""

# ╔═╡ 2004442b-6b1a-408a-a154-05eeba330b48
function maker(c, ∂c∂s, ∂c∂r)
	function r(p, s, ψ)
		mc(s, r) = ∂c∂r(s, r)*r + c(s, r)
		mb(s, r) = ψ*(p - k) + (∂c∂r(s+r, r) - ∂c∂s(s+r, r))*r + c(s+r, r)

		root = fzero(r -> mc(s, r) - β*mb(s, r), 0.0)
		
		return max(-s, root)
	end
end

# ╔═╡ 7eecc02c-9bc2-492c-8013-864bb99b029a
r = maker(c, ∂c∂s, ∂c∂r)

# ╔═╡ 27262d0f-06f5-4032-9a72-afd2e4cb4798
function simulatecosprices(T, ψ; p₀ = 5., s₀ = 10.)
	time = 1:T
	supplies = ones(T) * s₀
	ramps = zeros(T)
	prices = ones(T) * p₀
	
	for t=1:(T-1)
		p = prices[t] + sin(t / 4)
		s = supplies[t]
		ramps[t+1] = r(p, s, ψ)
		supplies[t+1] = s + ramps[t+1]
		prices[t+1] = p
	end
	
	return supplies, prices, ramps
	
end

# ╔═╡ 0c2afa65-010c-4a06-aedb-112932a01c6d
begin
	T = 100
	supplies, prices, ramps = simulatecosprices(T, 1.1)
end

# ╔═╡ 3fdd4dc4-caf7-41f2-a6fc-a8dc89fa6fbc
begin
	simfig = plot(figsize = (1200, 800), dpi = 500)
	
	plot!(
		simfig, 1:T, 
		prices, label = "p", c=:red, legend = :topleft)
	
	
	plot!(
		twinx(simfig), 1:T, 
		supplies, label = "s", c = :blue, legend = :topright)
end

# ╔═╡ 0802967f-811d-435b-832d-e4b60599f1b2
plot(ramps[2:end], figsize = (1200, 800), dpi = 500, label = "r")

# ╔═╡ Cell order:
# ╠═d24cee46-d3f2-11eb-0f8c-93119645edd9
# ╠═4509a0c9-374e-4f0f-a5dd-5671f0c67bb4
# ╠═805018be-7695-45ae-a671-2f8d8cc4a858
# ╠═4412cc25-bb76-4453-9727-5cf097a883e1
# ╟─e572d85f-1839-48e5-b1e2-2ee1123ef22e
# ╟─48506150-b30a-4e05-ac66-886c88171783
# ╟─5fdea5b6-10b6-4818-92e2-0d92d8bd0bcc
# ╟─ff79e521-c7a5-4ad2-96a0-0dc1c2c1c76c
# ╠═f859798a-8229-4c54-90ed-fc8fdc833cec
# ╠═4fda69af-82b4-4426-bc9d-aa8e9db4ec67
# ╟─557dcc62-1cf9-4f70-af29-e42fea678fae
# ╠═5bf78e23-96c4-4044-ad75-b169aa6e6ec5
# ╠═b794fc16-e815-42d3-b767-d0630573383a
# ╠═dfbdac59-6675-41a3-ab71-ac7f51f72a8a
# ╠═93e56234-86d8-423b-8325-42d0ab2fa3de
# ╟─ddf53627-181f-4fc0-b8dc-39d6243f1f0e
# ╠═2004442b-6b1a-408a-a154-05eeba330b48
# ╠═7eecc02c-9bc2-492c-8013-864bb99b029a
# ╠═27262d0f-06f5-4032-9a72-afd2e4cb4798
# ╠═0c2afa65-010c-4a06-aedb-112932a01c6d
# ╠═3fdd4dc4-caf7-41f2-a6fc-a8dc89fa6fbc
# ╠═0802967f-811d-435b-832d-e4b60599f1b2
