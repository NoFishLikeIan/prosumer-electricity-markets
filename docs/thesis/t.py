import numpy as np
import numpy.linalg as la
import itertools
import matplotlib.pyplot as plt

n = 5


def makeG(n):
    G = np.diag(np.ones(n - 1), k=1)
    return G - G.T


def I(G):
    return np.eye(G.shape[0])


G = makeG(n)
M = 2 * I(G) + G

compinv = la.inv(M)

theta_n = la.det(M)

sq2 = np.sqrt(2)
twosq2 = 2*np.sqrt(2)


def phi(i, n):
    if i == n:
        return 2
    if i == n+1:
        return 1

    return 2*phi(i+1, n) + phi(i+2, n)


def theta(i):
    if i == 0:
        return 1
    if i == 1:
        return 2

    return 2*theta(i - 1) + theta(i - 2)


def pellnumber(i):
    pos = 1 + sq2
    neg = 1 - sq2

    return (np.power(pos, i) - np.power(neg, i)) / twosq2


def huangratio(i, j, n):
    return phi(j + 1, n)*theta(i - 1) / theta(n)


def H(i, j, n):

    return pellnumber(n + 1 - j) * pellnumber(i) / pellnumber(n+1)


def theoreticalinv(i, j, M):
    n = M.shape[0]

    if i > j:
        sign = np.power(-1, 2*i)

        return sign*H(j, i, n)
    else:
        sign = np.power(-1, i + j)

        return sign*H(i, j, n)


thinv = np.zeros((n, n))

for (i, j) in itertools.product(range(n), range(n)):
    thinv[i, j] = theoreticalinv(i + 1, j + 1, M)

if np.allclose(thinv, compinv):
    print("Approximation: Success")
else:
    print("Approximation: Failure")

deltap = 1 + np.sqrt(2)
deltam = 1 - np.sqrt(2)


def firstsum(j):
    return pellnumber(j)*deltap - pellnumber(j + 1)


def limitinv(i, j):

    sign = np.power(-1, j + 1)

    return sign*firstsum(j)*pellnumber(i)


def simplified(i, j):
    diff = np.power(deltap, i) - np.power(deltam, i)
    m = np.power(deltam, j)
    sign = np.power(-1, j)

    return sign*m*diff/twosq2


def delt(i, j):

    sign = np.power(-1, j)

    fct = np.power(deltap, i) * np.power(deltam, j) - np.power(deltam, i+j)

    return sign * np.power(-1, j) * fct / twosq2


def diagdelt(i, n=150):
    return sum(delt(i, j) for j in list(range(1, n)))


entries = list(range(1, 10))
bargaining = [diagdelt(i) for i in entries]

plt.plot(entries, bargaining)
plt.savefig("t.png")
