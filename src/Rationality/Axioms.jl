"""
```isWARP(cc::ChoiceCorrespondence{T})``` 

Return whether a choice correspondence verify the Weak Axiom of Revealed Preferences. This test is only valid if the choice correspondence is fully observed, that is, if it contains all possible subsets of alternatives.

# Arguments

- `cc`: the choice correspondence to be tested.
"""
function isWARP(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) in cc
        for x in S, y in cS
            if x == y 
		continue
	    end
            for (T, cT) in cc
                if in(y, T) & in(x, cT) & !in(y, cT) 
                    return false
                end
            end
        end
    end
    return true
end


"""
```isalpha(cc::ChoiceCorrespondence{T}) where T <: Int```

Check whether a choice correspondence violate the ALPHA axiom (aka H, the Heredity Axiom).

# Arguments

- `cc`: the choice correspondence to be tested.
"""
function isalpha(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) in cc
	if length(S) == 2
	    continue
	end
        for x in cS
            for (T, cT) in cc
                if issubset(T, S) & in(x, T) & !in(x, cT) 
		    return false
		end
            end
        end
    end
    return true
end

"""
```isbeta(cc::ChoiceCorrespondence{T}) where T <: Int```

Check whether a choice correspondence violate the BETA axiom.

# Arguments

- `cc`: the choice correspondence to be tested.
"""
function isbeta(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) in cc
	if length(cS) == 1
	    continue
	end
        for (T, cT) in cc
            if (S == T) | !issubset(S, T)
		continue
	    end
            for x in cS, y in cS
                if x == y
		    continue
		elseif in(x, cT) & !in(y, cT)
		    return false
		end
            end
        end
    end
    return true
end

"""
```isdelta(cc::ChoiceCorrespondence{T}) where T <: Int```

Check whether a choice correspondence violate the DELTA axiom.

# Arguments

- `cc`: the choice correspondence to be tested.
"""
function isdelta(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) in cc
        length(cS) == 1 && continue
        for (T, cT) in cc
            ((S == T) | !issubset(S, T)) && continue
            for x in cS
                [x] == cT && return false
            end
        end
    end
    return true
end


"""
```isgamma(cc::ChoiceCorrespondence{T}) where T <: Int```

Check whether a choice correspondence violate the Gamma axiom of Sen (1997)

# Arguments

- `cc`: the choice correspondence to be tested.
"""
function isgamma(cc::ChoiceCorrespondence{T}) where T <: Int
    Ss = collect(keys(cc))
    while !isempty(Ss)
        S = pop!(Ss)
        for T in Ss
            if !issubset(intersect(cc[S], cc[T]), cc[sort(union(S, T))]) 
		return false
	    end
        end
    end
    return true
end

"""
```isWARNI(cc::ChoiceCorrespondence{T}) where T <: Int```

Check whether WARNI is verified by a choice correspondence.

# Arguments

- `cc`: the choice correspondence to be tested.
"""
function isWARNI(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) in cc
        for y in S
	    if in(y, cS) 
		continue
	    end
            chosenxs = falses(size(cS))
            for (i,x) in enumerate(cS)
                for (T, cT) in cc
                    if in(y, cT) & in(x, T)
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
```isoutcast(cc::ChoiceCorrespondence{T}) where T <: Int```

Check whether the Outcast axiom is verified by a choice correspondence.

# Arguments

- `cc`: the choice correspondence to be tested.
"""
function isoutcast(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) in cc
        for (T, cT) in cc
	    if !issubset(T, S) | !issubset(cS, T) 
		continue
	    elseif !(cS == cT)
		return false
	    end
        end
    end
    return true
end

"""
```isFAs(cc::ChoiceCorrespondence{T}) where T <: Int```

Verify the Functional Asymmetry Axiom on a choice correspondence.

# Arguments

- `cc`: the choice correspondence to be tested.
"""
function isFAs(cc::ChoiceCorrespondence{T}) where T <: Int
    Ss = collect(keys(cc))
    while !isempty(Ss)
        S = pop!(Ss)
        for T in Ss    
            if !isempty(intersect(cc[S], setdiff(T, cc[T]))) & !isempty(intersect(cc[T], setdiff(S, cc[S]))) 
		return false
	    end
        end
    end
    return true
end

"""
```isJLF(cc::ChoiceCorrespondence{T}) where T <: Int```

Is the Jamison Lau Fishburn condition verified?

# Arguments

- `cc`: the choice correspondence to be tested.
"""
function isJLF(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) in cc
        for (T, cT) in cc
	    if (length(T) == 2) | (S == T) | !issubset(S, setdiff(T, cT))
		continue
	    end
            for (U, cU) in cc
		if (T == U) | (S == U) | isempty(intersect(cT, U))
		    continue
		elseif !isempty(intersect(setdiff(S, cS),  cU))
	  	    return false
		end
            end
        end
    end
    return true
end


"""
```isOO(cc::ChoiceCorrespondence{T}) where T <: Int```

Test the occasional optimality condition of Mira Frick (2016).

# Arguments

- `cc`: the choice correspondence to be tested.
"""
function isOO(cc::ChoiceCorrespondence{T}) where T <: Int
    for (S, cS) in cc
        OOS = false       
        for x in cS
            OOx = true
            for (T, cT) in cc
                if in(x, T) & !isempty(intersect(cT, S)) & !in(x, cT)
			OOx = false
		end
            end
            if OOx
                for(T, cT) in cc
                    if !in(x, T)
			continue
		    end
                    for y in S
                        if !in(y, T) & !issubset(cT, cc[sort(union(T, y))]) 
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
```isFP(cc::Dict{Vector{Int}, Vector{Int}})```

Test the fixed point axiom of Aleskerov, Buyssou and Monjardet (2007).

# Arguments

- `cc`: the choice correspondence to be tested.
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
            for (T, cT) in cc
		if !issubset(T, S) | (T == S) 
		    continue
		elseif in(x, T) & !in(x, cT) 
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
```isFA(cc::ChoiceCorrespondence{T}, ndg::Int = 0) where T <: Int```

Test the functional acyclicity axiom of Aleskerov, Buyssou and Monjardet (2007).

# Arguments

- `cc`: the choice correspondence to be tested.
- `ndg`: Size of the digraph, if not given, will look in the choice correspondence for the length.
"""
function isFA(cc::ChoiceCorrespondence{T}, ndg::Int = 0) where T <: Int
    if ndg == 0
        set = Set{Int}()
        for (S, cS) in cc
            for x in S
                push!(set, x)
            end
        end
        ndg = length(set)       
    end
    dg = DiGraph(ndg)
    for (S, cS) in cc
        for x in cS, y in setdiff(S, cS)
            add_edge!(dg, x, y)
        end
    end
    return !is_cyclic(dg)
end
