function CNa = calc_CNa_ogive(r, l, R_ref, alpha, M, cna_csv_data)

    if nargin < 5
        M = 0;
    end

    l_over_d = l / (2*r);

    if nargin < 6
        CNa0 = nosecone_CNalpha(M, l_over_d);
    else
        CNa0 = nosecone_CNalpha(M, l_over_d, cna_csv_data);
    end

    CNa = (CNa0 * cos(2*alpha)) * (r/R_ref)^2;
    if isnan(CNa)
        CNa = 0;
    end
    
end
