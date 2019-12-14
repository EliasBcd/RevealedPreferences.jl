"""
```edgedegree(dg::DiGraph{T}, e::Edge{T}, f1, f2) where T <: Int```

Compute the relation between in degree and out degree for a given vertice using function `f1`.
Aggregate the source and the destination degrees of an edge using function `f2`.

# Arguments

- `dg`, the digraph on which we compute the degrees;
- `e`, the edge considered;
- `f1`, the function used within a vertex;
- `f2`, the function used to aggregate within an edge.
"""
function edgedegree(dg::DiGraph{T}, e::Edge{T}, f1, f2) where T <: Int
    res = Vector{Float64}()
    for x in [src(e), dst(e)]
        push!(res, f1(outdegree(dg, x), indegree(dg, x)))
    end
    return f2(res)
end

"""
```edgedegree(dg::DiGraph{T}, elist::Vector{Edge{T}}, f1 = -, f2 = mean, f3 = mean) where T <: Int```

Compute the relation between in degree and out degree for a given vertice using function `f1`.
Aggregate the source and the destination degrees of an edge using function `f2`.
Aggregaste over all edges using function `f3.`

# Arguments

- `dg`, the digraph on which we compute the degrees;
= `elist`, the list of edges to consider.
- `f1`, the function used within a vertex;
- `f2`, the function used to aggregate within an edge;
- `f3`, the function used to aggregate between edges;
"""
function edgedegree(dg::DiGraph{T}, elist::Vector{Edge{T}}, f1 = -, f2 = mean, f3 = mean) where T <: Int
    res = Vector{Float64}()
    for e in elist
        push!(res, edgedegree(dg, e, f1, f2))
    end
    return f3(res)
end


"""
```cycledegree(dg::DiGraph{T}, cycle::Vector{T}, f1, f2) where T<:Int```

Compute the relation between in degree and out degree for a given cycle.
Withn a vertex, in degree and out  degrees are compated using function `f1`.
Over all vertices, aggregate the degrees of an edge using function `f2`.

# Arguments

- `dg`, the digraph on which we compute the degrees;
- `cycle`, the cycle considered;
- `f1`, the function used within a vertex;
- `f2`, the function used to aggregate within cycle.
"""
function cycledegree(dg::DiGraph{T}, cycle::Vector{T}, f1, f2) where T<:Int
    res = Vector{Float64}()
    for x in cycle
        push!(res, f1(outdegree(dg, x), indegree(dg, x)))
    end
    return f2(res)
end

"""
```cycledegree(dg::DiGraph{T}, f1 = -, f2 = mean, f3 = mean, ceil::Int = 2) where T<:Int```

Compute the relation between in degree and out degree for a given vertice using function `f1`.
Aggregate the source and the destination degrees of a cycle using function `f2`.
Aggregaste over all cycles over length lower than `ceil` in the digraph using function `f3.`

# Arguments

- `dg`, the digraph on which we compute the degrees;
- `f1`, the function used within a vertex;
- `f2`, the function used to aggregate within an edge;
- `f3`, the function used to aggregate between edges;
- `ceil`, the maximal length of the cycles considered for the degree computation. Default to 2.
"""
function cycledegree(dg::DiGraph{T}, f1 = -, f2 = mean, f3 = mean, ceil::Int = 2) where T<:Int
    cycles = simplecycles_limited_length(dg, ceil)
    if isempty(cycles)
        return missing
    end
    res = Vector{Float64}()
    for cycle in cycles
        push!(res, cycledegree(dg, cycle, f1, f2))
    end
    return f3(res)
end
