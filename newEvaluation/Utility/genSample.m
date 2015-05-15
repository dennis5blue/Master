function [ F ] = genSample( P )
%P
x = cumsum([0 P(:).'/sum(P(:))]);
x(end) = 1e3*eps + x(end);
[a a] = histc(rand,x);
F = a;
end

