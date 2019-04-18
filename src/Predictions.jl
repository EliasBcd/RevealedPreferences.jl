"""
```welfareoptimal(dg::DiGraph{T}, set::Vector{T}) where {T<:Int}```

Look for all the maximal elements of the DiGraph `dg` in `set`.
Return the number of alternatives that are admissible and the predictive power as defined in Bouacida and Martin (2019).

# Arguments:

- `dg`: A DiGraph.
- `set`: A set of the same type than the DiGraph.
"""
function welfareoptimal(dg::DiGraph{T}, set::Vector{T}) where {T<:Int}
    pss = 0
    for t in set
        copyset = copy(set)
        s = pop!(copyset)
        while !has_edge(dg, s, t) && !isempty(copyset)
            s = pop!(copyset)
        end
        if isempty(copyset) && !has_edge(dg, s, t)
            pss += 1
        end
    end
    pp = 1 - (pss - 1) / (length(set)-1)
    return pss, pp
end