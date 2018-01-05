function A = squarePhase(B, s)
    %Assume B to be Image Matrix
    [x, y] = meshgrid(-s:s);
    w = (2*s+1);
    index = [1:w 2*w:w:w*w (w*w-1):-1:(w*(w-1)+1) w*(w-2)+1:(-w):1];
    for i = 1:numel(index)
        K(i,:) = [squeeze(x(index(i))); squeeze(y(index(i)))];
    end
    nPoints = size(K,1);
    T = NaN([nPoints size(B)]);
    for iShift = 1:nPoints
        T(iShift, :,:)= circshift(B, squeeze(K(iShift,:)));
    end
    U  = unwrap(T,[],1);
    A = squeeze(U(end,:,:)-U(1,:,:));
end