### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ 795167ee-de86-4f52-a098-cd76a4263838
begin
	using Plots
	using DataFrames
	using Agents
end

# ╔═╡ 486cff3b-1e59-442e-9a97-d20a3efaad56
include("../src/main.jl")

# ╔═╡ 48bea0fc-d98f-11eb-248b-89a62bc5d1fe
md"""
# Examples
"""

# ╔═╡ ae119317-6d6e-4cc2-bea5-135c6f9c9b86
begin
	c₁ = 100

	c(s, r) = log(1 + exp(c₁ * s * r)) / c₁
	S(s, r) = inv(1 + exp(-c₁ * s * r))

	∂c∂s(s, r) = S(s, r) * r
	∂c∂r(s, r) = S(s, r) * s
end

# ╔═╡ d5e4e620-a4f8-46f5-9c9f-7794c4ff0028
md"""
## One isolated provider
"""

# ╔═╡ d0547104-dc72-4131-88f1-adc2c54d8d47
begin 
	A = hcat(1)
	G = hcat(0)
	
	ρₗ = 0.9
	ρᵤ = 0.9

	ε = ([
			ρₗ 1 - ρₗ; 
			1 - ρᵤ ρᵤ
		],
		[-10., 10.])

	parameters = Dict(
		:c => (c, ∂c∂s, ∂c∂r), :k => 2.0,
		:Ψ => [0.9, 1.1],
		:β => 0.99, :βprod => 0.8,
		:M => 1_000, :N => 3,
		:ε => ε)
	
	model = initializemodel(A, G, parameters; s₀=0.)
end

# ╔═╡ e3f0f27c-b545-4509-a070-5706457d91c8
begin
	T = 100
	
	price = []
	ramps = []
	
	for t in 1:T
		provider = model[2]
		
		provider.p = -provider.b / provider.a
		push!(price, provider.p)
		
		for producer in getlocalproducers(provider, model)
			agent_step!(producer, model)
		end
		
		update_belief!(provider, model)
	
		for producer in getlocalproducers(provider, model)
			update_belief!(producer, model)
		end
		
		S = sum(p.s for p in getlocalproducers(provider, model))
	
		push!(ramps, S)
		
	end
end

# ╔═╡ 24761f7f-ade4-4f2d-a8ae-235cbbf06ab1
ramps

# ╔═╡ Cell order:
# ╟─48bea0fc-d98f-11eb-248b-89a62bc5d1fe
# ╠═486cff3b-1e59-442e-9a97-d20a3efaad56
# ╠═795167ee-de86-4f52-a098-cd76a4263838
# ╟─ae119317-6d6e-4cc2-bea5-135c6f9c9b86
# ╟─d5e4e620-a4f8-46f5-9c9f-7794c4ff0028
# ╠═d0547104-dc72-4131-88f1-adc2c54d8d47
# ╠═e3f0f27c-b545-4509-a070-5706457d91c8
# ╠═24761f7f-ade4-4f2d-a8ae-235cbbf06ab1
