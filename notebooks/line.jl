### A Pluto.jl notebook ###
# v0.14.3

using Markdown
using InteractiveUtils

# ╔═╡ 121d970c-88fa-4d78-81b5-c1eadb12865b
using LightGraphs, GraphPlot, Colors, Plots, Roots

# ╔═╡ 259aca87-3d8a-4b08-b134-81f5e56fd9a6
include("../src/main.jl")

# ╔═╡ 6a48ed3d-4f7c-42f6-aef7-2be97d9b5b49
md"""

In the cell below I set up a problem of the form

$$\mathbf{A} = \begin{pmatrix}
		0   & 1  & 0 \\
		- 1 & 0  & 1 \\
		0   & -1 & 0
\end{pmatrix}$$

with each market having 10 prosumers (`marketsize`).

Then I initialize each market with a different degree of autocorrelation in the endowment (i.e. less or more stable weather) $\omega = [0.4, 0.5, 0.6]$.

The relevant data and the policy functions are contained in `Grid`.

"""

# ╔═╡ f704ca13-b5db-4123-a33e-0e7c6c5eaaae
begin
	A = [
		0 1 0;
		1 0 1;
		0 1 0
	]
	N, N = size(A)
	marketsize = 10
	
	setups = [
		(
			Prosumer(ψ₁=.95, ψ₂=1.01), 
			Environment(ω=(0.3 + i / 10), γ=0.5), 
			marketsize
		) for i in 1:N
	]
	
	grd = (600, 100)

	localmarkets = [
		(solvepolicy(grd, p, e; verbose=true), p, e, s) for (p, e, s) in setups
	]
	
	Grid = ElectricityMarket(A, localmarkets)
end

# ╔═╡ ff361cfe-88dc-45a0-a51a-28632911d0ff
begin
	g = Graph(Grid.A)
	persistence = [mkt[3].ω for mkt in Grid.localmarkets]
	nodelabel = ["$i, ω = $ω" for (i, ω) in enumerate(persistence)]

	
	rgb = (151, 196, 240) ./ 255
	
	gplot(
		g, nodelabel = nodelabel, layout = spring_layout,
		nodefillc=RGBA(rgb..., 1), 
		edgestrokec = colorant"gray"
	)
		
end

# ╔═╡ a8fae4d5-97b3-4401-88fa-5d055232610c
md"""

The Nash bargaining solution is,

$P = (2\mathbf{I} + \mathbf{G})^{-1} (\Delta X \oslash Y)$

Where $\mathbf{G} = \begin{pmatrix}
			0  & 1 \\
			-1 & 0
\end{pmatrix}$. 

Using the equilibrium condition, $X_3 = Y^{2, 3} \text{ and } X_1 = Y^{1, 2}$ we can rewrite,

$\begin{align}
		\Delta X \oslash Y &= \begin{pmatrix}
			\frac{X_1 \cdot p_1 - X_2 \cdot p_2}{X_1} &
			\frac{X_2 \cdot p_1 - X_3 \cdot p_2}{X_3}
		\end{pmatrix}^{T} \\
		&= \begin{pmatrix}
			p_1 - \frac{X_2}{X_1} \cdot p_2 &
			\frac{X_2}{X_3} \cdot p_2 - p_3
		\end{pmatrix}^{T}
\end{align}$

hence the first order condition of the firm optimization problem is,

$\begin{align}
	P + \partial P \circ Y = - \frac{1}{5} \mathbf{G} \begin{pmatrix}
		p_1 - \frac{X_2}{X_1} \cdot p_2 \\
		\frac{X_2}{X_3} \cdot p_2 - p_3
	\end{pmatrix} = \frac{1}{5} \begin{pmatrix}
		p_3 - \frac{X_2}{X_3} \cdot p_2 \\
		p_1 - \frac{X_2}{X_1} \cdot p_2
	\end{pmatrix}
\end{align}$

Let $F_i := p_i +  \frac{X_i}{\partial X_i / p_i}$, then in equilibrium,

$F_1 = F_2 = F_3 = \frac{p_1}{5} + \left(- \frac{X_2 \cdot p_2}{5} \right) \cdot \frac{1}{X_1} = \frac{p_3}{5} + \left(- \frac{X_2 \cdot p_2}{5} \right) \cdot \frac{1}{X_3}$

This condition yields the equilibrium condition,

$\frac{1}{5} \cdot (p_3 - p_1) + \frac{X_1}{X_3} \cdot F_3 - F_1 = 0$

which in equilibrium is,

$\frac{1}{5} \cdot (p_3 - p_1) + \left(\frac{X_1}{X_3} - 1 \right) \cdot F_1 = 0$

"""

# ╔═╡ fd0a274d-edd6-4076-ad09-dfd85a936b8e
begin
	es = [0.99, 0.99, 1.01]
	
	Xs = initstatetransition(Grid)(es)

	X₁, X₂, X₃ = Xs
end

# ╔═╡ 571f3a77-922f-4c38-b4ee-0c304dc1809d
md"""
We will implement this below. Let's assume the endowments `es` = $(join(es, ", ")). We can generate the three demand functions.
"""

# ╔═╡ 39a2e655-41b0-4943-93cd-1a337baa484c
begin	
	fig = plot(title = "Demand in case of endwoments, ε = $es", xlabel = "price")
	prices = range(0.05, 0.2, length = 1000)
	for (i, X) in enumerate(Xs)
		plot!(fig, prices, X, label = "X_$(i)(p)")
	end
	
	fig
	
end

# ╔═╡ eacca97f-eea2-4c75-825e-5b03c6c87e0e
F₁, F₂, F₃ = map(optimumlocal, Xs)

# ╔═╡ 59eb380c-e67d-470a-84b0-e7d503a3bef9
"""
Function to compute the equilibrium local prices on the leaf nodes 1 and 3
"""
function leafequilibrium(p₁::Float64, p₃::Float64)
	(p₃ - p₁) / 5 + F₁(p₁) * (X₁(p₁)/X₃(p₃) - 1)
end

# ╔═╡ 0b68ffb0-e00e-4202-9506-47c31acb7034
begin
	
	sectionfig = hline(
		[0], xlim = extrema(prices), c = :black,
		legend = :bottomleft, xlabel = "p₁", label = false,
		title = "Price 1 solutions for different values of price 3"
	)
	
	colors = palette(:tab10)
	
	p₃s = [0.075, 0.1, 0.12]

	for (i, p₃) in enumerate(p₃s)
		
		secf = p -> leafequilibrium(p, p₃)
		p₁zero = find_zero(secf, 0.8)
		
		plot!(sectionfig, prices, secf, label = "p₃ = $(p₃)", c = colors[i])
		
		scatter!(sectionfig, [p₁zero], [0.], c = colors[i], label = false)
			
		solution = trunc(p₁zero; digits = 3)
		
		annotate!(
			sectionfig, p₁zero, 0.005, text(solution, colors[i], :above, 10))
		
	end
	
	sectionfig
end

# ╔═╡ Cell order:
# ╠═259aca87-3d8a-4b08-b134-81f5e56fd9a6
# ╠═121d970c-88fa-4d78-81b5-c1eadb12865b
# ╟─6a48ed3d-4f7c-42f6-aef7-2be97d9b5b49
# ╠═f704ca13-b5db-4123-a33e-0e7c6c5eaaae
# ╟─ff361cfe-88dc-45a0-a51a-28632911d0ff
# ╟─a8fae4d5-97b3-4401-88fa-5d055232610c
# ╠═fd0a274d-edd6-4076-ad09-dfd85a936b8e
# ╟─571f3a77-922f-4c38-b4ee-0c304dc1809d
# ╠═39a2e655-41b0-4943-93cd-1a337baa484c
# ╠═eacca97f-eea2-4c75-825e-5b03c6c87e0e
# ╠═59eb380c-e67d-470a-84b0-e7d503a3bef9
# ╠═0b68ffb0-e00e-4202-9506-47c31acb7034
