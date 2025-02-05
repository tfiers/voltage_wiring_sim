function init_Nto1_sim(p::SimParams)

    @unpack duration, num_timesteps, rngseed, input, synapses, izh_neuron  = p
    @unpack N_unconn, N_exc, N_inh, N_conn, N                              = input
    @unpack g_t0, E_exc, E_inh, avg_stim_rate_exc, avg_stim_rate_inh       = synapses
    @unpack v_t0, u_t0                                                     = izh_neuron

    # IDs, subgroup names.
    input_neuron_IDs = idvec(conn = idvec(exc = N_exc, inh = N_inh), unconn = N_unconn)
    synapse_IDs      = idvec(exc = N_exc, inh = N_inh)
    var_IDs          = idvec(t = scalar, v = scalar, u = scalar, g = similar(synapse_IDs))

    resetrng!(rngseed)

    # Inter-spike—interval distributions
    λ = similar(input_neuron_IDs, Float64)
    λ .= rand(p.input.spike_rates, length(λ))
    β = 1 ./ λ
    ISI_distributions = Exponential.(β)

    # Input spikes queue
    first_input_spike_times = rand.(ISI_distributions)
    upcoming_input_spikes   = PriorityQueue{Int, Float64}()
    for (n, t) in zip(input_neuron_IDs, first_input_spike_times)
        enqueue!(upcoming_input_spikes, n => t)
    end

    # Connections
    postsynapses = Dict{Int, Vector{Int}}()  # input_neuron_ID => [synapse_IDs...]
    for (n, s) in zip(input_neuron_IDs.conn, synapse_IDs)
        postsynapses[n] = [s]
    end
    for n in input_neuron_IDs.unconn
        postsynapses[n] = []
    end

    # Broadcast scalar parameters
    Δg = similar(synapse_IDs, Float64)
    Δg.exc .= avg_stim_rate_exc / mean(p.input.spike_rates)
    Δg.inh .= avg_stim_rate_inh / mean(p.input.spike_rates)
    E = similar(synapse_IDs, Float64)
    E.exc .= E_exc
    E.inh .= E_inh

    # Allocate memory to be overwritten every simulation step;
    # namely for the simulated variables and their time derivatives.
    vars = similar(var_IDs, Float64)
    vars.t = zero(duration)
    vars.v = v_t0
    vars.u = u_t0
    vars.g .= g_t0
    diff = similar(vars)  # = ∂x/∂t for every x in `vars`
    diff.t = 1 * s/s

    # Where to record to
    v_rec = Vector{Float64}(undef, num_timesteps)
    input_spikes = similar(input_neuron_IDs, Vector{Float64})
    for i in eachindex(input_spikes)
        input_spikes[i] = Vector{Float64}()
    end

    return (
        state = (
            fixed_at_init    = (; ISI_distributions, postsynapses, Δg, E),
            variable_in_time = (; vars, diff, upcoming_input_spikes),
        ),
        rec   = (; v = v_rec, input_spikes),
    )
end
