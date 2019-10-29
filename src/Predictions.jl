"""
```optimalset(dg::DiGraph{T}, set::Vector{T}) where {T<:Int}```

Look for all the maximal elements of the DiGraph `dg` in `set`.
Return the set of all maximal elements.

# Arguments

- `dg`, a DiGraph;
- `set`, a set of the same type than the DiGraph.
"""
function optimalset(dg::DiGraph{T}, set::Vector{T}) where {T<:Int}
    result = Vector{T}()
    for t in set
        copyset = copy(set)
        s = pop!(copyset)
        while !has_edge(dg, s, t) & !isempty(copyset)
            s = pop!(copyset)
        end
        if isempty(copyset) & !has_edge(dg, s, t)
            push!(result, t)
        end
    end
    return result
end

"""
```optimalsetsize(dg::DiGraph{T}, set::Vector{T}) where {T<:Int}```

Look for all the maximal elements of the DiGraph `dg` in `set`.
Return the number of alternatives that are admissible.

# Arguments

- `dg`, a DiGraph;
- `set`, a set of the same type than the DiGraph.
"""
function optimalsetsize(dg::DiGraph{T}, set::Vector{T}) where {T<:Int}
    result = 0
    for t in set
        copyset = copy(set)
        s = pop!(copyset)
        while !has_edge(dg, s, t) & !isempty(copyset)
            s = pop!(copyset)
        end
        if isempty(copyset) & !has_edge(dg, s, t)
            result += 1
        end
    end
    return result
end