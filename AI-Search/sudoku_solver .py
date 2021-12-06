#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Apr 26 17:11:13 2020

@author: robertotello
"""
from copy import deepcopy
import sys

class sudoku(object):
    
    def __init__(self, config):
        self.config = config 
        
        dic = self.config
        
        self.r1 = {k: dic[k] for k in ['A1','A2','A3','A4','A5','A6','A7','A8','A9']}
        self.r2 = {k: dic[k] for k in ['B1','B2','B3','B4','B5','B6','B7','B8','B9']}  
        self.r3 = {k: dic[k] for k in ['C1', 'C2', 'C3','C4', 'C5', 'C6','C7', 'C8', 'C9']}
        self.r4 = {k: dic[k] for k in ['D1', 'D2', 'D3','D4', 'D5', 'D6','D7', 'D8', 'D9']}
        self.r5 = {k: dic[k] for k in ['E1', 'E2', 'E3','E4', 'E5', 'E6','E7', 'E8', 'E9']}
        self.r6 = {k: dic[k] for k in ['F1', 'F2', 'F3','F4', 'F5', 'F6','F7', 'F8', 'F9']}
        self.r7 = {k: dic[k] for k in ['G1', 'G2', 'G3','G4', 'G5', 'G6','G7', 'G8', 'G9']}
        self.r8 = {k: dic[k] for k in ['H1', 'H2', 'H3','H4', 'H5', 'H6','H7', 'H8', 'H9']}
        self.r9 = {k: dic[k] for k in ['I1', 'I2', 'I3','I4', 'I5', 'I6','I7', 'I8', 'I9']}
        self.r10 = {k: dic[k] for k in ['A1', 'A2', 'A3','B1', 'B2', 'B3','C1', 'C2', 'C3']}         
        self.r11 = {k: dic[k] for k in ['D1', 'D2', 'D3','E1', 'E2', 'E3','F1', 'F2', 'F3']}
        self.r12 = {k: dic[k] for k in ['G1', 'G2', 'G3','H1', 'H2', 'H3','I1', 'I2', 'I3']} 
        self.r13 = {k: dic[k] for k in ['A4', 'A5', 'A6','B4', 'B5', 'B6','C4', 'C5', 'C6']}         
        self.r14 = {k: dic[k] for k in ['D4', 'D5', 'D6','E4', 'E5', 'E6','F4', 'F5', 'F6']}
        self.r15 = {k: dic[k] for k in ['G4', 'G5', 'G6','H4', 'H5', 'H6','I4', 'I5', 'I6']}
        self.r16 = {k: dic[k] for k in ['A7', 'A8', 'A9','B7', 'B8', 'B9','C7', 'C8', 'C9']}         
        self.r17 = {k: dic[k] for k in ['D7', 'D8', 'D9','E7', 'E8', 'E9','F7', 'F8', 'F9']}  
        self.r18 = {k: dic[k] for k in ['G7', 'G8', 'G9','H7', 'H8', 'H9','I7', 'I8', 'I9']}  
        self.r19 = {k: dic[k] for k in ['A1', 'B1', 'C1','D1', 'E1', 'F1','G1', 'H1', 'I1']} 
        self.r20 = {k: dic[k] for k in ['A2', 'B2', 'C2','D2', 'E2', 'F2','G2', 'H2', 'I2']}
        self.r21 = {k: dic[k] for k in ['A3', 'B3', 'C3','D3', 'E3', 'F3','G3', 'H3', 'I3']}
        self.r22 = {k: dic[k] for k in ['A4', 'B4', 'C4','D4', 'E4', 'F4','G4', 'H4', 'I4']}
        self.r23 = {k: dic[k] for k in ['A5', 'B5', 'C5','D5', 'E5', 'F5','G5', 'H5', 'I5']}
        self.r24 = {k: dic[k] for k in ['A6', 'B6', 'C6','D6', 'E6', 'F6','G6', 'H6', 'I6']}
        self.r25 = {k: dic[k] for k in ['A7', 'B7', 'C7','D7', 'E7', 'F7','G7', 'H7', 'I7']}
        self.r26 = {k: dic[k] for k in ['A8', 'B8', 'C8','D8', 'E8', 'F8','G8', 'H8', 'I8']}
        self.r27 = {k: dic[k] for k in ['A9', 'B9', 'C9','D9', 'E9', 'F9','G9', 'H9', 'I9']}
        
        self.rs = [self.r1,self.r2,self.r3,self.r4,self.r5,self.r6,self.r7,self.r8,self.r9,self.r10,self.r11,self.r12,self.r13,self.r14,self.r15,self.r16,self.r17,self.r18,self.r19,self.r20,self.r21,self.r22,self.r23,self.r24,self.r25,self.r26,self.r27]
    
    def insert(self, clave, valor):
        dic = self.config
        
        self.r1 = {k: dic[k] for k in ['A1','A2','A3','A4','A5','A6','A7','A8','A9']}
        self.r2 = {k: dic[k] for k in ['B1','B2','B3','B4','B5','B6','B7','B8','B9']}  
        self.r3 = {k: dic[k] for k in ['C1', 'C2', 'C3','C4', 'C5', 'C6','C7', 'C8', 'C9']}
        self.r4 = {k: dic[k] for k in ['D1', 'D2', 'D3','D4', 'D5', 'D6','D7', 'D8', 'D9']}
        self.r5 = {k: dic[k] for k in ['E1', 'E2', 'E3','E4', 'E5', 'E6','E7', 'E8', 'E9']}
        self.r6 = {k: dic[k] for k in ['F1', 'F2', 'F3','F4', 'F5', 'F6','F7', 'F8', 'F9']}
        self.r7 = {k: dic[k] for k in ['G1', 'G2', 'G3','G4', 'G5', 'G6','G7', 'G8', 'G9']}
        self.r8 = {k: dic[k] for k in ['H1', 'H2', 'H3','H4', 'H5', 'H6','H7', 'H8', 'H9']}
        self.r9 = {k: dic[k] for k in ['I1', 'I2', 'I3','I4', 'I5', 'I6','I7', 'I8', 'I9']}
        self.r10 = {k: dic[k] for k in ['A1', 'A2', 'A3','B1', 'B2', 'B3','C1', 'C2', 'C3']}         
        self.r11 = {k: dic[k] for k in ['D1', 'D2', 'D3','E1', 'E2', 'E3','F1', 'F2', 'F3']}
        self.r12 = {k: dic[k] for k in ['G1', 'G2', 'G3','H1', 'H2', 'H3','I1', 'I2', 'I3']} 
        self.r13 = {k: dic[k] for k in ['A4', 'A5', 'A6','B4', 'B5', 'B6','C4', 'C5', 'C6']}         
        self.r14 = {k: dic[k] for k in ['D4', 'D5', 'D6','E4', 'E5', 'E6','F4', 'F5', 'F6']}
        self.r15 = {k: dic[k] for k in ['G4', 'G5', 'G6','H4', 'H5', 'H6','I4', 'I5', 'I6']}
        self.r16 = {k: dic[k] for k in ['A7', 'A8', 'A9','B7', 'B8', 'B9','C7', 'C8', 'C9']}         
        self.r17 = {k: dic[k] for k in ['D7', 'D8', 'D9','E7', 'E8', 'E9','F7', 'F8', 'F9']}  
        self.r18 = {k: dic[k] for k in ['G7', 'G8', 'G9','H7', 'H8', 'H9','I7', 'I8', 'I9']}  
        self.r19 = {k: dic[k] for k in ['A1', 'B1', 'C1','D1', 'E1', 'F1','G1', 'H1', 'I1']} 
        self.r20 = {k: dic[k] for k in ['A2', 'B2', 'C2','D2', 'E2', 'F2','G2', 'H2', 'I2']}
        self.r21 = {k: dic[k] for k in ['A3', 'B3', 'C3','D3', 'E3', 'F3','G3', 'H3', 'I3']}
        self.r22 = {k: dic[k] for k in ['A4', 'B4', 'C4','D4', 'E4', 'F4','G4', 'H4', 'I4']}
        self.r23 = {k: dic[k] for k in ['A5', 'B5', 'C5','D5', 'E5', 'F5','G5', 'H5', 'I5']}
        self.r24 = {k: dic[k] for k in ['A6', 'B6', 'C6','D6', 'E6', 'F6','G6', 'H6', 'I6']}
        self.r25 = {k: dic[k] for k in ['A7', 'B7', 'C7','D7', 'E7', 'F7','G7', 'H7', 'I7']}
        self.r26 = {k: dic[k] for k in ['A8', 'B8', 'C8','D8', 'E8', 'F8','G8', 'H8', 'I8']}
        self.r27 = {k: dic[k] for k in ['A9', 'B9', 'C9','D9', 'E9', 'F9','G9', 'H9', 'I9']}
        
        self.rs = [self.r1,self.r2,self.r3,self.r4,self.r5,self.r6,self.r7,self.r8,self.r9,self.r10,self.r11,self.r12,self.r13,self.r14,self.r15,self.r16,self.r17,self.r18,self.r19,self.r20,self.r21,self.r22,self.r23,self.r24,self.r25,self.r26,self.r27]
        
        if valor in self.config[clave][1]:
            self.config[clave] = [valor,{valor}]
            
            for r in self.rs:
                if clave in r:
                    for j in r:
                        if j == clave:
                            continue
                        else:
                            dic[j][1].discard(valor)	
                            
    def get_sudoku(self): 
        return self.config
    
    def restricciones(self):
        dic = self.config
        
        dom = {1,2,3,4,5,6,7,8,9}             
    
        for d in dic:
            if dic[d][0] == 0:
                conj = set()
                for r in self.rs:
                    if d in r:
                        for k in r:
                            if r[k][0] != 0:
                                conj.add(r[k][0])        
                dic[d] = [0, dom.difference(conj)]
    
    def producto(self):
        queue = set()
        for i in self.get_sudoku():
            if self.get_sudoku()[i][0] == 0:
                for r in self.rs:
                    if i in r:
                        for k in r:
                            if k != i and self.get_sudoku()[k][0] == 0:
                                queue.add((i,k))
        return queue



if __name__ == "__main__":
    
    def linea(csp):
        d = []
        for i in csp.get_sudoku():
            d.append(csp.get_sudoku()[i][0])
        
        return ''.join(map(str,d))
    
    def configura(texto):    
        texto = list(map(int, str(texto)))
        t = 0
        d = {}
            
        for j in ['A','B','C','D','E','F','G','H','I']:
            for i in range(1,10):
                d[f'{j}{i}'] =[texto[t],{texto[t]}]
                t += 1  
        return d

    def variable(csp):
        t = deepcopy(csp)
        dic = t.get_sudoku()
             
        pequena2 = 9
            
        for i in dic:
            if ((dic[i][0] == 0) and len(dic[i][1]) < pequena2):
                pequena1 = i
                pequena2 = len(dic[i][1])          
        return pequena1               
    
    def ordena(var, csp): 
        d = deepcopy(csp)
        acciones = d.get_sudoku()
        dominio = list(acciones[var][1])
        
        dic = dict.fromkeys(dominio,0)
        
        for i in dominio:
            copia = deepcopy(csp)
            copia.insert(var,i)
            
            for j in acciones:
                if acciones[j][1] != copia.get_sudoku()[j][1]:
                    dic[i] += 1          
        return min(dic, key = dic.get)
    
    def verifica(csp):
        copia = deepcopy(csp)
        dic = copia.get_sudoku()
        
        for i in dic:
            dic[i] = dic[i][0]
        if (all(value != 0 for value in dic.values())):
            return True
        else:
            return False
    
    def BTS(csp):
        return backtrack(csp)
    
    def backtrack(csp):   
        if verifica(csp):
            return csp
        
        var = variable(csp)
        for i in list(csp.get_sudoku()[var][1]):
            copia = deepcopy(csp)
            copia.insert(var,i)
            try:
                resultado = backtrack(copia)
            except BaseException as error:
                resultado = 111111
            if resultado != 111111:
                return resultado
        return 111111
        
        
    def AC3(csp):
        
        queue =  list(csp.producto())
        
        while queue != []:
            t = queue.pop()
            Xi = t[0]
            Xj = t[1]
            if revise(csp,t):
                if len(csp.config[Xi][1]) == 0:
                    return False
                for r in csp.rs:
                    if t[0] in r:
                        for k in r:
                            if (Xi != k or Xj != k) and csp.get_sudoku()[k][0] == 0:
                                queue.append((k,Xi))
        return True                            
            
    def revise(csp,t):
        Xi = t[0]
        Xj = t[1]
        
        revised = False
        
        itera = list(csp.get_sudoku()[Xi][1])
        for x in itera:
            copia = deepcopy(csp)
            copia.insert(Xi,x)
            if copia.get_sudoku()[Xj][1] == set():
                csp.config[Xi][1].discard(x)
                revised = True
        
        return revised
    
    def resuelto(csp):
        for i in csp.get_sudoku():
            if len(csp.get_sudoku()[i][1]) > 1:
                return False
        return True
    
    d = str(sys.argv[1])
    dic = configura(d)
    s = sudoku(dic)
    s.restricciones()
    
    assignment = AC3(s)
    if (resuelto(s)):
          n = linea(s) + " AC3"
    d = str(sys.argv[1])
    dic = configura(d)
    s = sudoku(dic)
    s.restricciones()
    s = BTS(s)
    n = linea(s) + " BTS" 
    
    with open("output.txt","w") as output:
        output.write(n)