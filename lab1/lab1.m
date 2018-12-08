close all
clearvars
clc

diary on
disp("CLARENCE CHEE KANG HUI")
disp("==============================")
disp("Q1.1")
disp("==============================")

A = [1 7 3; 2 4 1; 4 8 6]
B = [1 1 0.25; 2 4 1; 4 8 2]
C = [0; 0; 0]

disp("==============================")
disp("Q1.2")
disp("==============================")

[Ua, Sa, Va] = svd(A)
[Ub, Sb, Vb] = svd(B)

disp("Verifying Ua, Ub, Va, Vb are all orthonormal:")
fprintf('\n')

disp("(Orthornormal = all columns are unit vectors and orthogonal to each other)")
fprintf('\n')

disp("***********************")
disp("magnitude of cols of Ua:")
col_1_mag = norm(Ua(:, 1))
col_2_mag = norm(Ua(:, 2))
col_3_mag = norm(Ua(:, 3))
disp("thus cols of Ua are unit vectors")
fprintf('\n')

disp("Ua.' * Ua:")
Ua.' * Ua
disp("since Ua.' * Ua is an identity matrix, cols of Ua are orthogonal")
disp("since cols of Ua are unit vectors and orthogonal to each other,")
disp("Ua is orthonormal")

fprintf('\n')
disp("***********************")
disp("magnitude of cols of Ub:")
col_1_mag = norm(Ub(:, 1))
col_2_mag = norm(Ub(:, 2))
col_3_mag = norm(Ub(:, 3))
disp("thus cols of Ub are unit vectors")
fprintf('\n')

disp("Ub.' * Ub:")
Ub.' * Ub
disp("since Ub.' * Ub is an identity matrix, cols of Ub are orthogonal")
disp("since cols of Ub are unit vectors and orthogonal to each other,")
disp("Ub is orthonormal")

fprintf('\n')

disp("***********************")
disp("magnitude of cols of Va:")
col_1_mag = norm(Va(:, 1))
col_2_mag = norm(Va(:, 2))
col_3_mag = norm(Va(:, 3))
disp("thus cols of Va are unit vectors")
fprintf('\n')

disp("Va.' * Va:")
Va.' * Va
disp("since Va.' * Va is an identity matrix, cols of Va are orthogonal")
disp("since cols of Va are unit vectors and orthogonal to each other,")
disp("Va is orthonormal")

fprintf('\n')

disp("***********************")
disp("magnitude of cols of Vb:")
col_1_mag = norm(Vb(:, 1))
col_2_mag = norm(Vb(:, 2))
col_3_mag = norm(Vb(:, 3))
disp("thus cols of Vb are unit vectors")
fprintf('\n')

disp("Vb.' * Vb:")
Vb.' * Vb
disp("since Vb.' * Vb is an identity matrix, cols of Vb are orthogonal")
disp("since cols of Vb are unit vectors and orthogonal to each other,")
disp("Vb is orthonormal")
disp("***********************")

fprintf('\n')

Sa
Sb
disp("min singular A value: 1.3523 because A is full rank")
disp("rank of A == 3 since 3 non-zero singular values")

disp("min singular B value: 0 because B is rank deficient")
disp("rank of B == 2 since two non-zero singular values")
fprintf('\n')

disp("==============================")
disp("Q1.3")
disp("==============================")
fprintf('\n')
disp("Solving Ax = C:")
det_A = det(A)
Sa
disp("det(A) != 0 and all singular values non-zero; thus x = zero vector")

fprintf('\n')
disp("Solving Bx = C:")
det_B = det(B)
Sb
disp("det(B) == 0 and at least one of the singular values == 0")
disp("non-zero solution is any linear combination of the following vector:")
Vb(:, end)
disp("this vector can be multiplied by a non-zero scalar to produce more solutions")

fprintf('\n')
disp("==============================")
disp("Q1.4")
disp("==============================")
fprintf('\n')

F = [10 -4 0; 2 3 2; 8 2 3; -2 7 2]
disp("No it can't be rank 4.")
disp("max rank of F = min(num_rows, num_cols) = 3")
disp("if we look at columns only, we have three vectors:")
col_1 = F(:,1)
col_2 = F(:,2)
col_3 = F(:,3)

disp("even if they were orthogonal to each other, they could at most, occupy")
disp("three dimensions only since we need four orthogonal vectors to occupy four dimensions of space.")
disp("Now if we look at rows only, we have four vectors:")

row_1 = F(1,:).'
row_2 = F(2,:).'
row_3 = F(3,:).'
row_4 = F(4,:).'

disp("even if they were orthogonal to each other, they could at most, occupy")
disp("three dimensions only because they all lack a fourth dimensional value.")
disp("Thus, the max rank of F is 3.")

fprintf('\n')
disp("linear least squares solution to Fx = [1; 2; 3; 4]:")
x = inv((transpose(F) * F)) * transpose(F) * [1; 2; 3; 4]

E = [5 -4 0; 1 3 4; 4 3 6; -1 7 4]
disp("linear least squares solution to Ex = [1; 2; 3; 4]:")
x = inv((transpose(E) * E)) * transpose(E) * [1; 2; 3; 4]

E_x = E * x
disp("comment: it is not the same as [1; 2; 3; 4] but close.")
disp("this is because linear least squares is solely an approximation of x.")
disp("rows do not align on the same values of x, more rows than needed to")
disp("approximate the value of x.")

fprintf('\n')
disp("==============================")
disp("Q2")
disp("==============================")
random_matrix = randi([0, 100], 3)
[e_vectors, e_values] = eig(random_matrix, 'vector');
disp("***********************")
for c = 1:3
    fprintf("Pair #%d", c)
    e_value = e_values(c)
    e_vector = e_vectors(:,c)
    disp("random_matrix * x:")
    random_matrix * e_vector
    disp("lambda * x:")
    e_value * e_vector
    disp("***********************")
    
end

diary off