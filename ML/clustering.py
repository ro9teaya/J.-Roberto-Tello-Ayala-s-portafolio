import numpy as np
import pandas as pd
import scipy as sp
import sys
from scipy.stats import multivariate_normal

X = np.genfromtxt(sys.argv[1], delimiter = ",")

def KMeans(data):
	#perform the algorithm with 5 clusters and 10 iterations...you may try others for testing purposes, but submit 5 and 10 respectively    
    m,n = np.shape(data) #takes dimensions of data matrix
    
    # initializes the centroid vector by randomly sampling 5 columns from the data matrix
    mu = data[np.random.choice(m, 5, replace=False), :]
    # creates the vector tha will hoid the values of each data point correspondig to the cluster
    centerslist = np.zeros(m)
    
    for i in range(10): # takes 10 iterations of the algorithm, as requested
        
        #selects the c_i for each data point
        for k in range(m):
            val = [(np.linalg.norm(data[k]-mu[j]))**2 for j in range(5)]
            centerslist[k] = val.index(min(val)) + 1
        
        #computes the n_k'a
        n_k = [np.count_nonzero(centerslist == (y+1)) for y in range(5)]
        
        # creates a new matrix of zeros that will hold the updated values
        mus = np.zeros([5,n])
        
        # updates the centroids
        for p in range(5):
            if(n_k[p] != 0):
                for t in range(m):   
                    if((p+1) == centerslist[t]):
                        mus[p] = mus[p] + (data[t])*(1/(n_k[p]))
            else: 
                mus[p] = mu[p]
        mu = mus

        filename = "centroids-" + str(i+1) + ".csv" #"i" would be each iteration
        np.savetxt(filename, mu, delimiter=",")

  
def EMGMM(data):
    k = 5
    m,n = np.shape(data)
    pi = (1/k)*np.ones(k)
    mu = data[np.random.choice(m, k, replace=False), :]
    sigma = [np.eye(n)]*k
    phi = np.ndarray([m,k])
    normi = np.ndarray([m,k])
    
    for i in range(10):
        normales = [multivariate_normal(mu[t],sigma[t]) for t in range(k)]
        for r in range(m):
            for s in range(k):
                normi[r][s] = normales[s].pdf(data[r])
                
        for r in range(m):
            for s in range(k):
                phi[r][s] = (pi[s]*normi[r][s])/(pi.dot(normi[r]))
    
        n_k = np.sum(phi, axis = 0)
        pi = (1/m)*n_k
        mu = np.zeros([5,n])
        sigma = k*[np.zeros([n,n])]
        
        for s in range(k):
            for r in range(m):
                mu[s] = mu[s] + (phi[r,s]*(data[r]))
            mu[s] = (1/n_k[s])*mu[s]
            for r in range(m):
                sigma[s] = sigma[s] + phi[r,s]*np.outer(data[r]-mu[s],data[r]-mu[s])
            sigma[s] = (1/n_k[s])*sigma[s]       
    
    
        filename = "pi-" + str(i+1) + ".csv" 
        np.savetxt(filename, pi, delimiter=",") 
        filename = "mu-" + str(i+1) + ".csv"
        np.savetxt(filename, mu, delimiter=",")  #this must be done at every iteration
    
        for j in range(k): #k is the number of clusters 
            filename = "Sigma-" + str(j+1) + "-" + str(i+1) + ".csv" #this must be done 5 times (or the number of clusters) for each iteration
            np.savetxt(filename, sigma[j], delimiter=",")

KMeans(X)
EMGMM(X)