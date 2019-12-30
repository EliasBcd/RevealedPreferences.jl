"""
```edgedegree(dg::DiGraph{T}, e::Edge{T}, f1, f2) where T <: Int```

Compute the relation between in degree and out degree for a given vertice using function `f1`.
Aggregate the source and the destination degrees of an edge using function `f2`.

# Arguments

- `dg`, the digraph on which we compute the degrees;
- `e`, the edge considered;
- `f1`, the function used within a vertex;
- `f2`, the function used within an edge.
"""
function edgedegree(dg::DiGraph{T}, e::Edge{T}, f1, f2) where T <: Int
    res = Vector{Float64}()
    for x in [src(e), dst(e)]
        if f1 == /
            push!(res, f1(outdegree(dg, x), degree(dg, x)))
        else
            push!(res, f1(outdegree(dg, x), indegree(dg, x)))
        end
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
- `elist`, the list of edges to consider.
- `f1`, the function used within a vertex;
- `f2`, the function used within an edge;
- `f3`, the function used to aggregate between edges;
"""
function edgedegree(dg::DiGraph{T}, elist::Vector{Edge{T}}, f1 = -, f2 = mean, f3 = mean) where T <: Int
    res = Vector{Float64}()
    for e in elist
        push!(res, edgedegree(dg, e, f1, f2))
    end
    return f3(res)
end