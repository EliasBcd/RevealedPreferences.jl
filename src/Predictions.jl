"""
    optimalset(dg::DiGraph{T}, set::Vector{T}) where {T<:Int}

Look for the set of all the maximal elements of the DiGraph `dg` in `set`.
"""
function optimalset(dg::DiGraph{T}, set::Vector{T}) where {T<:Int}
    result = Vector{T}()
    for t = set
        if t > nv(dg)
            throw(DomainError(t, "The $set contains values that are not in the digraph."))
        end
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
    Selten(cc::Union{ChoiceFunction{T}, ChoiceCorrespondence{T}}, dg::DiGraph{T}, set::Vector{T}) where T<:Int 

Compute the Selten's score of a given the set `set` for a choice correspondence `cc` and a preference `dg`.
"""
Selten(cc::Union{ChoiceFunction{T}, ChoiceCorrespondence{T}}, dg::DiGraph{T}, set::Vector{T})  where T <: Int  = issubset(cc[set], set) - length(optimalset(dg, set)) / length(set)


"""
    Selten(cc::Union{ChoiceCorrespondence{T}, ChoiceFunction{T}}, dg::DiGraph{T}, sets::Vector{Vector{T}}, f = mean) where T<:Int

Compute the Selten's score of a given the set of sets `sets` for a choice correspondence `cc` and a preference `dg`.

Aggregate the Selten's score on all the sets according to the function `f`, which is by default the mean.
"""
function Selten(cc::Union{ChoiceCorrespondence{T}, ChoiceFunction{T}}, dg::DiGraph{T}, sets::Vector{Vector{T}}, f = mean) where T <: Int
    res = Vector{Float64}()
    for set in sets
        push!(res, Selten(cc, dg, set))
    end
    return f(res)
end