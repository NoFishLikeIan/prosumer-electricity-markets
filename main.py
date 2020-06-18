import os

import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import pandas as pd
import networkx as nx

from rr_model.network import Network
from rr_model.model import Industry

from utils.resilience_metrics import resilience_test
from utils.plotting import plot_trophic, plot_sim
from utils.sim import simulate

sns.set(rc={'figure.figsize': (12, 8)})
np.random.seed(11148705)

def generate_network(firms: int,
        theta_two = None,
        d = None, 
        theta_one = 0.2,
        overhead = 0.06,
        params = {"lambda": 0.3, "beta": 0.95}
    ) -> Network:

    theta_two = theta_two or np.random.uniform(0.2, 0.3, firms)

    inds = [
        Industry(
            fixed_overhead=overhead,
            alpha=3,
            theta_one=theta_one,
            theta_two=t,
            params=params
        ) for t in theta_two
    ]

    d = d or np.tril(np.random.randint(1, 10, size=(firms, firms)), -1)

    return Network(inds, d)


def main_two(cache = False, verbose = True):

    res = resilience_test(verbose=verbose, cache=cache)

    fig, axes = plot_trophic(res)

    fig.savefig("plots/coherence_corr.png")

def main_one():
    net = generate_network(3)

    sim = simulate(net, iters=50, f=1.05)

    sim.to_csv("sim.csv")

    fig, ax = plot_sim(sim)

    fig.savefig("plots/wage_shock.png")
    

if __name__ == '__main__':

    main_one()