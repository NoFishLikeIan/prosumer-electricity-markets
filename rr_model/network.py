import networkx as nx
import numpy as np

from itertools import permutations
from networkx.algorithms.centrality import trophic

from typing import List, NoReturn, Tuple, Iterable

from .model import Industry


class Network:
    def __init__(self, nodes: List[Industry], d_matrix: np.array):
        self.nodes = nodes

        for supp, to in permutations(range(self.n), 2):
            dep = d_matrix[supp, to]

            if dep != 0:
                self.nodes[to].add_supplier(
                    self.nodes[supp],
                    dep
                )

        self.G = nx.from_numpy_array(
            d_matrix, create_using=nx.DiGraph)

    def __getitem__(self, item):
        return self.nodes[item]

    def __len__(self):
        return len(self.nodes)

    @property
    def n(self):
        return len(self)

    @property
    def sources_index(self) -> Iterable[int]:

        indices = (node for node, indegree in self.G.in_degree(
            self.G.nodes()) if indegree == 0)

        return indices

    @property
    def sources(self) -> Iterable[Industry]:
        return (self.nodes[i] for i in self.sources_index)

    @property
    def trophic_inc(self):
        return trophic.trophic_incoherence_parameter(self.G)


    def ist_steady(self) -> NoReturn:
        """
        Bring DAG to steady state istantenously
        """

        for node in self.nodes:
            node.set_steady()

        

    def step(self) -> NoReturn:
        """
        Traverses the DAG once, based on in-nodes hierarchy
        """
        nodes = list(self.sources_index)

        while len(nodes) > 0:

            idx = nodes.pop(0)

            self.nodes[idx].step()
            
            nodes += [succ for succ in self.G.successors(idx)]

    def bring_to_steady(self, verbose=False, iters=None, inst=True) -> NoReturn:
        
        if inst:
            # FIXME: Doesn't work
            self.ist_steady()
        else:
            for i in range(iters):
                if verbose:
                    print(f'{i+1}/{iters}', end='\r')

                self.step()
