#include <iostream>
#include <iomanip>
#include <relevance_realization.hpp>
#include <atomspace_integration.hpp>
#include <pln_integration.hpp>
#include <scheme_interface.hpp>
#include <persistent_atomspace.hpp>

using namespace plingua::rr;
using namespace plingua::atomspace;
using namespace plingua::pln;
using namespace plingua::scheme;
using namespace plingua::persistent;

void printSection(const std::string& title) {
    std::cout << "\n" << std::string(50, '=') << std::endl;
    std::cout << title << std::endl;
    std::cout << std::string(50, '=') << std::endl;
}

void demonstratePLNIntegration(RRHypergraph* hypergraph, AtomSpace* atomspace) {
    printSection("PLN Integration Demonstration");
    
    PLNInferenceEngine pln_engine(atomspace);
    
    // Generate implications from RR patterns
    std::cout << "Generating PLN implications from RR patterns..." << std::endl;
    pln_engine.generateRRImplications(hypergraph);
    
    // Show implication links
    auto implications = atomspace->findAtomsOfType(Atom::IMPLICATION_LINK);
    std::cout << "Generated " << implications.size() << " implication links:" << std::endl;
    
    for (unsigned impl_id : implications) {
        auto impl_atom = atomspace->getAtom(impl_id);
        if (impl_atom && impl_atom->outgoing.size() >= 2) {
            auto ant = atomspace->getAtom(impl_atom->outgoing[0]);
            auto cons = atomspace->getAtom(impl_atom->outgoing[1]);
            if (ant && cons) {
                std::cout << "  " << ant->name << " -> " << cons->name 
                          << " [strength=" << std::fixed << std::setprecision(3) << impl_atom->strength << "]" << std::endl;
            }
        }
    }
    
    // Perform PLN inference cycle
    std::cout << "\nRunning PLN inference cycle..." << std::endl;
    pln_engine.performInferenceCycle(hypergraph);
    
    auto results = pln_engine.getInferenceResults();
    for (const auto& result : results) {
        std::cout << "  " << result << std::endl;
    }
}

void demonstrateSchemeInterface(RRHypergraph* hypergraph, AtomSpace* atomspace) {
    printSection("Scheme Interface Demonstration");
    
    SchemeEvaluator evaluator(hypergraph, atomspace);
    
    // Test various Scheme commands
    std::vector<std::string> commands = {
        "(list-rr-nodes)",
        "(get-system-relevance)",
        "(run-pln-inference)",
        "(find-patterns)",
        "(get-salience node-2)",
        "(find-atom \"agent\")"
    };
    
    for (const auto& cmd : commands) {
        std::cout << "scheme> " << cmd << std::endl;
        std::string result = evaluator.evaluate(cmd);
        std::cout << result << std::endl << std::endl;
    }
    
    std::cout << "Note: Interactive REPL can be started with evaluator.startREPL()" << std::endl;
}

void demonstratePersistentStorage(RRHypergraph* hypergraph, AtomSpace* atomspace) {
    printSection("Persistent Storage Demonstration");
    
    PersistentAtomSpace storage;
    
    // Save current state
    std::cout << "Saving AtomSpace to file..." << std::endl;
    bool saved_as = storage.saveToFile(atomspace, "/tmp/atomspace_state.json");
    std::cout << "AtomSpace save " << (saved_as ? "successful" : "failed") << std::endl;
    
    std::cout << "Saving RR hypergraph to file..." << std::endl;
    bool saved_rr = storage.saveRRHypergraph(hypergraph, "/tmp/rr_hypergraph.json");
    std::cout << "RR hypergraph save " << (saved_rr ? "successful" : "failed") << std::endl;
    
    // Demonstrate memory consolidation
    std::cout << "\nBefore consolidation: " << atomspace->atoms.size() << " atoms" << std::endl;
    storage.consolidateMemory(atomspace, 0.3); // Remove atoms with confidence < 0.3
    std::cout << "After consolidation: " << atomspace->atoms.size() << " atoms" << std::endl;
    
    // Test loading (create new AtomSpace to verify)
    AtomSpace test_atomspace;
    std::cout << "\nTesting load from file..." << std::endl;
    bool loaded = storage.loadFromFile(&test_atomspace, "/tmp/atomspace_state.json");
    std::cout << "Load " << (loaded ? "successful" : "failed") << std::endl;
}

void demonstrateMultiLevelIntegration(RRHypergraph* hypergraph, AtomSpace* atomspace) {
    printSection("Multi-Level Integration Demonstration");
    
    // Create hierarchical structure
    std::cout << "Creating hierarchical membrane structure..." << std::endl;
    
    // Add nested membranes
    unsigned outer_membrane = hypergraph->addMembraneNode(10, "outer_membrane", AARType::ARENA);
    unsigned inner_agent = hypergraph->addMembraneNode(11, "inner_agent", AARType::AGENT);
    unsigned inner_arena = hypergraph->addMembraneNode(12, "inner_arena", AARType::ARENA);
    
    // Create hierarchical relations
    hypergraph->addRelationEdge(outer_membrane, inner_agent, RREdge::CO_CONSTRUCTION, 0.6);
    hypergraph->addRelationEdge(outer_membrane, inner_arena, RREdge::CO_CONSTRUCTION, 0.6);
    hypergraph->addRelationEdge(inner_agent, inner_arena, RREdge::INTERACTION, 0.8);
    
    std::cout << "Added hierarchical structure with " << hypergraph->nodes.size() << " total nodes" << std::endl;
    
    // Update RR dynamics for multiple levels
    std::cout << "Running multi-level RR dynamics..." << std::endl;
    for (int i = 0; i < 20; ++i) {
        hypergraph->updateRelevanceRealization(0.05);
    }
    
    // Check for cross-level emergent patterns
    std::cout << "\nDetecting cross-level emergent patterns..." << std::endl;
    
    double outer_salience = hypergraph->nodes[outer_membrane]->salience;
    double inner_coherence = (hypergraph->nodes[inner_agent]->computeTrialecticCoherence() + 
                             hypergraph->nodes[inner_arena]->computeTrialecticCoherence()) / 2.0;
    
    if (outer_salience > 0.6 && inner_coherence > 0.3) {
        std::cout << "Cross-level emergence detected: outer salience=" << outer_salience 
                  << ", inner coherence=" << inner_coherence << std::endl;
    }
    
    // Temporal reasoning simulation
    std::cout << "\nSimulating temporal reasoning..." << std::endl;
    std::vector<double> temporal_relevance;
    
    for (int t = 0; t < 10; ++t) {
        hypergraph->updateRelevanceRealization(0.1);
        
        double total_relevance = 0.0;
        for (auto it = hypergraph->nodes.begin(); it != hypergraph->nodes.end(); ++it) {
            total_relevance += it->second->computeRelevanceGradient();
        }
        temporal_relevance.push_back(total_relevance / hypergraph->nodes.size());
        
        std::cout << "  Time " << t << ": system relevance = " 
                  << std::fixed << std::setprecision(3) << temporal_relevance.back() << std::endl;
    }
    
    // Simple trend analysis
    if (temporal_relevance.size() >= 3) {
        double trend = temporal_relevance.back() - temporal_relevance[temporal_relevance.size()-3];
        std::cout << "Temporal trend: " << (trend > 0 ? "increasing" : trend < 0 ? "decreasing" : "stable") 
                  << " (Δ=" << trend << ")" << std::endl;
    }
}

int main() {
    std::cout << "=== Next Development Directions - Comprehensive Demo ===" << std::endl;
    
    // Initialize core components
    RRHypergraph hypergraph;
    AtomSpace atomspace;
    RRAtomSpaceIntegrator integrator(&hypergraph, &atomspace);
    
    // Create initial test environment
    std::cout << "\nSetting up test environment..." << std::endl;
    unsigned env_node = hypergraph.addMembraneNode(0, "environment", AARType::ARENA);
    unsigned agent_node = hypergraph.addMembraneNode(1, "agent_membrane", AARType::AGENT);
    unsigned arena_node = hypergraph.addMembraneNode(2, "arena_membrane", AARType::ARENA);
    
    hypergraph.addRelationEdge(agent_node, arena_node, RREdge::CO_CONSTRUCTION, 0.7);
    hypergraph.addRelationEdge(env_node, agent_node, RREdge::INTERACTION, 0.5);
    
    // Run initial RR dynamics
    for (int i = 0; i < 10; ++i) {
        hypergraph.updateRelevanceRealization(0.1);
    }
    
    // Perform initial AtomSpace integration
    integrator.performIntegration();
    
    // Demonstrate all Next Development Directions
    demonstratePLNIntegration(&hypergraph, &atomspace);
    demonstrateSchemeInterface(&hypergraph, &atomspace);
    demonstratePersistentStorage(&hypergraph, &atomspace);
    demonstrateMultiLevelIntegration(&hypergraph, &atomspace);
    
    printSection("Summary");
    std::cout << "Demonstrated Next Development Directions:" << std::endl;
    std::cout << "✓ Advanced PLN Integration" << std::endl;
    std::cout << "✓ Enhanced Scheme Interface" << std::endl;
    std::cout << "✓ Persistent AtomSpace" << std::endl;
    std::cout << "✓ Multi-Level Integration" << std::endl;
    
    std::cout << "\nFinal system state:" << std::endl;
    std::cout << "  RR nodes: " << hypergraph.nodes.size() << std::endl;
    std::cout << "  RR edges: " << hypergraph.edges.size() << std::endl;
    std::cout << "  AtomSpace atoms: " << atomspace.atoms.size() << std::endl;
    
    // Compute final system relevance
    double total_relevance = 0.0;
    for (auto it = hypergraph.nodes.begin(); it != hypergraph.nodes.end(); ++it) {
        total_relevance += it->second->computeRelevanceGradient();
    }
    double system_relevance = hypergraph.nodes.size() > 0 ? total_relevance / hypergraph.nodes.size() : 0.0;
    std::cout << "  System relevance: " << std::fixed << std::setprecision(3) << system_relevance << std::endl;
    
    std::cout << "\n=== Comprehensive demo completed ===" << std::endl;
    return 0;
}