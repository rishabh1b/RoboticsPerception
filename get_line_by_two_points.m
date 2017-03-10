function L = get_line_by_two_points(p1,p2)
x1 = [p1(1), p1(2), 1]';
x2 = [p2(1), p2(2), 1]';
L = cross(x1, x2);
L = L / sqrt(L(1)*L(1) + L(2) * L(2));
end
