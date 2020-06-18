from ..rr_model.network import Network

def simulate(net: Network, iters=150, verbose=True, f=2):
    if verbose:
        print("Bringing to steady...")

    net.bring_to_steady(iters=iters, verbose=verbose)
    n = len(net)

    prev_wage = net[n-1].wage
    next_wage = prev_wage*f

    net[n-1].wage = next_wage

    if verbose:
        print(f"Wage: {prev_wage} -> {next_wage}")

    data = [[] for _ in range(n)]

    base = [net[i].aggregate_prod for i in range(n)]

    if verbose:
        print("Shock...")

    for _ in range(iters):
        if verbose:
            print(f"{_+1}/{iters}", end='\r')

        for i in range(n):
            net[i].step()
            prod = net[i].aggregate_prod / base[i]
            data[i].append(prod)

    net[n-1].wage = prev_wage

    if verbose:
        print("...recovery...")

    recovery_iters = iters*3

    for _ in range(recovery_iters):
        if verbose:
            print(f"{_+1}/{recovery_iters}", end='\r')

        for i in range(n):
            net[i].step()
            prod = net[i].aggregate_prod / base[i]
            data[i].append(prod)

    if verbose:
        print("...done!")

    return pd.DataFrame(data).T