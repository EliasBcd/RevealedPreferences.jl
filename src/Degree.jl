"""
```edgedegree(dg::Union{Graph{T}, DiGraph{T}}, e::Edge{T}, f1, f2) where T <: Int```

Compute the relation between in degree and out degree for a given vertice using function `f1`.
Aggregate the source and the destination degrees of an edge using function `f2`.

# Arguments

- `dg`, the digraph on which we compute the degrees;
- `e`, the edge considered;
- `f1`, the function used within a vertex;
- `f2`, the function used within an edge.
"""
function edgedegree(dg::Union{Graph{T}, DiGraph{T}}, e::Edge{T}, f1, f2) where T <: Int
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
```edgesdegree(dg::Union{Graph{T}, DiGraph{T}}, elist::Vector{Edge{T}}, f1 = -, f2 = mean, f3 = mean) where T <: Int```

Compute the relation between in degree and out degree for a given vertice using function `f1`.
Aggregate the source and the destination degrees of an edge using function `f2`.
Aggregaste over all edges using function `f3.`

# Arguments

- `dg`, the digraph on which we compute the degrees;
- `elist`, the list of edges to consider;
- `f1`, the function used within a vertex;
- `f2`, the function used within an edge;
- `f3`, the function used to aggregate between edges.
"""
function edgesdegree(dg::Union{Graph{T}, DiGraph{T}}, elist::Vector{Edge{T}}, f1 = -, f2 = mean, f3 = mean) where T <: Int
    res = Vector{Float64}()
    for e in elist
        push!(res, edgedegree(dg, e, f1, f2))
    end
    return f3(res)
end

"""
```missingedgesdegree(dg::Union{Graph{T}, DiGraph{T}},f1 = -, f2 = mean, f3 = mean) where T <: Int```

Aggregate the relation between indegree and outdegree of missing edges compared to a complete graph of the same size.
Compute the relation between in degree and out degree for a given vertice using function `f1`.
Aggregate the source and the destination degrees of an edge using function `f2`.
Aggregaste over all edges using function `f3.`

# Arguments

- `dg`, the digraph on which we compute the degrees;
- `f1`, the function used within a vertex;
- `f2`, the function used within an edge;
- `f3`, the function used to aggregate between edges;
"""
function missingedgesdegree(dg::Union{Graph{T}, DiGraph{T}},f1 = -, f2 = mean, f3 = mean) where T <: Int
    g = Graph(dg)
    cg = complete_graph(nv(g))
    diffg = difference(cg, g)
    return edgesdegree(dg, collect(edges(diffg)), f1, f2, f3)
end