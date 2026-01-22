# House Elevation Model for Lab 2
# Minimal SimOptDecisions types for flood risk analysis

using SimOptDecisions

# Config: fixed parameters (don't change across scenarios)
Base.@kwdef struct HouseConfig{T<:AbstractFloat} <: AbstractConfig
    house_value::T = 250_000.0
    base_elevation::T = 0.0  # first floor elevation (ft)
end

# Scenario: one state of the world (a single flood event)
struct FloodScenario{T<:AbstractFloat} <: AbstractScenario
    water_level::T  # flood stage (ft)
end

"""Logistic depth-damage function. Returns damage as fraction of house value (0 to 1)."""
function depth_damage(depth::T; threshold::T=one(T), saturation::T=T(7)) where {T<:AbstractFloat}
    depth <= threshold && return zero(T)
    depth >= saturation && return one(T)
    midpoint = (threshold + saturation) / 2
    steepness = T(6) / (saturation - threshold)
    return one(T) / (one(T) + exp(-steepness * (depth - midpoint)))
end

"""Compute flood damage for a house given a flood scenario."""
function compute_damage(config::HouseConfig{T}, scenario::FloodScenario{T}) where {T<:AbstractFloat}
    flood_depth = scenario.water_level - config.base_elevation
    damage_fraction = depth_damage(flood_depth)
    return damage_fraction * config.house_value
end
