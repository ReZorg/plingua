#ifndef _RELEVANCE_REALIZATION_HPP_
#define _RELEVANCE_REALIZATION_HPP_

#include <vector>
#include <map>
#include <set>
#include <string>
#include <memory>
#include <functional>
#include <algorithm>
#include <numeric>
#include <cmath>
#include <cstdlib>
#include "serialization.hpp"

namespace plingua { namespace rr {

// Forward declarations
class RRNode;
class RREdge;
class RRHypergraph;

// Relevance Realization primitives
enum class RRPrimitive {
    SELECTION,
    SALIENCE, 
    AFFORDANCE
};

// ─────────────────────────────────────────────────────────────────────────────
// Trielectic Ennead State
// Nine dimensions across three triads:
//   Triad A (Agent):    identity_continuity, skill_readiness, motivational_valence
//   Triad B (Arena):    constraint_clarity,  affordance_density, feedback_latency
//   Triad C (Relation): coupling_strength,   reciprocal_shaping, adaptive_fit
// ─────────────────────────────────────────────────────────────────────────────
struct EnneadState {
    // Triad A – Agent
    double identity_continuity;   // a0 ∈ [0,1]
    double skill_readiness;       // a1 ∈ [0,1]
    double motivational_valence;  // a2 ∈ [0,1]

    // Triad B – Arena
    double constraint_clarity;    // b0 ∈ [0,1]
    double affordance_density;    // b1 ∈ [0,1]
    double feedback_latency;      // b2 ∈ [0,1]

    // Triad C – Relation
    double coupling_strength;     // c0 ∈ [0,1]
    double reciprocal_shaping;    // c1 ∈ [0,1]
    double adaptive_fit;          // c2 ∈ [0,1]

    EnneadState()
        : identity_continuity(0.5), skill_readiness(0.5), motivational_valence(0.5),
          constraint_clarity(0.5),  affordance_density(0.5),  feedback_latency(0.5),
          coupling_strength(0.5),   reciprocal_shaping(0.5),  adaptive_fit(0.5) {}

    EnneadState(double a0, double a1, double a2,
                double b0, double b1, double b2,
                double c0, double c1, double c2)
        : identity_continuity(a0), skill_readiness(a1), motivational_valence(a2),
          constraint_clarity(b0),  affordance_density(b1),  feedback_latency(b2),
          coupling_strength(c0),   reciprocal_shaping(c1),  adaptive_fit(c2) {}

    // Return all nine dimensions as an ordered vector
    std::vector<double> toVector() const {
        return { identity_continuity, skill_readiness, motivational_valence,
                 constraint_clarity,  affordance_density,  feedback_latency,
                 coupling_strength,   reciprocal_shaping,  adaptive_fit };
    }

    // Load nine dimensions from a vector (clamped to [0,1])
    void fromVector(const std::vector<double>& v) {
        auto clamp = [](double x) { return std::max(0.0, std::min(1.0, x)); };
        if (v.size() >= 9) {
            identity_continuity  = clamp(v[0]); skill_readiness     = clamp(v[1]);
            motivational_valence = clamp(v[2]); constraint_clarity  = clamp(v[3]);
            affordance_density   = clamp(v[4]); feedback_latency    = clamp(v[5]);
            coupling_strength    = clamp(v[6]); reciprocal_shaping  = clamp(v[7]);
            adaptive_fit         = clamp(v[8]);
        }
    }

    // Mean of each triad (A, B, C)
    double triadA() const { return (identity_continuity + skill_readiness + motivational_valence) / 3.0; }
    double triadB() const { return (constraint_clarity  + affordance_density  + feedback_latency)  / 3.0; }
    double triadC() const { return (coupling_strength   + reciprocal_shaping  + adaptive_fit)       / 3.0; }

    // Ennead balance: 1 − normalized variance across all nine dimensions.
    // High balance (→1) means all dimensions are roughly equal.
    // Low balance  (→0) means large disparities between dimensions.
    double balance() const {
        std::vector<double> v = toVector();
        double mean = std::accumulate(v.begin(), v.end(), 0.0) / 9.0;
        double var  = 0.0;
        for (double d : v) var += (d - mean) * (d - mean);
        var /= 9.0;
        // Maximum possible variance for values in [0,1] is 0.25 (half at 0, half at 1).
        return std::max(0.0, 1.0 - var / 0.25);
    }

    // Propagate intra-triad circular coupling: d[i] ← tanh(d[i] + k*(d[i+1] − d[i-1]))
    // Applied independently to each of the three triads.
    void propagateTriads(double k) {
        auto step3 = [&](double& d0, double& d1, double& d2) {
            double n0 = d0 + k * (d1 - d2) / 2.0;
            double n1 = d1 + k * (d2 - d0) / 2.0;
            double n2 = d2 + k * (d0 - d1) / 2.0;
            auto clamp_tanh = [](double x) { return (std::tanh(x) + 1.0) / 2.0; };
            d0 = clamp_tanh(n0); d1 = clamp_tanh(n1); d2 = clamp_tanh(n2);
        };
        step3(identity_continuity, skill_readiness, motivational_valence);
        step3(constraint_clarity,  affordance_density, feedback_latency);
        step3(coupling_strength,   reciprocal_shaping, adaptive_fit);
    }

    // Cross-triad coupling: A ↔ B ↔ C ↔ A using mean values
    void propagateCrossTriad(double k) {
        double a = triadA(), b = triadB(), c = triadC();
        auto bump = [&](double base, double prev, double next) {
            return std::max(0.0, std::min(1.0, base + k * (next - prev) / 2.0));
        };
        double na = bump(a, c, b);
        double nb = bump(b, a, c);
        double nc = bump(c, b, a);
        // Distribute delta back proportionally to each triad dimension
        auto scale3 = [](double& d0, double& d1, double& d2, double delta) {
            d0 = std::max(0.0, std::min(1.0, d0 + delta));
            d1 = std::max(0.0, std::min(1.0, d1 + delta));
            d2 = std::max(0.0, std::min(1.0, d2 + delta));
        };
        scale3(identity_continuity, skill_readiness, motivational_valence, (na - a) / 3.0);
        scale3(constraint_clarity,  affordance_density, feedback_latency,  (nb - b) / 3.0);
        scale3(coupling_strength,   reciprocal_shaping, adaptive_fit,      (nc - c) / 3.0);
    }

    // Full ennead update step
    void update(double delta_time, double coupling = 0.1) {
        propagateTriads(delta_time * coupling);
        propagateCrossTriad(delta_time * coupling * 0.5);
    }
};

// Agent-Arena-Relation triad types
enum class AARType {
    AGENT,
    ARENA,
    RELATION
};

// Structure for tracking emergent patterns
struct EmergentCluster {
    unsigned agent_id;
    std::vector<unsigned> arena_ids;
    std::vector<double> coupling_strengths;
    double coherence;
    
    EmergentCluster() : agent_id(0), coherence(0.0) {}
};

// RR Node representing membranes, rules, or objects in the hypergraph
class RRNode {
public:
    enum Type { MEMBRANE, RULE, OBJECT, ENVIRONMENT };
    
    unsigned id;
    Type nodeType;
    AARType aarType;
    std::string label;
    
    // RR properties
    double salience;
    double affordance_potential;
    double affordance_realization;
    std::map<RRPrimitive, double> rr_properties;
    
    // Links to original P-system components
    unsigned original_membrane_id;
    unsigned original_rule_id;
    std::string original_object;
    
    // Trialectic state (x,y,z) — legacy 3-element form kept for backward compat
    std::vector<double> trialectic_state;

    // ── Ennead extension ──────────────────────────────────────────────────────
    // Per-node ennead state; initialized from system-level ennead or defaults.
    EnneadState ennead;

    // Derived per-node metrics (recomputed each update step)
    double coherence;    // trialectic coherence ∈ [0,1]  (renamed from implicit)
    double grip_index;   // optimal cognitive grip ∈ [0,1]
    // ─────────────────────────────────────────────────────────────────────────

    RRNode(unsigned nodeId, Type type, AARType aar, const std::string& nodeLabel) 
        : id(nodeId), nodeType(type), aarType(aar), label(nodeLabel),
          salience(0.5), affordance_potential(1.0), affordance_realization(0.3),
          original_membrane_id(0), original_rule_id(0), trialectic_state(3, 0.1),
          coherence(0.5), grip_index(0.0) {
        // Initialize trialectic state (legacy) with small random values
        for (size_t i = 0; i < trialectic_state.size(); ++i) {
            trialectic_state[i] = 0.1 * (double(rand()) / RAND_MAX - 0.5);
        }
    }

    // ── Grip index computation ────────────────────────────────────────────────
    // grip_index = (realization/potential) × coherence × ennead_balance
    // Bounded to [0,1].
    double computeGripIndex() const {
        if (affordance_potential <= 0) return 0.0;
        double realization_ratio = std::min(1.0, affordance_realization / affordance_potential);
        return std::max(0.0, std::min(1.0,
            realization_ratio * coherence * ennead.balance()));
    }
    // ─────────────────────────────────────────────────────────────────────────
          
    // Compute relevance gradient: ∇ℜ = lim_{t→∞} Σᵢ log(affordance_realizationᵢ(t)/affordance_potentialᵢ(t))
    double computeRelevanceGradient() const {
        if (affordance_potential <= 0) return 0.0;
        // Use a small epsilon to prevent log(0) issues
        double epsilon = 1e-6;
        double ratio = std::max(epsilon, affordance_realization) / affordance_potential;
        return std::log(ratio);
    }
    
    // Update salience based on RR dynamics (ennead-aware)
    void updateSalience(double delta_time) {
        // 1. Update legacy trialectic state (backward compat)
        if (trialectic_state.size() >= 3) {
            std::vector<double> new_state = trialectic_state;
            for (size_t i = 0; i < trialectic_state.size(); ++i) {
                size_t prev = (i + trialectic_state.size() - 1) % trialectic_state.size();
                size_t next = (i + 1) % trialectic_state.size();
                double k = salience * delta_time;
                new_state[i] += k * (trialectic_state[next] - trialectic_state[prev]) / 2.0;
                new_state[i] = std::tanh(new_state[i]);
            }
            trialectic_state = new_state;
        }

        // 2. Update per-node ennead state
        ennead.update(delta_time);

        // 3. Recompute coherence from both legacy trialectic and ennead balance
        double tc = computeTrialecticCoherence();
        double eb = ennead.balance();
        // Blend: coherence = 0.5*trialectic_coherence + 0.5*ennead_balance
        coherence = std::max(0.0, std::min(1.0, 0.5 * tc + 0.5 * eb));

        // 4. Update salience incorporating both relevance gradient and ennead feedback
        double relevance_gradient = computeRelevanceGradient();
        double ennead_feedback = 0.2 * eb + 0.1 * ennead.adaptive_fit;
        salience = (std::tanh(salience + delta_time * (relevance_gradient
                    + 0.3 * tc + ennead_feedback)) + 1.0) / 2.0;

        // 5. Update grip index
        grip_index = computeGripIndex();
    }
    
    // Compute trialectic coherence measure, normalized to [0, 1]
    double computeTrialecticCoherence() const {
        if (trialectic_state.size() < 3) return 0.0;
        
        double coherence_val = 0.0;
        for (size_t i = 0; i < trialectic_state.size(); ++i) {
            size_t next = (i + 1) % trialectic_state.size();
            coherence_val += trialectic_state[i] * trialectic_state[next];
        }
        // Raw value is in [-1, 1]; map to [0, 1]
        return (coherence_val / trialectic_state.size() + 1.0) / 2.0;
    }
};

// RR Edge representing relations in agent-arena dynamics
class RREdge {
public:
    enum Type { APPLICATION, INTERACTION, CO_CONSTRUCTION, EMERGENT };
    
    unsigned id;
    Type edgeType;
    unsigned from_node;
    unsigned to_node;
    
    // RR relation properties
    double strength;
    double relevance_weight;
    std::map<std::string, double> properties;
    
    RREdge(unsigned edgeId, Type type, unsigned from, unsigned to, double weight = 0.5)
        : id(edgeId), edgeType(type), from_node(from), to_node(to),
          strength(weight), relevance_weight(weight) {}
          
    // Agent-arena co-construction: agent ↔^δ arena ∈ ℝ^(∞×∞)
    void updateCoConstruction(const RRNode& from, const RRNode& to, double delta_time) {
        // Bidirectional morphism updating both nodes
        double co_construction_factor = delta_time * strength * 
            (from.salience * to.affordance_potential + to.salience * from.affordance_potential);
        relevance_weight = std::tanh(relevance_weight + co_construction_factor);
        strength = std::max(0.0, std::min(1.0, strength + co_construction_factor * 0.1));
    }
};

// Hypergraph for representing the living P-system as RR architecture
class RRHypergraph {
public:
    std::map<unsigned, std::shared_ptr<RRNode>> nodes;
    std::map<unsigned, std::shared_ptr<RREdge>> edges;
    unsigned next_node_id;
    unsigned next_edge_id;
    
    // Agent-Arena-Relation mappings
    std::set<unsigned> agent_nodes;
    std::set<unsigned> arena_nodes;
    std::set<unsigned> relation_edges;

    // ── System-level ennead + grip metrics ───────────────────────────────────
    EnneadState system_ennead;   // system-wide trielectic ennead state

    // Global objective metrics (updated each updateRelevanceRealization() call)
    double relevance_gradient;   // mean ∇ℜ across all nodes
    double ennead_balance;       // mean per-node ennead balance
    double grip_stability;       // variance of grip_index (lower = more stable)
    double emergence_score;      // fraction of nodes that are EMERGENT relation nodes

    // Constraint parameters (can be set by R-Lingua @constraints block)
    double salience_threshold;       // nodes below this may be pruned
    double affordance_decay;         // per-step decay applied to affordance_realization
    double grip_threshold;           // minimum grip_index for healthy operation
    double convergence_window_size;  // steps for stability check
    double emergence_sensitivity;    // coupling threshold for spawning new RELATION nodes
    // ─────────────────────────────────────────────────────────────────────────
    
    RRHypergraph()
        : next_node_id(1), next_edge_id(1),
          relevance_gradient(0.0), ennead_balance(0.5),
          grip_stability(1.0),     emergence_score(0.0),
          salience_threshold(0.05), affordance_decay(0.0),
          grip_threshold(0.3),      convergence_window_size(50.0),
          emergence_sensitivity(0.7) {}
    
    // Create RR node from P-system components
    unsigned addMembraneNode(unsigned membrane_id, const std::string& label, AARType aar_type) {
        auto node = std::make_shared<RRNode>(next_node_id++, RRNode::MEMBRANE, aar_type, label);
        node->original_membrane_id = membrane_id;
        // Inherit system ennead as starting point
        node->ennead = system_ennead;
        nodes[node->id] = node;
        
        if (aar_type == AARType::AGENT) agent_nodes.insert(node->id);
        else if (aar_type == AARType::ARENA) arena_nodes.insert(node->id);
        
        return node->id;
    }
    
    unsigned addRuleNode(unsigned rule_id, const std::string& label) {
        auto node = std::make_shared<RRNode>(next_node_id++, RRNode::RULE, AARType::AGENT, label);
        node->original_rule_id = rule_id;
        node->ennead = system_ennead;
        nodes[node->id] = node;
        agent_nodes.insert(node->id);
        return node->id;
    }
    
    unsigned addObjectNode(const std::string& object_name, AARType aar_type) {
        auto node = std::make_shared<RRNode>(next_node_id++, RRNode::OBJECT, aar_type, object_name);
        node->original_object = object_name;
        node->ennead = system_ennead;
        nodes[node->id] = node;
        
        if (aar_type == AARType::AGENT) agent_nodes.insert(node->id);
        else if (aar_type == AARType::ARENA) arena_nodes.insert(node->id);
        
        return node->id;
    }
    
    // Create relation edges
    unsigned addRelationEdge(unsigned from_node, unsigned to_node, RREdge::Type type, double strength = 0.5) {
        auto edge = std::make_shared<RREdge>(next_edge_id++, type, from_node, to_node, strength);
        edges[edge->id] = edge;
        relation_edges.insert(edge->id);
        return edge->id;
    }
    
    // Recursive relevance realization update
    void updateRelevanceRealization(double delta_time) {
        // 1. Update system-level ennead
        system_ennead.update(delta_time);

        // 2. Apply affordance decay
        if (affordance_decay > 0.0) {
            for (auto& kv : nodes) {
                kv.second->affordance_realization =
                    std::max(0.0, kv.second->affordance_realization * (1.0 - affordance_decay * delta_time));
            }
        }

        // 3. Update all nodes (salience, coherence, grip_index)
        for (auto it = nodes.begin(); it != nodes.end(); ++it) {
            it->second->updateSalience(delta_time);
        }
        
        // 4. Update all edges with co-construction dynamics
        for (auto it = edges.begin(); it != edges.end(); ++it) {
            auto edge = it->second;
            if (nodes.count(edge->from_node) && nodes.count(edge->to_node)) {
                edge->updateCoConstruction(*nodes[edge->from_node], *nodes[edge->to_node], delta_time);
            }
        }
        
        // 5. Update global objective metrics
        updateGlobalMetrics();

        // 6. Detect emergent patterns
        detectEmergentPatterns();
    }

    // ── Global metric computation ─────────────────────────────────────────────
    void updateGlobalMetrics() {
        if (nodes.empty()) {
            relevance_gradient = 0.0;
            ennead_balance     = 0.5;
            grip_stability     = 1.0;
            emergence_score    = 0.0;
            return;
        }

        double sum_gradient = 0.0, sum_balance = 0.0, sum_grip = 0.0;
        double sum_grip_sq  = 0.0;
        unsigned emergent_count = 0;

        for (auto& kv : nodes) {
            auto& n = *kv.second;
            sum_gradient += n.computeRelevanceGradient();
            sum_balance  += n.ennead.balance();
            sum_grip     += n.grip_index;
            sum_grip_sq  += n.grip_index * n.grip_index;
            if (n.aarType == AARType::RELATION) ++emergent_count;
        }

        double count = static_cast<double>(nodes.size());
        relevance_gradient = sum_gradient / count;
        ennead_balance     = sum_balance  / count;
        double mean_grip   = sum_grip / count;
        // Variance: E[x²] - E[x]²
        grip_stability     = std::max(0.0, sum_grip_sq / count - mean_grip * mean_grip);
        emergence_score    = static_cast<double>(emergent_count) / count;
    }

    // Test whether the system has converged (grip_stability and ennead_balance criteria)
    bool hasConverged() const {
        return grip_stability < 0.01 && ennead_balance > 0.8;
    }
    // ─────────────────────────────────────────────────────────────────────────
    
    // Monitor for emergent agent-arena-relations
    void detectEmergentPatterns() {
        // Enhanced emergence detection with multiple criteria
        std::vector<EmergentCluster> clusters;
        
        // 1. Detect high-relevance clusters
        for (auto agent_id : agent_nodes) {
            if (!nodes.count(agent_id)) continue;
            auto agent = nodes[agent_id];
            
            if (agent->salience > 0.8 && agent->affordance_realization > 0.7) {
                EmergentCluster cluster;
                cluster.agent_id = agent_id;
                cluster.coherence = agent->computeTrialecticCoherence();
                
                // Check for arena coupling
                for (auto arena_id : arena_nodes) {
                    if (!nodes.count(arena_id)) continue;
                    auto arena = nodes[arena_id];
                    
                    double cs = computeCouplingStrength(agent_id, arena_id);
                    if (cs > emergence_sensitivity) {
                        cluster.arena_ids.push_back(arena_id);
                        cluster.coupling_strengths.push_back(cs);
                    }
                }
                
                if (!cluster.arena_ids.empty()) {
                    clusters.push_back(cluster);
                }
            }
        }
        
        // 2. Create emergent relations for strong clusters
        for (const auto& cluster : clusters) {
            if (cluster.coherence > grip_threshold && !cluster.coupling_strengths.empty()) {
                double avg_coupling = 0.0;
                for (double s : cluster.coupling_strengths) avg_coupling += s;
                avg_coupling /= cluster.coupling_strengths.size();
                
                if (avg_coupling > emergence_sensitivity) {
                    createEmergentRelation(cluster.agent_id, cluster.arena_ids[0]);
                }
            }
        }
    }
    
    // Compute coupling strength between agent and arena
    double computeCouplingStrength(unsigned agent_id, unsigned arena_id) const {
        double total_strength = 0.0;
        int edge_count = 0;
        
        for (auto edge_it = edges.begin(); edge_it != edges.end(); ++edge_it) {
            auto edge = edge_it->second;
            if ((edge->from_node == agent_id && edge->to_node == arena_id) ||
                (edge->from_node == arena_id && edge->to_node == agent_id)) {
                total_strength += edge->strength;
                ++edge_count;
            }
        }
        
        return edge_count > 0 ? total_strength / edge_count : 0.0;
    }
    
private:
    void createEmergentRelation(unsigned agent_id, unsigned arena_id) {
        // Guard: don't create duplicate emergent relations
        std::string emergent_label =
            "emergent_" + std::to_string(agent_id) + "_" + std::to_string(arena_id);
        for (auto& kv : nodes) {
            if (kv.second->label == emergent_label) return;
        }

        auto emergent_node = std::make_shared<RRNode>(
            next_node_id++, RRNode::OBJECT, AARType::RELATION, emergent_label);
        emergent_node->salience = (nodes[agent_id]->salience + nodes[arena_id]->salience) * 0.5;
        emergent_node->affordance_realization = 1.0;
        // Inherit system ennead boosted by relation triad
        emergent_node->ennead = system_ennead;
        emergent_node->ennead.coupling_strength   = std::min(1.0, system_ennead.coupling_strength   + 0.1);
        emergent_node->ennead.reciprocal_shaping  = std::min(1.0, system_ennead.reciprocal_shaping  + 0.1);
        emergent_node->ennead.adaptive_fit        = std::min(1.0, system_ennead.adaptive_fit        + 0.05);
        nodes[emergent_node->id] = emergent_node;
        
        // Connect emergent node to both agent and arena
        addRelationEdge(emergent_node->id, agent_id, RREdge::EMERGENT, 0.9);
        addRelationEdge(emergent_node->id, arena_id, RREdge::EMERGENT, 0.9);
    }
};

// Utility functions for creating Scheme-like RR structures
namespace scheme_like {

// Make RR node equivalent to (make-rr-node type properties)
inline std::shared_ptr<RRNode> make_rr_node(RRNode::Type type, AARType aar_type, 
    const std::string& label, const std::map<std::string, double>& properties = {}) {
    auto node = std::make_shared<RRNode>(0, type, aar_type, label);
    
    // Set properties from map
    for (auto it = properties.begin(); it != properties.end(); ++it) {
        const std::string& key = it->first;
        double value = it->second;
        if (key == "salience") node->salience = value;
        else if (key == "affordance") node->affordance_potential = value;
        // Add more property mappings as needed
    }
    
    return node;
}

// Make relation equivalent to (make-relation from to properties)
inline std::shared_ptr<RREdge> make_relation(unsigned from, unsigned to, 
    const std::map<std::string, double>& properties = {}) {
    RREdge::Type type = RREdge::INTERACTION;
    double strength = 0.5;
    
    // Extract properties
    for (auto it = properties.begin(); it != properties.end(); ++it) {
        const std::string& key = it->first;
        double value = it->second;
        if (key == "strength") strength = value;
    }
    
    return std::make_shared<RREdge>(0, type, from, to, strength);
}

} // namespace scheme_like

}} // namespace plingua::rr

#endif // _RELEVANCE_REALIZATION_HPP_