"""
    swapindex(wdg::WeightedDiGraph)

Compute the swap index of Apesteguia and Ballester (2015) for the digraph `digraph(wdg)`.[^AB2015]

The frequency of each relation is given by the Matrix `weights(wdg)`.

### References

[^AB2015]: Jose Apesteguia and Miguel A. Ballester, "A Measure of Rationality and Welfare," *Journal of Political Economy* vol 123, no. 6 (December 2015): 1278-1310. doi: [10.1086/683838](https://doi.org/10.1086/683838)
"""
function swapindex(wdg::WeightedDiGraph)
    if !is_cyclic(digraph(wdg))
        return 0., true
    end
    cycles = simplecycles(digraph(wdg))
    cyclessize = length(cycles)
    removalsize = ne(digraph(wdg))
    alledges = collect(edges(digraph(wdg)))
    lp = GLPK.glp_create_prob()
    GLPK.glp_set_obj_dir(lp, GLPK.GLP_MIN)    
    GLPK.glp_add_rows(lp, cyclessize)
    for i = 1:cyclessize
        GLPK.glp_set_row_bnds(lp, i, GLPK.GLP_LO, 1, 0)
    end
    GLPK.glp_add_cols(lp, removalsize)
    for i = 1:removalsize
        GLPK.glp_set_col_kind(lp, i, GLPK.GLP_BV)
        GLPK.glp_set_obj_coef(lp, i, weights(wdg)[src(alledges[i]), dst(alledges[i])])  
    end
    ia = Vector{Cint}()
    ja = Vector{Cint}()
    ar = Vector{Cdouble}()
    for i = 1:cyclessize
        for k = 1:(length(cycles[i]) - 1)
            for j = 1:removalsize
                if((src(alledges[j]) == cycles[i][k]) & (dst(alledges[j]) == cycles[i][k+1]))
                    push!(ia, i)
                    push!(ja, j)
                    push!(ar, 1)
                    break
                end
            end
        end
        for j = 1:removalsize
            if((src(alledges[j]) == cycles[i][end]) & (dst(alledges[j]) == cycles[i][1]))
                push!(ia, i)
                push!(ja, j)
                push!(ar, 1)
                break
            end
        end
    end
    GLPK.glp_load_matrix(lp, length(ar), GLPK.offset(ia), GLPK.offset(ja), GLPK.offset(ar)) 
    parm = GLPK.glp_iocp()
    GLPK.glp_init_iocp(parm)
    parm.presolve = GLPK.GLP_ON  
    parm.msg_lev = GLPK.GLP_MSG_OFF
    GLPK.glp_intopt(lp, parm)      
    edgetoremove = Vector{Int}()
    for i = 1:removalsize
        if GLPK.glp_mip_col_val(lp, i) == 1
            push!(edgetoremove, i)
        end
    end
    result = 0.
    copywdg = copy(wdg)
    for e = alledges[edgetoremove]
        result += weights(wdg)[src(e), dst(e)]
        rem_edge!(copywdg, e)
    end
    return result, !is_cyclic(digraph(copywdg))
end

"""
    allchoicesets(n::Int, floor::Int = 2)

Compute all choice sets of size larger than `floor` for a given number of alternatives.

# Arguments

- `n`, the number of alternatives;
- `floor`, minimal size of the choice sets. Default to 2.
"""
function allchoicesets(n::Int, floor::Int = 2)
    if floor < 0
        throw(DomainError(floor, "should be positive."))
    elseif n < floor
        throw(DomainError(n, "should be greater or equal than floor $floor."))
    end
    X = collect(1:n)
    result = [X]
    for i = floor:(n-1)
        append!(result, collect(subsets(X, i)))
    end
    return result
end

"""
    allcombinationchoicesets(n::Int)

Compute all possible combination of choice sets to remove from a grand set of alternatives of size `n`, assuming that choice sets must be of size 2 or greater.
"""
function allcombinationchoicesets(n::Int, floor::Int = 2)
    if n < floor
        throw(DomainError(n, "should be greater than the `floor` $floor"))
    elseif floor < 0
        throw(DomainError(floor, "cannot be negative!"))
    end        
    rs = Vector{Vector{Int}}()
    for i = floor:n
        append!(rs, collect(subsets(collect(1:n), i)))
    end
    rs2 = Vector{Vector{Vector{Int}}}()
    for i = 0:n
        append!(rs2, collect(subsets(rs, i)))
    end
    return rs2
end


"""
    HMI(cf::ChoiceFunction{T}, removablesets::Vector{Vector{Vector{T}}}) where T <: Int

Compute the Houtman-Maks Index (1985) with brute force, conditional on providing the set of removable alternatives beforehand.
Use a brute force algorithm to do so.

# Arguments:

- `cf`, the choice function that is used to computed the Houtman-Maks index;
- `removablesets`, the set of all possible combination of sets that can be removed.
"""
function HMI(cf::ChoiceFunction{T}, removablesets::Vector{Vector{Vector{T}}}) where T <: Int
    if isacyclic(cf)
        return 0.
    end
    result = maximum(length.(removablesets))
    for s = removablesets
        if length(s) >= result
            continue
        end
        ch = copy(cf)
        for ss = s
            delete!(ch, ss)
        end
        if isacyclic(ch)
            result = length(s)
        end
    end
    return result / length(cf)
end
