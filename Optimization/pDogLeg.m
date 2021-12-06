function [p] = pDogLeg( B, g, delta)
% In : B ... an s.p.d. matrix that approximates the hessian of f in xk
% g ... (vector) gradient of f in xk
% delta ... trust region radius
%
% Out: p ... The dogleg point
    
    
    escala = norm(g);
    alphau = -escala^2/dot(g,B*g);
    pu = alphau*g;
           
    if alphau >= delta/escala
        p = -delta/escala * g;
    else
        pb = -linsolve(B,g);    
        if norm(pb) <= delta
            p = pb;
        else
            resta = pb - pu;
            u = dot(resta,pu);
            nu = norm(resta)^2;
            alpha1 = (-2 * u + sqrt(4 * u^2 - 4 * nu * (norm(pu)^2 - delta^2)))/(2 * nu);
            alpha2 = (-2 * u - sqrt(4 * u^2 - 4 * nu * (norm(pu)^2 - delta^2)))/(2 * nu);
            if alpha1 >= 0 && alpha1 <= 1
                alpha = alpha1;
            else
                alpha = alpha2;
            end
            
            p = pu + alpha*resta;
        end
    end    
end
