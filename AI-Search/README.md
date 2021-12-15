This folder contains a script that solves sudoku configurations based on Contraint Satisfaction Algorithms. It utilizes either the AC-3 algorithm or backtracking search. To run the file in the terminal type: $pyhton3 sudoku_solver.py <sudoku_config>. 

Any <sudoku_config> can be taken from the sudoku_start.txt file. For instance, for running the first configuration: 
$pyhton3 sudoku_solver.py 000000000302540000050301070000000004409006005023054790000000050700810000080060009

The actual configuration would look like this:

000000000
302540000
050301070
000000004
409006005
023054790
000000050
700810000
080060009

The program will output a .txt file with the corresponding solution and the algorithm used.
