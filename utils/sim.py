import pandas as pd
import numpy as np


def simulate_wage_shock(
    net: 'Network',
    f = 2,
    len_shock = 20,
    slow_rec = False,
    verbose=False
):

    T = len_shock + 20

    net.bring_to_steady(iters = 20, verbose=verbose)
    n = len(net)

    source = list(net.sources_index)[0]

    baseline = net.production + 1 # FIXME: This is here to prevent np.nan

    simulation = np.zeros((T, n))
    simulation[0] = 1


    w_0 = net[source].wage
    w_f = w_0 * f

    net[source].wage = w_f

    # shock
    for j in range(1, len_shock):
        net.step()
        simulation[j] = net.production / baseline

        if slow_rec:
            step = j / (len_shock - 1)
            w = step*(w_0 - w_f) + w_f

            net[source].wage = w

    net[source].wage = w_0
    
    for j in range(len_shock, T):
        net.step()
        simulation[j] = net.production / baseline

    columns = [
        f"Industry {i}" if i != source else "Source" for i in range(n)
    ]

    return pd.DataFrame(simulation, columns=columns)
