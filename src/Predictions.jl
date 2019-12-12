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
```Selten(dg::DiGraph{T}, set::Vector{T}) where T<:Int```

Compute the Selten's score of a given digraph on a given set.

# Arguments

- `dg`, a DiGraph;
- `set`, a set of the same type than the DiGraph.
"""
function Selten(dg::DiGraph{T}, set::Vector{T}) where T<:Int
    return 1 - length(optimalset(dg, set)) / length(set)
end


"""
```Selten(dg::DiGraph{T}, sets::Vector{Vector{T}}, f = mean) where T<:Int```

Aggregate Selten's score of a given digraph for a list of sets, according to function f.

# Arguments

- `dg`, a DiGraph;
- `set`, a vector of sets of the same type than the DiGraph;
- `f`, a function to use for aggregation, default the mean.
"""
function Selten(dg::DiGraph{T}, sets::Vector{Vector{T}}, f = mean) where T<:Int
    res = Vector{Float64}()
    for set in sets
        push!(res, Selten(dg, set))
    end
    return f(res)
end