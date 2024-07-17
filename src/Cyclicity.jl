"""
    removeallcycles!(dg::DiGraph{T}) where T <: Int

Remove all the cycles from the digraph `dg`.
Modify the digraph in place.
"""
function removeallcycles!(dg::DiGraph{T}) where T <: Int
    sccs = strongly_connected_components(dg)
    for scc in sccs
        if length(scc) > 1
            sdg, vmap = induced_subgraph(dg, scc)
            for e in edges(sdg)
                rem_edge!(dg, vmap[src(e)], vmap[dst(e)])
            end
        end
    end
    return dg
end

"""
    cycleswosubcycles!(dg::DiGraph{T}) where T <: Int

Remove cycles by increasing length of cycles and return the removed cycles.

Here, a cycle without a subcycle is a cycle which does not share an edge with a cycle of strictly shorter length.
If two cycles of the same length share an edge, both will be considered as removed cycles.
"""
function cycleswosubcycles!(dg::DiGraph{T}) where T <: Int
    l = 1
    res = Vector{Vector{T}}()
    while is_cyclic(dg)
        l += 1
        cycles = simplecycles_limited_length(dg, l)
        append!(res, cycles)
        for cycle = cycles
            rem_edge!(dg, cycle[end], cycle[1])
            for i in eachindex(cycle)
                i == 1 && continue
                rem_edge!(dg, cycle[i-1], cycle[i])
            end
        end
    end
    return res
end

"""
    numbercycleswosubcycles!(dg::DiGraph{T}, pref::AbstractString = "RP") where T <: Int

Count the number of cycles in without any subcycle in `dg`, for each given length.

Here, a cycle without a subcycle is a cycle which does not share an edge with a cycle of strictly shorter length.
If two cycles of the same length share an edge, both will be considered as removed cycles, and therefore be counted.
`name` is the name we want to use in the DataFrame output, default to RP.
"""
function numbercycleswosubcycles!(dg::DiGraph{T}, pref::AbstractString = "RP") where T <: Int
    cycleslength = length.(cycleswosubcycles!(dg))
    res = DataFrame()
    if !isempty(cycleslength)
        for (k, v) = countmap(cycleslength)
            res[!, Symbol("$(pref)NOSC$(k)")] = [v]
        end
    end
    return res
end

"""
    cyclesbylength(dg::DiGraph, pref::AbstractString = "RP")

Return the number of cycles of each length in a digraph `dg`.

# Arguments

- `dg`, the preference relation;
- `pref`, the name of the preference relation, defaults to "RP".
"""
function cyclesbylength(dg::DiGraph, pref::AbstractString = "RP")
    cyclelength = simplecycleslength(dg)
    res = DataFrame([[i] for i = cyclelength[1]], Symbol.(["$(pref)$i" for i = 1:length(cyclelength[1])]))
    res[!, Symbol("$(pref)ALL")] = repeat([cyclelength[2]], size(res, 1))
    return res
end