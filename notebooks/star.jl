### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ 41809916-cea7-11eb-2af5-8b37c6dbd767
using Plots, DataFrames, CSV

# ╔═╡ c0cf7f69-a656-4bc0-9c24-ad3dc0f31f36
using Agents

# ╔═╡ 848401cf-5016-4753-ba92-2e9e2350723b
include("../src/main.jl")

# ╔═╡ 40dc6db5-7b14-4150-89cc-ca27992a4b7c
Plots.resetfontsizes(); Plots.scalefontsizes(0.8)

# ╔═╡ 3e067f0a-f882-421a-bdb0-bc4915aa5b35
plotpath = "../plots/energy"

# ╔═╡ 658106ec-f84a-43c6-96ec-ec90e271a552
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

	ρₗ = ρᵤ = 0.9

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
		:βprod => 0.5
	)

	s₀ = 20.0

	model = initializemodel(
		A, parameters;
		s₀=s₀, b₀=0.
	)
end

# ╔═╡ ad90abb5-2e74-49f2-ab24-76265904afb8
function makeproducer(ψ)
	s -> Producer(1, 1, s, 1.0, ψ, 1.0, [1., 1.])
end

# ╔═╡ c60d5bdf-4052-4bb2-9628-bc4f2be3579f
function drawrampup(ψ, supplies)
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
		
	figure = plot(xlabel = "p", ylabel="r")
	
	for s ∈ supplies
		plot!(figure, p -> r(p, producer(s), model), label="s = $s")
	end
	
	
	return figure
end

# ╔═╡ b20e801b-515b-4142-b278-df4a46201659
drawrampup(2.5, [2.])

# ╔═╡ f9e927f1-dbf0-497a-a539-f4897687536d
dfagent = CSV.read("../data/out/star_sim.csv", DataFrame)

# ╔═╡ Cell order:
# ╠═41809916-cea7-11eb-2af5-8b37c6dbd767
# ╠═40dc6db5-7b14-4150-89cc-ca27992a4b7c
# ╠═c0cf7f69-a656-4bc0-9c24-ad3dc0f31f36
# ╠═848401cf-5016-4753-ba92-2e9e2350723b
# ╠═3e067f0a-f882-421a-bdb0-bc4915aa5b35
# ╟─658106ec-f84a-43c6-96ec-ec90e271a552
# ╠═ad90abb5-2e74-49f2-ab24-76265904afb8
# ╠═c60d5bdf-4052-4bb2-9628-bc4f2be3579f
# ╠═b20e801b-515b-4142-b278-df4a46201659
# ╟─f9e927f1-dbf0-497a-a539-f4897687536d
