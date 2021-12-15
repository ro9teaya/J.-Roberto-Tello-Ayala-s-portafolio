from __future__ import division
import numpy as np
import sys

train_data = np.genfromtxt(sys.argv[1], delimiter = ",")

lam = 2
sigma2 = 0.1
d = 5

# Implement function here
def PMF(train_data):
    N1 = int(np.max(train_data[:,0]))
    N2 = int(np.max(train_data[:,1]))

    V = np.random.multivariate_normal(np.zeros(d), (1/lam)*np.eye(d), N2)
    U = np.ndarray([N1,d])

    U_matrices = [U]*50
    V_matrices = [V]*50
    
    L = np.zeros(50)
    sumaui = train_data[:,2]
    sumavi = train_data[:,1].astype(int)
    for t in range(50):
        for i in range(N1):
            indxu = (train_data[:,0] - 1 == i)
            Mi  = sumaui[indxu]
            vis = list(sumavi[indxu] - 1)
            vis = V[vis]
            U[i] = np.linalg.solve(lam*sigma2*np.eye(d)+np.sum([np.outer(r,r) for r in vis],axis = 0),(np.multiply(vis, Mi[:, np.newaxis])).sum(axis = 0))
        
        U_matrices[t] = U
        for j in range(N2):
            indxv = ((sumavi-1) == j)
            Mj = sumaui[indxv]
            uis = list(dict.fromkeys((train_data[:,0].astype(int) - 1)[indxv]))
            uis = U[uis]
            V[j] = np.linalg.solve(lam*sigma2*np.eye(d)+np.sum([np.outer(r,r) for r in uis],axis = 0),(np.multiply(uis, Mj[:, np.newaxis])).sum(axis = 0))
        
        V_matrices[t] = V
        for s in train_data:   
            L[t] = L[t] - (0.5/sigma2)*(s[2]-(U[int(s[0])-1]).dot(V[int(s[1])-1]))**2
        
        for u in U:
            L[t] = L[t] - 0.5*lam*np.linalg.norm(u)**2 
        for v in V:
            L[t] = L[t] - 0.5*lam*np.linalg.norm(v)**2 
            
    
    return L, U_matrices, V_matrices

# Assuming the PMF function returns Loss L, U_matrices and V_matrices (refer to lecture)
L, U_matrices, V_matrices = PMF(train_data)

np.savetxt("objective.csv", L, delimiter=",")

np.savetxt("U-10.csv", U_matrices[9], delimiter=",")
np.savetxt("U-25.csv", U_matrices[24], delimiter=",")
np.savetxt("U-50.csv", U_matrices[49], delimiter=",")

np.savetxt("V-10.csv", V_matrices[9], delimiter=",")
np.savetxt("V-25.csv", V_matrices[24], delimiter=",")
np.savetxt("V-50.csv", V_matrices[49], delimiter=",")
