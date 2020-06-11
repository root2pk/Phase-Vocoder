%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Ruthu Prem Kumar
%                November 2019
%  Function that accepts an angle,wraps it to pi
%  and return the value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ph] = ppa(angle)
    ph = mod((angle+pi),(2*pi)) - pi;
end

