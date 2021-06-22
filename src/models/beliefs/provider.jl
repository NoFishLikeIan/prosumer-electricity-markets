getjumpindex(arr, start, N) = arr[start:N:length(arr)]

function update_belief!(provider::Provider, model, node)

    N = length(model.space.s)

    R = getjumpindex(model.R, node, N)

    X = hcat(ones(length(R)), R)
    p = getjumpindex(model.p, node, N)

    a, b = inv(X'X) * (X'p)

    provider.a = a
    provider.b = b

end