"""
```swapindex(wdg::WeightedDiGraph)```

Compute the swap index of Apesteguia and Ballester (2016) for the digraph `digraph(wdg)` where the frequency of each relation is given by the Matrix `weights(wdg)`.

# Arguments

- `wdg`, the preference graph and its associated weights.
"""
function swapindex(wdg::WeightedDiGraph)
    if !is_cyclic(digraph(wdg))
        return 0., true
    end
    cycles = simplecycles(digraph(wdg))
    cyclessize = length(cycles)
    removalsize = ne(digraph(wdg))
    alledges = collect(edges(digraph(wdg)))
    lp = GLPK.Prob()
    GLPK.set_obj_dir(lp, GLPK.MIN)    
    GLPK.add_rows(lp, cyclessize)
    for i in 1:cyclessize
        GLPK.set_row_bnds(lp, i, GLPK.LO, 1, 0)
    end
    GLPK.add_cols(lp, removalsize)
    for i in 1:removalsize
        GLPK.set_col_kind(lp, i, GLPK.BV)
        GLPK.set_obj_coef(lp, i, weights(dg)[src(alledges[i]), dst(alledges[i])])  
    end
    ia = Vector{Int}()
    ja = Vector{Int}()
    ar = Vector{Int}()
    for i in 1:cyclessize
        for k in 1:(length(cycles[i]) - 1)
            for j in 1:removalsize
                if((src(alledges[j]) == cycles[i][k]) & (dst(alledges[j]) == cycles[i][k+1]))
                    push!(ia, i)
                    push!(ja, j)
                    push!(ar, 1)
                    break
                end
            end
        end
        for j in 1:removalsize
            if((src(alledges[j]) == cycles[i][end]) & (dst(alledges[j]) == cycles[i][1]))
                push!(ia, i)
                push!(ja, j)
                push!(ar, 1)
                break
            end
        end
    end
    GLPK.load_matrix(lp, ia, ja, ar) 
    parm = GLPK.IntoptParam()
    GLPK.init_iocp(parm)
    parm.presolve = GLPK.ON  
    parm.msg_lev = GLPK.MSG_OFF
    GLPK.intopt(lp, parm)      
    edgetoremove = Vector{Int}()
    for i in 1:removalsize
        if GLPK.mip_col_val(lp, i) == 1
            push!(edgetoremove, i)
        end
    end
    result = 0.
    copydg = copy(dg)
    for e in alledges[edgetoremove]
        result += weights(dg)[src(e), dst(e)]
        rem_edge!(copydg, e)
    end
    return result, !is_cyclic(copydg)
end

"""
```allchoicesets(n::Int, floor::Int = 2)```

Compute all choice sets of size larger than `floor` for a given number of alternatives.

# Arguments

- `n`, the number of alternatives;
- `floor`, minimal size of the choice sets. Default to 2.
"""
function allchoicesets(n::Int, floor::Int = 2)
    if floor < 0
        DomainError(floor, "should be positive.")
    elseif n < floor
        DomainError(n, "should be greater or equal than floor $floor.")
    end
    X = collect(1:n)
    result = [X]
    for i in floor:(n-1)
        append!(result, collect(subsets(X, i)))
    end
    return result
end

"""
```allcombinationchoicesets(n::Int)```

Compute all possible combination of choice sets to remove.

# Arguments

- `n`, the number of alternatives in the grand set of alternatives.
"""
function allcombinationchoicesets(n::Int)
    rs = Vector{Vector{Int}}()
    for i in 2:n
        append!(rs, collect(subsets(collect(1:n), i)))
    end
    rs2 = Vector{Vector{Vector{Int}}}()
    for i in 0:n
        append!(rs2, collect(subsets(rs, i)))
    end
    return rs2
end

"""
```cyclesbylength(dg::DiGraph; pref::AbstractString = "RP")```

Return the number of cycles of each length.

# Arguments

- `dg`, the preference relation;
- `pref`, the name of the preference relation, defaults to "RP".
"""
function cyclesbylength(dg::DiGraph; pref::AbstractString = "RP")
    cyclelength = simplecycleslength(dg)
    res = DataFrame([[i] for i in cyclelength[1]], Symbol.(["$(pref)$i" for i=1:length(cyclelength[1])]))
    res[!, Symbol("$(pref)ALL")] .= cyclelength[2]
    return res
end

"""
```HMI(cf::ChoiceFunction{T}, removablesets::Vector{Vector{Vector{T}}}) where T <: Int```

Compute the Houtman-Maks Index (1985) with brute force, conditional on providing the set of removable alternatives beforehand.
Use a brute force algorithm to do so.

# Arguments:

- `cf`, the choice function that is used to computed the Houtman-Maks index;
- `removablesets`, the set of all possible combination of sets that can be removed.
"""
function HMI(cf::ChoiceFunction{T}, removablesets::Vector{Vector{Vector{T}}}) where T <: Int
    rp = RP(cf)
    if !is_cyclic(rp)
        return 0.
    end
    result = maximum.(length(removablesets))
    for s in removablesets
        if length(s) >= min
            continue
        end
        ch = copy(cf)
        for ss in s
            delete!(ch, Set(ss))
        end
        rp = RP(ch)
        if !is_cyclic(rp)
            result = length(s)
        end
    end
    return result / nchoices
end
