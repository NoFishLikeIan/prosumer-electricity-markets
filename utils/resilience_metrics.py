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

    if len(idxs) == 0:
        idxs = list(range(df.shape[1]))
    
    average_shock = sim.min()
    time_to_rec = (sim >= 1.).idxmax()


    return average_shock[idxs], time_to_rec[idxs]
