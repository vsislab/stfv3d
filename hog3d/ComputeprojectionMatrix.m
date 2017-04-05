function [projectionMatrix,project_6bins]=ComputeprojectionMatrix()
goldenRatio = 1.6180339887;
projectionThresholdDodecahedron = 0.44721359549995792770...
    *sqrt(1+goldenRatio*goldenRatio);
projectionThresholdIcosahedron = 0.74535599249992989801;
projectionMatrix=zeros(3,6);
projectionMatrix(1,1) = 0;
projectionMatrix(2,1) = 1;
projectionMatrix(3,1) = goldenRatio;

projectionMatrix(1,2) = 0;
projectionMatrix(2,2) = -1;
projectionMatrix(3,2) = goldenRatio;

projectionMatrix(1,3) = 1;
projectionMatrix(2,3) = goldenRatio;
projectionMatrix(3,3) = 0;

projectionMatrix(1,4) = -1;
projectionMatrix(2,4) = goldenRatio;
projectionMatrix(3,4) = 0;

projectionMatrix(1,5) = goldenRatio;
projectionMatrix(2,5) = 0;
projectionMatrix(3,5) = 1;

projectionMatrix(1,6) = -goldenRatio;
projectionMatrix(2,6) = 0;
projectionMatrix(3,6) = 1;

project_6bins = projectionThresholdDodecahedron*sqrt(1+goldenRatio*goldenRatio);