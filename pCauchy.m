function [pC] = pCauchy( B, g, delta )
% In : B ... (symmetric matrix) approximates the hessian of f in xk
% g ... (vector) gradient of f in xk
% delta ... trust region radius
%
% Out: pC ... The Cauchy point


    p = norm(g);
    g = g/p;
    
    prueba = dot(g,B*g);
    
    if prueba > 0
        alphaStar = p/ (delta*prueba);
    else
        alphaStar = 1;       
    end
    
    alphaStar = 0.99*alphaStar;
    
    pC = -delta * min(1, alphaStar) * g;
    
end

