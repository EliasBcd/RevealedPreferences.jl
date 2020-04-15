"""
    isWARP(cc::ChoiceCorrespondence{T})

Return if the choice correspondence `cc` satisfies the Weak Axiom of Revealed Preferences. 

!!! The test is only valid if the choice correspondence is fully observed, that is, if it contains all possible subsets of alternatives.
"""
function isWARP(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) = cc
        for x = S, y = cS
            if !(x == y)
                for (U, cU) = cc
                    if in(y, U) & in(x, cU) & !in(y, cU) 
                        return false
                    end
                end
            end
        end
    end
    return true
end

"""
    isacyclic(dg::DiGraph{T}, g::Graph{T}) where T <: Int

Check whether a preference relation represented in a digraph `dg` and a graph `g` is acyclic. 

# Arguments

- `dg` represents the strict part of the preference relation;
- `g` represents the indifference part of the preference relation.
"""
function isacyclic(dg::DiGraph{T}, g::Graph{T}) where T <: Int
    P = transitiveclosure(dg)
    if is_cyclic(P)
        return false
    end
    I = DiGraph(g)
    R = union(P, I)
    transitiveclosure!(R)
    cycles = simplecycles(R)
    for cyc = cycles
        push!(cyc, cyc[1])
        for i = 1:(length(cyc) - 1) 
            if has_edge(P, Edge(cyc[i], cyc[i+1])) 
                return false
            end
        end
    end
    return true
end


"""
    isacyclic(cf::ChoiceFunction{T}, n::Int = 0) where T <: Int

Check if a choice function `cf` is acyclic when using revealed preferences.

# Arguments

- `cf` is the choice function to check;
- `n` is the number of alternatives in the set of alternatives. Defaults to 0 if not given, and will be computed, which is slower.
"""
function isacyclic(cf::ChoiceFunction{T}, n::Int = 0) where T <: Int
    dg, g = weakstrictrevealedpreferences(cf, n)
    return isacyclic(dg, g)
end
    


"""
    isalpha(cc::ChoiceCorrespondence{T}) where T <: Int

Check whether a choice correspondence `cc` violate the ``\\alpha`` axiom of Sen (1971).[^Sen1997]

[^Sen1997]: Sen, Amartya K. "Choice Functions and Revealed Preference." *The Review of Economic Studies*, vol. 38, no. 3, 1971, pp. 307–317. JSTOR, [www.jstor.org/stable/2296384](www.jstor.org/stable/2296384).
"""
function isalpha(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) = cc
        if length(S) > 2
            for x = cS
                for (U, cU) = cc
                    if issubset(U, S) & in(x, U) & !in(x, cU) 
                        return false
                    end
                end
            end
        end
    end
    return true
end

"""
    isbeta(cc::ChoiceCorrespondence{T}) where T <: Int

Check if a choice correspondence `cc` violates the ``\\beta`` axiom of Sen (1971).[^Sen1997]

[^Sen1997]: Sen, Amartya K. "Choice Functions and Revealed Preference." *The Review of Economic Studies*, vol. 38, no. 3, 1971, pp. 307–317. JSTOR, [www.jstor.org/stable/2296384](www.jstor.org/stable/2296384).
"""
function isbeta(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) in cc
        if length(cS) > 1
            for (U, cU) in cc
                if (S == U) | !issubset(S, U)
                    continue
                end
                for x in cS, y in cS
                    if in(x, cU) & !in(y, cU)
                        return false
                    end
                end
            end
        end
    end
    return true
end

"""
    isdelta(cc::ChoiceCorrespondence{T}) where T <: Int

Check if a choice correspondence `cc` violates the ``\\delta`` axiom of Sen (1971).[^Sen1997]

[^Sen1997]: Sen, Amartya K. "Choice Functions and Revealed Preference." *The Review of Economic Studies*, vol. 38, no. 3, 1971, pp. 307–317. JSTOR, [www.jstor.org/stable/2296384](www.jstor.org/stable/2296384).
"""
function isdelta(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) in cc
        if length(cS) > 1
            for (U, cU) in cc
                if (S == U) | !issubset(S, U)
                    continue
                end
                for x in cS
                    if [x] == cU 
                        return false
                    end
                end
            end
        end
    end
    return true
end


"""
    isgamma(cc::ChoiceCorrespondence{T}) where T <: Int

Check if a choice correspondence `cc` violates the ``\\gamma`` axiom of Sen (1971).[^Sen1997]

[^Sen1997]: Sen, Amartya K. "Choice Functions and Revealed Preference." *The Review of Economic Studies*, vol. 38, no. 3, 1971, pp. 307–317. JSTOR, [www.jstor.org/stable/2296384](www.jstor.org/stable/2296384).
"""
function isgamma(cc::ChoiceCorrespondence{T}) where T <: Int
    Ss = collect(keys(cc))
    while !isempty(Ss)
        S = pop!(Ss)
        for U in Ss
            if !issubset(intersect(cc[S], cc[U]), cc[sort(union(S, U))]) 
                return false
            end
        end
    end
    return true
end

"""
    isWARNI(cc::ChoiceCorrespondence{T}) where T <: Int

Check if a choice correspondence `cc` satisfies WARNI of Eliaz and Ok (2006).[^Eliaz2006]

[^Eliaz2006]: Kfir Eliaz, Efe A. Ok,
"Indifference or indecisiveness? Choice-theoretic foundations of incomplete preferences,"
*Games and Economic Behavior*,
Volume 56, Issue 1,
2006,
Pages 61-86,
ISSN 0899-8256,
[https://doi.org/10.1016/j.geb.2005.06.007.](https://doi.org/10.1016/j.geb.2005.06.007.)
"""
function isWARNI(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) in cc
        for y in S
            if in(y, cS) 
                continue
            end
            chosenxs = falses(size(cS))
            for (i,x) in enumerate(cS)
                for (U, cU) in cc
                    if in(y, cU) & in(x, U)
                        chosenxs[i] = true
                    end
                end
            end
            if chosenxs == trues(size(cS))
                return false
            end
        end
    end
    return true
end

"""
    isoutcast(cc::ChoiceCorrespondence{T}) where T <: Int

Check if a choice correspondence `cc` satisfies the Outcast axiom from Aleskerov, Bouyssou and Monjarder (2007).[^ABM2007]

[^ABM2007]: ALESKEROV, Fuad, BOUYSSOU, Denis, et MONJARDET, Bernard. *Utility maximization, choice and preference.* Springer Science & Business Media, 2007.
"""
function isoutcast(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) in cc
        for (U, cU) in cc
            if !issubset(U, S) | !issubset(cS, U) 
                continue
            elseif !(cS == cU)
                return false
            end
        end
    end
    return true
end

"""
    isFAs(cc::ChoiceCorrespondence{T}) where T <: Int

Check if the choice correspondence `cc` satisfies the Functional Asymmetry axiom from Aleskerov, Bouyssou and Monjarder (2007).[^ABM2007]

[^ABM2007]: ALESKEROV, Fuad, BOUYSSOU, Denis, et MONJARDET, Bernard. *Utility maximization, choice and preference.* Springer Science & Business Media, 2007.
"""
function isFAs(cc::ChoiceCorrespondence{T}) where T <: Int
    Ss = collect(keys(cc))
    while !isempty(Ss)
        S = pop!(Ss)
        for U in Ss    
            if !isempty(intersect(cc[S], setdiff(U, cc[U]))) & !isempty(intersect(cc[U], setdiff(S, cc[S]))) 
                return false
            end
        end
    end
    return true
end

"""
    isJLF(cc::ChoiceCorrespondence{T}) where T <: Int

Check if the choice correspondence `cc` satisfies the Jamison Lau Fishburn from Aleskerov, Bouyssou and Monjarder (2007).[^ABM2007]

[^ABM2007]: ALESKEROV, Fuad, BOUYSSOU, Denis, et MONJARDET, Bernard. *Utility maximization, choice and preference.* Springer Science & Business Media, 2007.
"""
function isJLF(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) = cc
        for (U, cU) = cc
            if (length(U) == 2) | (S == U) | !issubset(S, setdiff(U, cU))
                continue
            end
            for (V, cV) in cc
                if (V == U) | (S == V) | isempty(intersect(cU, V))
                    continue
                elseif !isempty(intersect(setdiff(S, cS),  cV))
                    return false
                end
            end
        end
    end
    return true
end


"""
    isOO(cc::ChoiceCorrespondence{T}) where T <: Int

Test the occasional optimality condition of Mira Frick (2016) on the choice correspondence `cc`.
"""
function isOO(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) in cc
        OOS = false       
        for x in cS
            OOx = true
            for (U, cU) in cc
                if in(x, U) & !isempty(intersect(cU, S)) & !in(x, cU)
                    OOx = false
                end
            end
            if OOx
                for(U, cU) in cc
                    if !in(x, U)
                        continue
                    end
                    for y in S
                        if !in(y, U) & !issubset(cU, cc[sort(union(U, y))]) 
                            OOx = false
                            break
                        end
                    end
                    if !OOx 
                        break
                    end
                end
            end
            if OOx 
                OOS = true
                break
            end
        end        
        if !OOS 
            return false
        end
    end
    return true
end     


"""
    isFP(cc::ChoiceCorrespondence{T}) where T <: Int

Check if the choice correspondence `cc` satisfies the Fixed Point axiom from Aleskerov, Bouyssou and Monjarder (2007).[^ABM2007]

[^ABM2007]: ALESKEROV, Fuad, BOUYSSOU, Denis, et MONJARDET, Bernard. *Utility maximization, choice and preference.* Springer Science & Business Media, 2007.
"""
function isFP(cc::ChoiceCorrespondence{T}) where T <: Int
    Ss = collect(keys(cc))
    while !isempty(Ss)
        S = pop!(Ss)
        if length(S) == 2
            continue
        end
        FP = false
        for x in cc[S]
            FPx = true
            for (U, cU) in cc
                if !issubset(U, S) | (U == S) 
                    continue
                elseif in(x, U) & !in(x, cU) 
                    FPx = false
                end
            end
            if FPx
                FP = true
                break
            end
        end
        if !FP
            return false
        end
    end
    return true 
end

"""
    isFA(cc::ChoiceCorrespondence{T}, n::Int = 0) where T <: Int

Check if the choice correspondence `cc` satisfies the Functional Acyclicity axiom from Aleskerov, Bouyssou and Monjarder (2007).[^ABM2007]

[^ABM2007]: ALESKEROV, Fuad, BOUYSSOU, Denis, et MONJARDET, Bernard. *Utility maximization, choice and preference.* Springer Science & Business Media, 2007.
# Arguments

- `cc`, the choice correspondence to be tested;
- `n`, size of the digraph, if not given, will look in the choice correspondence for the length.
"""
function isFA(cc::ChoiceCorrespondence{T}, n::Int = 0) where T <: Int
    if n == 0
        set = Set{Int}()
        for (S, cS) in cc
            for x in S
                push!(set, x)
            end
        end
        n = length(set)       
    end
    dg = DiGraph(n)
    for (S, cS) in cc
        for x in cS, y in S
            if !in(y, cS)
                add_edge!(dg, x, y)
            end
        end
    end
    return !is_cyclic(dg)
end
