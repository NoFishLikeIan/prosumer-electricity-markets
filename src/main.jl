using LightGraphs, GraphPlot
using Agents

using Random, Distributions

using Roots, Optim

Random.seed!(11148705)

include("utils.jl")
include("models/agents.jl")

include("models/policies/provider.jl")
include("models/policies/producer.jl")
include("models/beliefs/provider.jl")
include("models/beliefs/producer.jl")

include("models/evolution.jl")
include("models/init.jl")

include("plot.jl")