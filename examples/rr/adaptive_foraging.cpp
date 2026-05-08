#include <iostream>
#include <iomanip>
#include <string>
#include <vector>
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
    std::cout << "\n" << std::string(60, '=') << std::endl;
    std::cout << title << std::endl;
    std::cout << std::string(60, '=') << std::endl;
}

int main() {
    std::cout << "=== Adaptive Foraging Agent — RR Cognitive P-System ===" << std::endl;
    std::cout << "A cognitive foraging agent explores food-source arenas,\n"
              << "learns relevance through RR dynamics, reasons with PLN,\n"
              << "and persists knowledge for future sessions.\n" << std::endl;

    // ================================================================
    // Phase 1 — Environment Setup
    // ================================================================
    printSection("Phase 1: Environment Setup");

    RRHypergraph hypergraph;
    AtomSpace atomspace;

    // Add agent node: the forager (membrane_id=1)
    unsigned forager_id = hypergraph.addMembraneNode(1, "forager", AARType::AGENT);

    // Add food-source arena nodes
    unsigned berry_id    = hypergraph.addMembraneNode(2, "berry_patch", AARType::ARENA);
    unsigned mushroom_id = hypergraph.addMembraneNode(3, "mushroom_grove", AARType::ARENA);
    unsigned fish_id     = hypergraph.addMembraneNode(4, "river_fish", AARType::ARENA);

    // Add environment arena node (membrane_id=0)
    unsigned forest_id   = hypergraph.addMembraneNode(0, "forest", AARType::ARENA);

    // Connect the forager to each food source with INTERACTION edges
    hypergraph.addRelationEdge(forager_id, berry_id,    RREdge::INTERACTION, 0.8);
    hypergraph.addRelationEdge(forager_id, mushroom_id, RREdge::INTERACTION, 0.5);
    hypergraph.addRelationEdge(forager_id, fish_id,     RREdge::INTERACTION, 0.9);

    // Connect environment to forager with CO_CONSTRUCTION
    hypergraph.addRelationEdge(forest_id, forager_id, RREdge::CO_CONSTRUCTION, 0.4);

    // Print initial state
    std::cout << "Nodes:  " << hypergraph.nodes.size() << std::endl;
    std::cout << "Edges:  " << hypergraph.edges.size() << std::endl;

    std::cout << "\nInitial salience values:" << std::endl;
    for (auto it = hypergraph.nodes.begin(); it != hypergraph.nodes.end(); ++it) {
        std::cout << "  " << std::setw(16) << std::left << it->second->label
                  << " salience=" << std::fixed << std::setprecision(3)
                  << it->second->salience << std::endl;
    }

    // ================================================================
    // Phase 2 — RR Dynamics (Exploration)
    // ================================================================
    printSection("Phase 2: RR Dynamics — Exploration");

    RRAtomSpaceIntegrator integrator(&hypergraph, &atomspace);

    for (int step = 1; step <= 30; ++step) {
        hypergraph.updateRelevanceRealization(0.1);

        if (step % 10 == 0) {
            std::cout << "\n--- Step " << step << " ---" << std::endl;

            integrator.performIntegration();
            auto patterns = integrator.findEmergentPatterns();

            std::cout << "Salience values:" << std::endl;
            for (auto it = hypergraph.nodes.begin(); it != hypergraph.nodes.end(); ++it) {
                std::cout << "  " << std::setw(16) << std::left << it->second->label
                          << " salience=" << std::fixed << std::setprecision(3)
                          << it->second->salience << std::endl;
            }

            if (!patterns.empty()) {
                std::cout << "Emergent patterns:" << std::endl;
                for (const auto& p : patterns) {
                    std::cout << "  * " << p << std::endl;
                }
            } else {
                std::cout << "No emergent patterns detected yet." << std::endl;
            }
        }
    }

    // Print coupling strengths between forager and each food source
    std::cout << "\nCoupling strengths (forager <-> food source):" << std::endl;

    std::vector<std::pair<unsigned, std::string>> arenas = {
        {berry_id, "berry_patch"}, {mushroom_id, "mushroom_grove"}, {fish_id, "river_fish"}
    };

    for (const auto& arena : arenas) {
        double coupling = hypergraph.computeCouplingStrength(forager_id, arena.first);
        std::cout << "  forager <-> " << std::setw(16) << std::left << arena.second
                  << " coupling=" << std::fixed << std::setprecision(3) << coupling << std::endl;
    }

    // ================================================================
    // Phase 3 — PLN Reasoning (Strategy)
    // ================================================================
    printSection("Phase 3: PLN Reasoning — Strategy");

    PLNInferenceEngine pln_engine(&atomspace);

    std::cout << "Generating implications from RR state..." << std::endl;
    pln_engine.generateRRImplications(&hypergraph);

    std::cout << "Running PLN inference (deduction + abduction)..." << std::endl;
    auto deductions = pln_engine.performDeduction();
    auto abductions = pln_engine.performAbduction();

    // Print all implication links
    auto implications = atomspace.findAtomsOfType(Atom::IMPLICATION_LINK);
    std::cout << "\nGenerated " << implications.size() << " implication links:" << std::endl;
    for (unsigned impl_id : implications) {
        auto impl_atom = atomspace.getAtom(impl_id);
        if (impl_atom && impl_atom->outgoing.size() >= 2) {
            auto ant  = atomspace.getAtom(impl_atom->outgoing[0]);
            auto cons = atomspace.getAtom(impl_atom->outgoing[1]);
            if (ant && cons) {
                std::cout << "  " << ant->name << " -> " << cons->name
                          << " [strength=" << std::fixed << std::setprecision(3)
                          << impl_atom->strength << "]" << std::endl;
            }
        }
    }

    // Print inference results
    std::cout << "\nInference results: " << deductions.size() << " deductions, "
              << abductions.size() << " abductions" << std::endl;

    // Determine best foraging strategy: arena with highest coupling to forager
    std::string best_arena;
    double best_coupling = -1.0;
    for (const auto& arena : arenas) {
        double coupling = hypergraph.computeCouplingStrength(forager_id, arena.first);
        if (coupling > best_coupling) {
            best_coupling = coupling;
            best_arena = arena.second;
        }
    }
    std::cout << "\nBest foraging strategy: prioritize " << best_arena
              << " (coupling=" << std::fixed << std::setprecision(3)
              << best_coupling << ")" << std::endl;

    // ================================================================
    // Phase 4 — Scheme Interface (Inspection)
    // ================================================================
    printSection("Phase 4: Scheme Interface — Inspection");

    SchemeEvaluator evaluator(&hypergraph, &atomspace);

    std::vector<std::string> commands = {
        "(list-rr-nodes)",
        "(get-system-relevance)",
        "(find-patterns)",
        "(get-salience node-1)"
    };

    for (const auto& cmd : commands) {
        std::cout << "scheme> " << cmd << std::endl;
        std::string result = evaluator.evaluate(cmd);
        std::cout << result << std::endl << std::endl;
    }

    // ================================================================
    // Phase 5 — Persistence (Memory)
    // ================================================================
    printSection("Phase 5: Persistence — Memory");

    PersistentAtomSpace storage;

    // Save AtomSpace and RR hypergraph
    std::cout << "Saving AtomSpace to /tmp/foraging_atomspace.json ..." << std::endl;
    bool saved_as = storage.saveToFile(&atomspace, "/tmp/foraging_atomspace.json");
    std::cout << "AtomSpace save " << (saved_as ? "successful" : "failed") << std::endl;

    std::cout << "Saving RR hypergraph to /tmp/foraging_rr.json ..." << std::endl;
    bool saved_rr = storage.saveRRHypergraph(&hypergraph, "/tmp/foraging_rr.json");
    std::cout << "RR hypergraph save " << (saved_rr ? "successful" : "failed") << std::endl;

    // Memory consolidation
    size_t atoms_before = atomspace.atoms.size();
    std::cout << "\nAtoms before consolidation: " << atoms_before << std::endl;
    storage.consolidateMemory(&atomspace, 0.3);
    size_t atoms_after = atomspace.atoms.size();
    std::cout << "Atoms after consolidation:  " << atoms_after << std::endl;

    // Summary
    printSection("Summary");
    std::cout << "The forager learned that " << best_arena
              << " is the most relevant food source with coupling strength "
              << std::fixed << std::setprecision(3) << best_coupling << "." << std::endl;

    std::cout << "\nFinal system state:" << std::endl;
    std::cout << "  RR nodes:        " << hypergraph.nodes.size() << std::endl;
    std::cout << "  RR edges:        " << hypergraph.edges.size() << std::endl;
    std::cout << "  AtomSpace atoms: " << atomspace.atoms.size() << std::endl;

    std::cout << "\n=== Adaptive foraging demo completed ===" << std::endl;
    return 0;
}
