#include <iostream>
#include <relevance_realization.hpp>
#include <atomspace_integration.hpp>
#include <scheme_interface.hpp>

using namespace plingua::rr;
using namespace plingua::atomspace;
using namespace plingua::scheme;

int main() {
    std::cout << "=== Interactive RR/AtomSpace Scheme REPL Demo ===" << std::endl;
    
    // Initialize system
    RRHypergraph hypergraph;
    AtomSpace atomspace;
    RRAtomSpaceIntegrator integrator(&hypergraph, &atomspace);
    
    // Create test environment
    unsigned agent = hypergraph.addMembraneNode(1, "agent", AARType::AGENT);
    unsigned arena = hypergraph.addMembraneNode(2, "arena", AARType::ARENA);
    hypergraph.addRelationEdge(agent, arena, RREdge::CO_CONSTRUCTION, 0.8);
    
    // Run some dynamics
    for (int i = 0; i < 5; ++i) {
        hypergraph.updateRelevanceRealization(0.1);
    }
    
    integrator.performIntegration();
    
    // Start Scheme REPL
    SchemeEvaluator evaluator(&hypergraph, &atomspace);
    
    std::cout << "\nStarting interactive REPL..." << std::endl;
    std::cout << "Try commands like: (list-rr-nodes), (get-system-relevance), (find-patterns)" << std::endl;
    std::cout << "Or just press Enter a few times to skip the interactive part." << std::endl;
    
    // evaluator.startREPL(); // Uncomment for actual interactive REPL
    
    // For non-interactive demo, show some sample commands
    std::vector<std::string> demo_commands = {
        "(list-rr-nodes)",
        "(list-atoms)", 
        "(get-system-relevance)",
        "(find-patterns)",
        "(get-salience node-1)"
    };
    
    std::cout << "\nDemo commands:" << std::endl;
    for (const auto& cmd : demo_commands) {
        std::cout << "scheme> " << cmd << std::endl;
        std::cout << evaluator.evaluate(cmd) << std::endl;
        std::cout << std::endl;
    }
    
    std::cout << "Interactive REPL demo completed." << std::endl;
    return 0;
}