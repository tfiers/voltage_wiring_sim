
cacheroot::String = joinpath(homedir(), ".phdcache")


"""
Load the pre-computed output of `f` from disk, if available. Else, run `f` and save to disk.

Useful when re-running a cell in a notebook, or restarting a Julia session later.

Function runs are identified by the hashes of the elements of `key`, and the function name.
The `key` elements are saved on disk alongside the output.

The contents of the files on disk can be inspected using `f = jldopen(cachepath(f, key))`
(shows groupnames), and then `f["name"]`. Finally, `close(f)`

Usage:

    function slow_func(intermediary_result_x_for_neuron_n, params::ExperimentParams) … end
    …
    output = cached(slow_func, [x, p]; key=[p, n]])
"""
function cached(f, args; key = [last(args)], verbose = true)
    path = cachepath(f, key)
    if isfile(path)
        if verbose @withfb "Loading cached output from `$path`" (output = loadcache(path))
        else (output = loadcache(path))
        end
    else
        output = f(args...)
        if verbose @withfb "Saving output at `$path`" savecache(path, output; key)
        else savecache(path, output; key)
        end
    end
    return output
end

cachepath(f, key) = joinpath(cachedir(f), cachefilename(key) * ".jld2")
cachedir(f)              = joinpath(cacheroot, string(nameof(f)))
cachedir(subdir::String) = joinpath(cacheroot, subdir)
cachefilename(key::String) = key
function cachefilename(key::Vector)
    h = zero(UInt)
    for el in key
        h = hash(el, h)
    end
    return string(h, base=16)
end
function savecache(path, output; kw...)
    dir = dirname(path)
    mkpath(dir)
    jldsave(path; output, kw...)
end
loadcache(path) = load(path, "output")
empty_cache(path) = rm(path, force = true)
empty_cache(f, key) = empty_cache(cachepath(f, key))


"""
The hash of a set of parameters is different if a value is changed, if the struct (the type)
is renamed, and if a field is renamed/added/removed. It does not change when fields are
reordered.
"""
Base.hash(p::ParamSet, h::UInt) = hash_contents(p, h)

# By default, `hash(x)` is based on `objectid(x)` (⇔ `is` aka `===`), which is not stable
# across Julia sessions for custom structs like `LogNormal`. This function should be.
function hash_contents(x, h::UInt)
    type = typeof(x)
    h = hash(nameof(type), h)
    # Sort field names, so reordering fields doesn't change hash.
    for fieldname in sort!(collect(fieldnames(type)))
        value = getproperty(x, fieldname)
        h = hash(fieldname, h)
        valtype = typeof(value)
        if isstructtype(valtype) && fieldcount(valtype) > 0
                # Vectors are structtypes, but have no fields. So use `hash`.
            h = hash_contents(value, h)
        else
            h = hash(value, h)
        end
    end
    return h
end
