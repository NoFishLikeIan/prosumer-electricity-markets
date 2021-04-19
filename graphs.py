import networkx as nx
import numpy as np
import matplotlib.pyplot as plt

import numpy.linalg as la


def pmatrix(a):
    """Returns a LaTeX pmatrix

    :a: numpy array
    :returns: LaTeX pmatrix as a string
    """
    if len(a.shape) > 2:
        raise ValueError('pmatrix can at most display two dimensions')
    lines = str(a).replace('[', '').replace(']', '').splitlines()
    rv = [r'\begin{pmatrix}']
    rv += ['  ' + ' & '.join(l.split()) + r'\\' for l in lines]
    rv += [r'\end{pmatrix}']
    return '\n'.join(rv)


do_plot = False

A = [[0, 1, 0, 0, 0, 0, 0],
     [0, 0, 1, 1, 0, 0, 0],
     [0, 0, 0, 0, 0, 1, 0],
     [0, 0, 0, 0, 1, 0, 0],
     [0, 0, 0, 0, 0, 1, 0],
     [0, 0, 0, 0, 0, 0, 1],
     [0, 0, 0, 0, 0, 0, 0]]

A = np.array(A)

Ag = nx.convert_matrix.from_numpy_array(A, create_using=nx.DiGraph)

Lg = nx.generators.line_graph(Ag)

if do_plot:
    nx.draw(Ag, with_labels=True)
    plt.savefig("original.png")
    plt.close()

    nx.draw(Lg, with_labels=True)
    plt.savefig("linegraph.png")
    plt.close()

G = nx.to_numpy_array(Lg)
G = G - G.T
I = np.identity(G.shape[0])

inverse = np.linalg.inv(2*I + G)


# Convergence

t = -0.5
B = t*G
neumann = la.inv(I - B)

print("||tG|| = ", la.norm(B, ord=2))


def expansion(B):
    K = np.zeros(B.shape)

    for k in range(0, 1_000_000):
        P = la.matrix_power(B, k)
        K_p = K + P

        if np.allclose(K_p, K):
            print(f"Ending at k = {k}")
            return K

        K = K_p

    return K_p


E = expansion(B)

print("Correct: ", np.allclose(neumann, E))
