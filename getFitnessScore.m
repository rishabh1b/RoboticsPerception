function score = getFitnessScore(F, matchedpoints1, matchedpoints2)
global thresh;
score = 0;
sz = size(matchedpoints1,1);
for i = 1:sz
   x2 = [matchedpoints2(i,:)';1];
   x1 = [matchedpoints1(i,:)';1];
   epip_line = F * x1;
   err = abs(x2' * F * x1) / (sqrt(epip_line(1)^2 + epip_line(2)^2));
   if err < thresh
       score = score + 1;
   end
end
score = score / sz;
end