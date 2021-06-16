supply(model) = sum(agent.s for agent in agents_in_position(1, model) if agent isa Producer)
price(model) = sum(agent.p for agent in agents_in_position(1, model) if agent isa Provider)