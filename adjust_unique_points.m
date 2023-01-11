function x= adjust_unique_points(Xroc)
    x= zeros(1, length(Xroc));
    aux= 0.0001;
    for i=1: length(Xroc)
        if i~=1
            x(i)= Xroc(i)+aux;
            aux= aux+0.0001;
        end
        
    end
end