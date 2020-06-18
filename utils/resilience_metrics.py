from typing import Tuple

import pandas as pd

def resilience(sim: pd.DataFrame, idxs = []) -> Tuple[float, float]:
    """
    Parameters
    ----------
    sim : pd.DataFrame
        return of simulate()

    Returns
    -------
    Tuple[float, float]
        shock intensity, time to recovery
    """        
    
    average_shock = sim.min()
    time_to_rec = (sim >= 1.).idxmax()

    if len(idxs) > 0:
        return average_shock[idxs], time_to_rec[idxs]

    return average_shock, time_to_rec


def resilience_test(verbose = False, cache = False, cached_res_path = "simulations/result.csv"):

    if cache and os.path.isfile(cached_res_path):
        if verbose:
            print("Using cached file!")

        df = pd.read_csv(cached_res_path)

        return df

    res = []

    for j in range(30):

        theta_two = np.random.uniform(
            0.2, 0.4, 6
        )

        firms = len(theta_two)

        inds = []
        
        for n in range(firms):

            i = Industry(
                fixed_overhead=overhead,
                alpha=3,
                theta_one=theta_one,
                theta_two=theta_two[n],
                params=params
            )

            inds.append(i)

        d = np.tril(np.random.randint(1, 10, size=(firms, firms)), -1)
    
        net = Network(inds, d)

        troph = net.trophic_inc

        if verbose: print(f"  {j+1}/30 -> incoherence:", troph, end='\r')

        df = simulate(net, iters=30, f=1.4, verbose=False)

        df.columns = [f"Industry {i}" for i in df.columns]
        
        s, t = resilience(df)



        datum = {
            "shock": s.mean().tolist(),
            "incoherence": troph,
            "time to recovery":t.mean().tolist()
        }

        res.append(datum)

    res = pd.DataFrame(res)

    res.to_csv(cached_res_path, index=False)

    return res