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
