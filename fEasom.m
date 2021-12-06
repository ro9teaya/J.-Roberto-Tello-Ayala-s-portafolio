function [f, Df,Hf] = fEasom()
% Easom function
% f function handle for the function
% Df function handle for the gradient
% Hf function handle for the hessian

    f = @(x) -cos(x(1))*cos(x(2))*exp(-(x(1)-pi)^2 - (x(2)-pi)^2);
    
    Df = @(x) [exp(-(x(1)-pi)^2 - (x(2)-pi)^2)*cos(x(2))*(sin(x(1)) + 2*(x(1)-pi)*cos(x(1))); ...
               exp(-(x(1)-pi)^2 - (x(2)-pi)^2)*cos(x(1))*(sin(x(2)) + 2*(x(2)-pi)*cos(x(2)))];
           
    Hf = @(x) [exp(-(x(1)-pi)^2 - (x(2)-pi)^2) * cos(x(2)) * (-4 * (x(1) - pi)^2 * cos(x(1)) + 3 * cos(x(1)) - 4 * (x(1)-pi) * sin(x(1))), ...
               -exp(-(x(1)-pi)^2 - (x(2)-pi)^2) * (sin(x(1)) * sin(x(2)) + 4 * (x(1)-pi) * (x(2)-pi) * cos(x(1)) * cos(x(2)) + 2 * (x(2)-pi) * sin(x(1)) * cos(x(2)) + 2 * (x(1)-pi) * cos(x(1)) * sin(x(2))); ...
               -exp(-(x(1)-pi)^2 - (x(2)-pi)^2) * (sin(x(1)) * sin(x(2)) + 4 * (x(1)-pi) * (x(2)-pi) * cos(x(1)) * cos(x(2)) + 2 * (x(2)-pi) * sin(x(1)) * cos(x(2)) + 2 * (x(1)-pi) * cos(x(1)) * sin(x(2))), ...
               exp(-(x(1)-pi)^2 - (x(2)-pi)^2) * cos(x(2)) * (-4 * (x(1) - pi)^2 * cos(x(1)) + 3 * cos(x(1)) - 4 * (x(1)-pi) * sin(x(1)))];
           
end

