import os

import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import pandas as pd
import networkx as nx

from mpl_toolkits import mplot3d
from matplotlib import animation

from rr_model.model import Industry
from rr_model.network import Network
from utils.resilience_metrics import resilience
from utils.plotting import plot_trophic


sns.set(rc={'figure.figsize': (12, 8)})
np.random.seed(11148705)

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

def resilience_test(verbose = False, cache = False):

    cached_res_path = "simulations/result.csv"

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


if __name__ == '__main__':

    cache = False
    verbose = True

    theta_one = 0.2
    overhead = 0.06

    params = {
        "lambda": 0.3,
        "beta": 0.95
    }

    res = resilience_test(verbose=verbose, cache=cache)

    fig, axes = plot_trophic(res)

    fig.savefig("coherence_corr.png")