import networkx as nx
import numpy as np

def ppmodel(N: int, T: float, S: int = 5):
    """
    Implementation of the preferential praying model, 
    using Johnson S, Domı́nguez-Garcı́a V, Donetti L, Muñoz MA (2014)

    Parameters
    ----------
    T : float
        Desired coherence level
    S : int
        Number of base nodes
    N : int
        Total number of nodes
    """

    if N < S:
        raise ValueError(f"N={N} < S={S}")

    G = nx.DiGraph()
    G.add_nodes_from(range(S))

    for s_node in range(N - S):

        n = len(G)
        
        G.add_node(s_node)
        assign = np.random.uniform(n)
        G.add_edge(s_node, assign)


        beta = -1 + (np.square(N) - np.square(S)) / 4
        extra_pray = int(n * np.random.beta(1, beta))

        ks = np.random.randint(0, n, size=extra_pray)

        for k_node in ks:
            try:
                d = nx.shortest_path(G, source = s_node, target = k_node)
            except nx.exception.NetworkXNoPath:
                d = []
            
            p = np.exp(-len(d)/T)

            G.add_edge(k_node, s_node, weight = p)

    return G


if __name__ == '__main__':
    G = ppmodel(10, 2.2)

