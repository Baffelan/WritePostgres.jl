# """
# The aim of this file is to return a json file with information about outliers that have been identified from the collected data

# Rough Steps:
#     postgreSQLquery to get data from server

#     textGraph (should rename) to transform data to embedding

#     Detect anomalies

#     build json

# File needs distance dictionaries, dataframe from postgreSQL
# """




"""
Aligns the indeces of each 
"""
function create_interacting_embedding(df1::DataFrameRow, df2::DataFrameRow; transpose_1::Bool=false, transpose_2::Bool=false)
    emb1 = transpose_1 ? df1.embedding' : df1.embedding
    emb2 = transpose_2 ? df2.embedding' : df2.embedding

    toks1 = typeof(df1.token_idx)==String ? JSON.parse(df1.token_idx) : df1.token_idx
    toks2 = typeof(df2.token_idx)==String ? JSON.parse(df2.token_idx) : df2.token_idx

    all_toks = union(keys(toks1), keys(toks2))
    int_toks = intersect(keys(toks1), keys(toks2))
    
    emb_dim = max(size(emb1)[2], size(emb2)[2])
    bigm1 = zeros(Float32, (length(all_toks), emb_dim))
    bigm2 = zeros(Float32, (length(all_toks), emb_dim))

    int_locs1 = [toks1[k] for k in int_toks]
    int_locs2 = [toks2[k] for k in int_toks]


    non_int1 = [toks1[k] for k in setdiff(keys(toks1),int_toks)]

    
    if length(toks1)>0
        bigm1[1:length(int_toks),:].=emb1[int_locs1,:]
        bigm1[length(int_toks)+1:length(int_toks)+length(non_int1),:].=emb1[non_int1,:]
    end
    

    non_int2 = [toks2[k] for k in setdiff(keys(toks2), int_toks)]

    if length(toks2)>0
    bigm2[1:length(int_toks),:].=emb2[int_locs2,:]
    bigm2[length(int_toks)+1+length(non_int1):end,:].=emb2[non_int2,:]
    end

    return bigm1, bigm2, vcat([k for k in int_toks], [k for k in setdiff(keys(toks1),int_toks)], [k for k in setdiff(keys(toks2), int_toks)])

end




