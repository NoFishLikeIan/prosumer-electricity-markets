getjumpindex(arr, start, N) = arr[start:N:length(arr)]

function update_belief!(provider::Provider, model)

    node = provider.pos
    N = length(model.space.s)

    R = getjumpindex(model.R, node, N)
    p = getjumpindex(model.p, node, N)

    if !all(R .== 0) & !all(p .== 0)

        X = hcat(ones(length(p)), p)

        a, b = inv(X'X) * (X'R)

        if b == 0.
            throw("Zero b with \n $X \n $p")
        end

        provider.a = a # FIXME: Why is it negative?
        provider.b = b

    end

end