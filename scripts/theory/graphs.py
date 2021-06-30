import numpy.linalg as la
import networkx as nx
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

sns.set()
doplot = False


def pmatrix(a, digits=-1):
    """Returns a LaTeX pmatrix

    :a: numpy array
    :returns: LaTeX pmatrix as a string
    """
    if len(a.shape) > 2:
        raise ValueError('pmatrix can at most display two dimensions')

    a = np.round(a, digits) if digits > 0 else digits

    lines = str(a).replace('[', '').replace(']', '').splitlines()
    rv = [r'\begin{pmatrix}']
    rv += ['  ' + ' & '.join(l.split()) + r'\\' for l in lines]
    rv += [r'\end{pmatrix}']
    return '\n'.join(rv)


A = np.array([
    [0, 1, 1, 1, 0],
    [0, 0, 0, 0, 1],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0]
])

A = A + A.T

N = A.shape[0]

label_mapping = dict(zip(range(N), range(1, N + 1)))

Ag = nx.convert_matrix.from_numpy_array(A)

Ag = nx.relabel_nodes(Ag, label_mapping)


def makeline(Ag):
    unG = nx.generators.line_graph(Ag)

    H = nx.Graph()
    H.add_nodes_from(sorted(unG.nodes(data=True)))
    H.add_edges_from(unG.edges(data=True))

    return H


Lg = makeline(Ag)

nx.draw(Ag, with_labels=True)
plt.savefig("original.png")
plt.close()

nx.draw(Lg, with_labels=True)
plt.savefig("linegraph.png")
plt.close()

G = nx.to_numpy_array(Lg)

I = np.identity(G.shape[0])

inverse = np.linalg.inv(2*I + G)


def notdiag(A): return A - np.diag(np.diag(A))


effect = notdiag(inverse)

if doplot:
    matrices = [(G, "Adjacency"), (inverse, "Effect")]

    for M, name in matrices:
        M = notdiag(M)

        fig, ax = plt.subplots()

        sns.heatmap(M, ax=ax, cmap="coolwarm")
        ax.set_title(f"{name} matrix")

        ax.set_xticks([])
        ax.set_yticks([])

        fig.savefig(f"plots/{name}.png")

convergence = False
if convergence:
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
