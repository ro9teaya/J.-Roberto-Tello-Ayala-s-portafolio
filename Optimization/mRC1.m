function [x, msg] = mRC1( f, x0, itmax )
% Trust region method using the Cauchy point.
%
% In : f ... (handle) function to be optimized
% x0 ... (vector) initial point
% itmax ... (natural number) upper bound for number of iterations
%
% Out: x ... (vector) last approximation of a stationary point
% msg ... (string) message that says whether (or not) a minimum was found

    eta = 0.1;
    deltaMax = 1.5;
    delta = deltaMax; 
    x = x0;
    tol = 10^-5;
    k = 0;
    gk = apGrad(f, x);
    
    while (k < itmax) && (norm(gk,Inf) > tol) 
        
        [~,gk,Bk] = fEasom();
        gk = gk(x);
        Bk = Bk(x);
        
        dk = pCauchy(Bk,gk,delta);
        
        coc = -(f(x)-f(x+ dk))/ (dot(gk,dk) + 0.5*dot(dk,Bk*dk));
        
        if coc < 0.25
            delta = 0.25*delta;
        else
            if coc > 0.75 && (delta - norm(dk)) <= eps
                delta = min(2*delta, deltaMax);     
            end      
        end     
        if (coc > eta)
            x = x + dk;
        end
         
        k = k + 1;
    end
    
    [~,p] = chol(Bk);
    if p == 0
        msg = '-';
    
    else
        msg = 'The method did not converge';
    end
end
