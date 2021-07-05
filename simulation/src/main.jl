using LightGraphs, GraphPlot
using LightGraphs.LinAlg, LinearAlgebra

using Agents
using Random, Distributions

using Base.Threads

using Plots, LaTeXStrings, GraphPlot, StatsPlots
using Cairo, Compose
using DataFrames

include("utils.jl")
include("models/agents.jl")

include("models/policies/provider.jl")
include("models/policies/producer.jl")
include("models/beliefs/provider.jl")

include("models/bargaining.jl")
include("models/evolution.jl")
include("models/init.jl")

include("softpluscosts.jl")
include("plot.jl")
include("makegraph.jl")

ENV["GKSwstype"] = "nul"