c₁ = 100

c(s, r) = log(1 + exp(c₁ * s * r)) / c₁
S(s, r) = inv(1 + exp(-c₁ * s * r))

∂c∂s(s, r) = S(s, r) * r
∂c∂r(s, r) = S(s, r) * s