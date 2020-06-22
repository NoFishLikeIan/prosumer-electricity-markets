from typing import Tuple

import pandas as pd
import numpy as np

def resilience(sim: pd.DataFrame, rec_th = 1., idxs = []) -> Tuple[float, float]:
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
    
    average_shock = sim.min() - 1
    time_to_rec = (sim >= rec_th)[1:].idxmax()

    if len(idxs) > 0:
        return average_shock[idxs], time_to_rec[idxs]

    return average_shock, time_to_rec