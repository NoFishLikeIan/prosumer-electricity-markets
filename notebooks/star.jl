### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ 41809916-cea7-11eb-2af5-8b37c6dbd767
using Plots

# ╔═╡ 40dc6db5-7b14-4150-89cc-ca27992a4b7c
using DataFrames, LinearAlgebra

# ╔═╡ 5e11eacb-f7b5-4914-b045-2684e4ad9779
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

# ╔═╡ c0cf7f69-a656-4bc0-9c24-ad3dc0f31f36
begin
	Plots.resetfontsizes(); default()
	default(size = (800, 600), margin = 10Plots.mm)
	Plots.scalefontsizes(0.8)
end

# ╔═╡ 85620986-9b70-4c6b-baeb-dc47c715bee8
begin
	plotpath = "../plots/two"
	simpath = "../simulation"
end

# ╔═╡ 848401cf-5016-4753-ba92-2e9e2350723b
begin
	main = ingredients(joinpath(simpath, "src/main.jl"))
	simulate = ingredients(joinpath(simpath, "simulate.jl"))
	barg = ingredients("bargaining.jl")
end

# ╔═╡ 658106ec-f84a-43c6-96ec-ec90e271a552
begin
	A = [
		0 1 1 1;
		1 0 0 0;
		1 0 0 0;
		1 0 0 0;
	]

	G = makeG(A)
end

# ╔═╡ 0c6fdbe0-8af1-4139-8950-27da3b18b370
barg.plotpower(A, G)

# ╔═╡ Cell order:
# ╠═41809916-cea7-11eb-2af5-8b37c6dbd767
# ╠═40dc6db5-7b14-4150-89cc-ca27992a4b7c
# ╟─5e11eacb-f7b5-4914-b045-2684e4ad9779
# ╠═c0cf7f69-a656-4bc0-9c24-ad3dc0f31f36
# ╠═85620986-9b70-4c6b-baeb-dc47c715bee8
# ╠═848401cf-5016-4753-ba92-2e9e2350723b
# ╠═658106ec-f84a-43c6-96ec-ec90e271a552
# ╠═0c6fdbe0-8af1-4139-8950-27da3b18b370
