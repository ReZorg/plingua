#include <iostream>
#include <memory>
#include "relevance_realization.hpp"
#include "rr_simulator.hpp"

using namespace plingua::rr;

// Forward declaration
std::vector<std::string> getEmergentPatternsFromHypergraph(const RRHypergraph& hypergraph);

// Demo function showing the Scheme-like interface
void demonstrateSchemeInterface() {
    std::cout << "\n=== Scheme-like RR Interface Demo ===\n";
    
    // Create nodes like (make-rr-node 'arena '(membrane-id 1 env-params (ph 7.2)))
    std::map<std::string, double> arena_props;
    arena_props["salience"] = 0.6;
    arena_props["affordance"] = 1.2;
    auto arena1 = scheme_like::make_rr_node(RRNode::MEMBRANE, AARType::ARENA, "membrane_1", arena_props);
    
    // Create agent node like (make-rr-node 'agent '(rule "a+b->c" salience 0.8 affordance "bind"))
    std::map<std::string, double> agent_props;
    agent_props["salience"] = 0.8;
    agent_props["affordance"] = 0.9;
    auto agent1 = scheme_like::make_rr_node(RRNode::RULE, AARType::AGENT, "rule_bind", agent_props);
    
    // Create relation like (make-relation agent1 arena1 '(type "application" strength 0.5))
    std::map<std::string, double> rel_props;
    rel_props["strength"] = 0.5;
    auto relation1 = scheme_like::make_relation(agent1->id, arena1->id, rel_props);
    
    std::cout << "Created arena node: " << arena1->label 
              << " (salience: " << arena1->salience << ")\n";
    std::cout << "Created agent node: " << agent1->label 
              << " (salience: " << agent1->salience << ")\n";
    std::cout << "Created relation with strength: " << relation1->strength << "\n";
}

// Demo function showing hypergraph construction and RR dynamics
void demonstrateRRDynamics() {
    std::cout << "\n=== RR Dynamics Demo ===\n";
    
    // Create hypergraph
    RRHypergraph hypergraph;
    
    // Add trialectic components
    unsigned autopoiesis = hypergraph.addMembraneNode(1, "autopoiesis", AARType::ARENA);
    unsigned anticipation = hypergraph.addMembraneNode(2, "anticipation", AARType::AGENT);  
    unsigned adaptation = hypergraph.addMembraneNode(3, "adaptation", AARType::AGENT);
    
    // Add objects representing the triadic elements
    unsigned mu_bio = hypergraph.addObjectNode("mu_bio", AARType::ARENA);
    unsigned sigma_mil = hypergraph.addObjectNode("sigma_mil", AARType::ARENA);
    unsigned tau_trans = hypergraph.addObjectNode("tau_trans", AARType::ARENA);
    
    // Create co-constitutional relations: ∀^ω(x ⇔^α y ⇔^α z ⇔^α x)
    hypergraph.addRelationEdge(mu_bio, sigma_mil, RREdge::CO_CONSTRUCTION, 0.8);
    hypergraph.addRelationEdge(sigma_mil, tau_trans, RREdge::CO_CONSTRUCTION, 0.8);
    hypergraph.addRelationEdge(tau_trans, mu_bio, RREdge::CO_CONSTRUCTION, 0.8);
    
    // Agent-arena coupling: agent ↔^δ arena ∈ ℝ^(∞×∞)
    hypergraph.addRelationEdge(anticipation, autopoiesis, RREdge::CO_CONSTRUCTION, 0.7);
    hypergraph.addRelationEdge(adaptation, anticipation, RREdge::CO_CONSTRUCTION, 0.9);
    
    std::cout << "Initial hypergraph created with " << hypergraph.nodes.size() 
              << " nodes and " << hypergraph.edges.size() << " edges\n";
    
    // Set initial high salience for anticipation (agent)
    if (hypergraph.nodes.count(anticipation)) {
        hypergraph.nodes[anticipation]->salience = 0.9;
        hypergraph.nodes[anticipation]->affordance_realization = 0.8;
    }
    
    // Run RR dynamics simulation
    std::cout << "\nRunning RR dynamics...\n";
    for (int step = 0; step < 5; ++step) {
        std::cout << "Step " << step + 1 << ":\n";
        
        hypergraph.updateRelevanceRealization(0.1);
        
        // Report current state
        for (auto it = hypergraph.nodes.begin(); it != hypergraph.nodes.end(); ++it) {
            auto node = it->second;
            if (node->salience > 0.6) {
                std::cout << "  High-salience node " << node->label 
                          << ": salience=" << node->salience
                          << ", affordance=" << node->affordance_realization << "\n";
            }
        }
        
        // Check for emergent patterns
        auto patterns = getEmergentPatternsFromHypergraph(hypergraph);
        for (size_t i = 0; i < patterns.size(); ++i) {
            std::cout << "  EMERGENT: " << patterns[i] << "\n";
        }
    }
}

// Helper function to extract emergent patterns for demo
std::vector<std::string> getEmergentPatternsFromHypergraph(const RRHypergraph& hypergraph) {
    std::vector<std::string> patterns;
    
    for (auto it = hypergraph.nodes.begin(); it != hypergraph.nodes.end(); ++it) {
        auto node = it->second;
        if (node->salience > 0.8 && node->affordance_realization > 0.7) {
            patterns.push_back("High-relevance coupling in " + node->label);
        }
    }
    
    return patterns;
}

// Demo showing relevance gradient computation
void demonstrateRelevanceComputation() {
    std::cout << "\n=== Relevance Computation Demo ===\n";
    
    // Create a simple agent-arena pair
    auto agent = std::shared_ptr<RRNode>(new RRNode(1, RRNode::RULE, AARType::AGENT, "transform_rule"));
    agent->affordance_potential = 2.0;
    agent->affordance_realization = 1.5;
    agent->salience = 0.7;
    
    auto arena = std::shared_ptr<RRNode>(new RRNode(2, RRNode::MEMBRANE, AARType::ARENA, "context_membrane"));
    arena->affordance_potential = 3.0;
    arena->affordance_realization = 2.1;
    arena->salience = 0.6;
    
    std::cout << "Agent relevance gradient: " << agent->computeRelevanceGradient() << "\n";
    std::cout << "Arena relevance gradient: " << arena->computeRelevanceGradient() << "\n";
    
    // Simulate temporal evolution
    std::cout << "\nTemporal evolution:\n";
    for (int t = 0; t < 3; ++t) {
        agent->updateSalience(0.2);
        arena->updateSalience(0.2);
        
        std::cout << "t=" << t << " Agent salience: " << agent->salience 
                  << ", Arena salience: " << arena->salience << "\n";
    }
}

int main() {
    std::cout << "=== P-Lingua Relevance Realization Transformation Demo ===\n";
    std::cout << "Implementing Agent-Arena-Relation (AAR) architecture from P-Systems\n";
    
    try {
        demonstrateSchemeInterface();
        demonstrateRRDynamics();
        demonstrateRelevanceComputation();
        
        std::cout << "\n=== Demo Complete ===\n";
        std::cout << "Successfully demonstrated:\n";
        std::cout << "- Scheme-like RR node creation\n";
        std::cout << "- Hypergraph representation of P-systems\n";
        std::cout << "- Trialectic co-constitution dynamics\n";
        std::cout << "- Agent-arena co-construction\n";
        std::cout << "- Emergent pattern detection\n";
        std::cout << "- Relevance gradient computation\n";
        
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}