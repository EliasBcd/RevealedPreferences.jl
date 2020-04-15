"""
    edgedegree(dg::Union{Graph{T}, DiGraph{T}}, e::Edge{T}, f1, f2) where T <: Int

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
    if (src(e) > nv(dg)) | (dst(e) > nv(dg))
        throw(DomainError(e, "At least one of the source or the destination of the graph are not in the graph."))
    end
    for x = [src(e), dst(e)]
        if f1 == /
            if degree(dg, x) > 0
                push!(res, f1(outdegree(dg, x), degree(dg, x)))
            end
        else
            push!(res, f1(outdegree(dg, x), indegree(dg, x)))
        end
    end
    if isempty(res)
        return 0
    else
        return f2(res)
    end
end

"""
    edgesdegree(dg::Union{Graph{T}, DiGraph{T}}, elist::Vector{Edge{T}}, f1 = -, f2 = mean, f3 = mean) where T <: Int

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
    for e = elist
        push!(res, edgedegree(dg, e, f1, f2))
    end
    if isempty(res)
        return 0
    else
        return f3(res)
    end
end

"""
    missingedgesdegree(dg::Union{Graph{T}, DiGraph{T}},f1 = -, f2 = mean, f3 = mean; refdg::DiGraph = dg) where T <: Int

Aggregate the relation between indegree and outdegree of missing edges compared to a complete graph of the same size.

Compute the relation between in degree and out degree for a given vertice using function `f1`.
Aggregate the source and the destination degrees of an edge using function `f2`.
Aggregaste over all edges using function `f3.`

# Arguments

- `dg`, the digraph on which we compute the degrees;
- `f1`, the function used within a vertex;
- `f2`, the function used within an edge;
- `f3`, the function used to aggregate between edges;
- `refdg` is the digraph on which the degree indices should be computed. Default to the digraph we are interested in.
"""
function missingedgesdegree(dg::Union{Graph{T}, DiGraph{T}},f1 = -, f2 = mean, f3 = mean; refdg::DiGraph = dg) where T <: Int
    g = Graph(dg)
    cg = complete_graph(nv(g))
    diffg = difference(cg, g)
    return edgesdegree(refdg, collect(edges(diffg)), f1, f2, f3)
end