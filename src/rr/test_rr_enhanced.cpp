#include <iostream>
#include <iomanip>
#include <relevance_realization.hpp>
#include <atomspace_integration.hpp>

using namespace plingua::rr;
using namespace plingua::atomspace;

void printRRState(const RRHypergraph* hypergraph) {
    if (!hypergraph) return;
    
    std::cout << "\n=== RR Hypergraph State ===" << std::endl;
    std::cout << "Nodes: " << hypergraph->nodes.size() << std::endl;
    
    for (auto it = hypergraph->nodes.begin(); it != hypergraph->nodes.end(); ++it) {
        auto node = it->second;
        std::cout << "  Node " << node->id << " (" << node->label << "): "
                  << "salience=" << std::fixed << std::setprecision(3) << node->salience
                  << ", affordance=" << node->affordance_realization
                  << ", coherence=" << node->computeTrialecticCoherence() << std::endl;
    }
    
    std::cout << "Edges: " << hypergraph->edges.size() << std::endl;
    for (auto it = hypergraph->edges.begin(); it != hypergraph->edges.end(); ++it) {
        auto edge = it->second;
        std::cout << "  Edge " << edge->id << ": " << edge->from_node 
                  << " -> " << edge->to_node 
                  << ", strength=" << edge->strength << std::endl;
    }
}

void printAtomSpaceState(const AtomSpace* atomspace) {
    if (!atomspace) return;
    
    std::cout << "\n=== AtomSpace State ===" << std::endl;
    std::cout << "Total atoms: " << atomspace->atoms.size() << std::endl;
    
    auto concepts = atomspace->findAtomsOfType(Atom::CONCEPT_NODE);
    std::cout << "Concept nodes: " << concepts.size() << std::endl;
    for (unsigned id : concepts) {
        auto atom = atomspace->getAtom(id);
        if (atom) {
            std::cout << "  " << atom->name 
                      << " [strength=" << std::fixed << std::setprecision(3) << atom->strength
                      << ", confidence=" << atom->confidence << "]" << std::endl;
        }
    }
    
    auto evaluations = atomspace->findAtomsOfType(Atom::EVALUATION_LINK);
    std::cout << "Evaluation links: " << evaluations.size() << std::endl;
    for (unsigned id : evaluations) {
        auto atom = atomspace->getAtom(id);
        if (atom && atom->outgoing.size() >= 3) {
            auto pred = atomspace->getAtom(atom->outgoing[0]);
            auto arg1 = atomspace->getAtom(atom->outgoing[1]);
            auto arg2 = atomspace->getAtom(atom->outgoing[2]);
            if (pred && arg1 && arg2) {
                std::cout << "  " << pred->name << "(" << arg1->name << ", " << arg2->name << ")"
                          << " [strength=" << atom->strength << "]" << std::endl;
            }
        }
    }
}

int main() {
    std::cout << "=== Enhanced RR Development & AtomSpace Integration Test ===" << std::endl;
    
    // Create and initialize RR hypergraph directly
    RRHypergraph hypergraph;
    
    // Create test nodes
    unsigned env_node = hypergraph.addMembraneNode(0, "environment", AARType::ARENA);
    unsigned agent_node = hypergraph.addMembraneNode(1, "agent_membrane", AARType::AGENT);
    unsigned arena_node = hypergraph.addMembraneNode(2, "arena_membrane", AARType::ARENA);
    
    // Create test relations
    hypergraph.addRelationEdge(agent_node, arena_node, RREdge::CO_CONSTRUCTION, 0.7);
    
    std::cout << "\nInitial state:" << std::endl;
    printRRState(&hypergraph);
    
    // Set up AtomSpace integration
    AtomSpace atomspace;
    RRAtomSpaceIntegrator integrator(&hypergraph, &atomspace);
    integrator.performIntegration();
    
    printAtomSpaceState(&atomspace);
    
    // Run simulation for several steps
    std::cout << "\nRunning 50 simulation steps..." << std::endl;
    for (int i = 0; i < 50; ++i) {
        hypergraph.updateRelevanceRealization(0.1);
        
        // Print intermediate state every 10 steps
        if ((i + 1) % 10 == 0) {
            std::cout << "\nStep " << (i + 1) << " state:" << std::endl;
            printRRState(&hypergraph);
            
            // Update AtomSpace
            integrator.performIntegration();
            
            // Show emergent patterns
            auto patterns = integrator.findEmergentPatterns();
            if (!patterns.empty()) {
                std::cout << "Emergent patterns detected:" << std::endl;
                for (const std::string& pattern : patterns) {
                    std::cout << "  - " << pattern << std::endl;
                }
            }
        }
    }
    
    // Final state with AtomSpace
    std::cout << "\nFinal state:" << std::endl;
    printRRState(&hypergraph);
    printAtomSpaceState(&atomspace);
    
    // Compute overall system relevance
    double total_relevance = 0.0;
    size_t node_count = 0;
    
    for (auto it = hypergraph.nodes.begin(); it != hypergraph.nodes.end(); ++it) {
        total_relevance += it->second->computeRelevanceGradient();
        ++node_count;
    }
    
    double system_relevance = node_count > 0 ? total_relevance / node_count : 0.0;
    std::cout << "\nOverall system relevance: " << std::fixed << std::setprecision(3) 
              << system_relevance << std::endl;
    
    std::cout << "\n=== Test completed ===" << std::endl;
    return 0;
}