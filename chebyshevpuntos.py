#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jul  9 17:51:14 2020

@author: robertotello
"""

import numpy as np
from numpy import linalg as LA
import matplotlib.pyplot as plt

def biseccion(f, cota_inferior, cota_superior, tol):
    '''
    Metodo de la biseccion para encontrar raices de la funcion f, f(x) = 0,
    en el intervalo [cota_inferior, cota_superior]. Para que el metodo inicie,
    es necesario que se cumpla la siguiente condicion:
    f(cota_inferior)*f(cota_superior) < 0
    
    Entradas
    ----------
    f : Funcion de tipo lambda
        Funcion a la que se busca una raiz en el intervalo
        [cota_inferior, cota_superior].
    cota_inferior : Numero de precision doble 
        Extremo izquierdo del intervalo.
    cota_superior : Numero de precision doble 
        Extremo derecho del intervalo.
    tol : Numero de precision doble 
        Tolerancia o precison del metodo.

    Salida
    -------
    xk : Numero de precision doble 
        raiz de la funcion f, f(xk) = 0.

    '''
    assert(f(cota_inferior)*f(cota_superior) < 0)
    
    while (cota_superior-cota_inferior > tol):
        xk = (cota_superior + cota_inferior)/2
        
        if (f(cota_inferior)*f(xk) > 0):
            cota_inferior = xk
        else:
            cota_superior = xk
    
    return xk
                
def projeccion_simplejo(y):
    '''
    Funcion que calcula la proyeccion ortogonal del vector y al simplejo unitario
    
    Parameters
    ----------
    y : Arreglo de numpy
        Vector al que se busca encontrar la proyeccion ortogonal.

    Returns
    -------
    z : Arreglo de numpy
        La proyeccion ortogonal.


    '''
    f = lambda a : np.sum(np.maximum(y-a,0)) - 1
    n = y.shape[0]
    cota_inferior = np.min(y) - 2/n
    cota_superior = np.max(y)
    lam = biseccion(f, cota_inferior, cota_superior, 1e-12)
    z = np.maximum(y-lam,0)
    
    return z

def centros_puntos(X):
    '''
    Funcion que calcula el centro y el radio de Chebyshev de un conjunto de 
    puntos en R^n

    Entrada
    ----------
    X : Arreglo de numpy, matrix
        Matriz que contiene como columnas a los k puntos, X = [x1|...|xk].

    Salidas
    -------
    c : Arreglo de numpy, vector
        El centro de Chebyshev del conjunto de puntos.
    r : Numero de precision doble
        El radio de Chebyshev del conjuto de puntos.

    '''
    m = X.shape[1]
    Q = (X.transpose()).dot(X)
    L = 2*np.max(LA.eigvalsh(Q))
    b = np.sum(np.square(X), axis=0)
    
    lam = 1/m * np.ones([m,])
    lam_vieja = np.zeros([m,])
    while (LA.norm(lam-lam_vieja,np.inf) > 1e-6):
        lam_vieja = lam
        lam = projeccion_simplejo(lam + 1/L*(-2*Q.dot(lam)+b))
        
    c = X.dot(lam)
    r = 0
    
    for i in range(m):
        r = max(r,LA.norm(c-X[:,i]))
    
    return c, r
    
N = 50
x = np.random.rand(N)
y = np.random.rand(N)
X = np.array([x,y])
c,r = centros_puntos(X)

figure, axes = plt.subplots() 
plt.xlim(1.25*r+c[0],c[0]-1.25*r)
plt.ylim(1.25*r+c[1],c[1]-1.25*r)
circulo = plt.Circle(tuple(c), r, fill = False)
axes.set_aspect(1)
axes.add_artist(circulo)
plt.scatter(x, y,color='red')
plt.scatter(c[0],c[1])
plt.title('Bola de Chebyshev de un conjunto aleatorio de puntos.')
plt.savefig('foo.pdf',bbox_inches='tight', dpi=3000)
plt.show()