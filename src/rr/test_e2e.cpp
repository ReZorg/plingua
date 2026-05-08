// End-to-end unit tests for the Relevance Realization P-Systems framework.
// Tests cover node/edge creation, dynamics, AtomSpace integration, and emergent patterns.

#include <iostream>
#include <cassert>
#include <cmath>
#include <string>
#include "relevance_realization.hpp"
#include "atomspace_integration.hpp"

using namespace plingua::rr;
using namespace plingua::atomspace;

static int tests_run = 0;
static int tests_passed = 0;

#define ASSERT_TRUE(cond, msg) \
    do { \
        ++tests_run; \
        if (cond) { \
            ++tests_passed; \
        } else { \
            std::cerr << "FAIL [" << __func__ << ":" << __LINE__ << "] " << msg << "\n"; \
        } \
    } while (0)

#define ASSERT_NEAR(a, b, eps, msg) \
    ASSERT_TRUE(std::fabs((a) - (b)) < (eps), msg)

static void assertAllSalienceBounded(const RRHypergraph& hg, const std::string& context) {
    bool all_valid = true;
    for (auto& kv : hg.nodes) {
        if (kv.second->salience < 0.0 || kv.second->salience > 1.0) {
            all_valid = false;
        }
    }
    ASSERT_TRUE(all_valid, "all node salience values in [0,1]: " + context);
}

// --- RRNode tests ---

void test_node_creation() {
    RRNode node(1, RRNode::MEMBRANE, AARType::AGENT, "test_agent");
    ASSERT_TRUE(node.id == 1, "node id");
    ASSERT_TRUE(node.nodeType == RRNode::MEMBRANE, "node type");
    ASSERT_TRUE(node.aarType == AARType::AGENT, "aar type");
    ASSERT_TRUE(node.label == "test_agent", "node label");
    ASSERT_NEAR(node.salience, 0.5, 1e-9, "default salience");
    ASSERT_NEAR(node.affordance_potential, 1.0, 1e-9, "default affordance_potential");
    ASSERT_TRUE(node.trialectic_state.size() == 3, "trialectic state size");
}

void test_trialectic_coherence() {
    RRNode node(2, RRNode::RULE, AARType::RELATION, "rel");
    // coherence should be in [0, 1] range
    double c = node.computeTrialecticCoherence();
    ASSERT_TRUE(c >= 0.0 && c <= 1.0, "trialectic coherence in [0,1]");
}

void test_relevance_gradient() {
    RRNode node(3, RRNode::OBJECT, AARType::ARENA, "arena");
    node.affordance_potential = 2.0;
    node.affordance_realization = 1.0;
    double g = node.computeRelevanceGradient();
    // log(1.0 / 2.0) = -log(2) < 0
    ASSERT_TRUE(g < 0.0, "relevance gradient negative when realization < potential");

    node.affordance_realization = node.affordance_potential;
    double g2 = node.computeRelevanceGradient();
    ASSERT_NEAR(g2, 0.0, 1e-9, "relevance gradient zero when realization == potential");
}

// --- RRHypergraph tests ---

void test_hypergraph_add_nodes() {
    RRHypergraph hg;
    unsigned n1 = hg.addMembraneNode(1, "agent", AARType::AGENT);
    unsigned n2 = hg.addMembraneNode(2, "arena", AARType::ARENA);
    ASSERT_TRUE(hg.nodes.size() == 2, "two nodes added");
    ASSERT_TRUE(hg.nodes.count(n1) == 1, "node 1 exists");
    ASSERT_TRUE(hg.nodes.count(n2) == 1, "node 2 exists");
}

void test_hypergraph_add_edge() {
    RRHypergraph hg;
    unsigned n1 = hg.addMembraneNode(1, "agent", AARType::AGENT);
    unsigned n2 = hg.addMembraneNode(2, "arena", AARType::ARENA);
    unsigned e = hg.addRelationEdge(n1, n2, RREdge::CO_CONSTRUCTION, 0.7);
    ASSERT_TRUE(hg.edges.size() == 1, "one edge added");
    ASSERT_TRUE(hg.edges.count(e) == 1, "edge exists");
    ASSERT_NEAR(hg.edges[e]->strength, 0.7, 1e-9, "edge strength");
    ASSERT_TRUE(hg.edges[e]->from_node == n1, "edge from");
    ASSERT_TRUE(hg.edges[e]->to_node == n2, "edge to");
}

void test_hypergraph_update_dynamics() {
    RRHypergraph hg;
    unsigned n1 = hg.addMembraneNode(1, "agent", AARType::AGENT);
    unsigned n2 = hg.addMembraneNode(2, "arena", AARType::ARENA);
    hg.addRelationEdge(n1, n2, RREdge::CO_CONSTRUCTION, 0.5);

    double salience_before = hg.nodes[n1]->salience;
    hg.updateRelevanceRealization(0.1);
    double salience_after = hg.nodes[n1]->salience;
    // Salience should change after a dynamics step
    ASSERT_TRUE(salience_after != salience_before, "dynamics update changes node salience");
    // Salience must remain in valid range
    ASSERT_TRUE(salience_after >= 0.0 && salience_after <= 1.0,
                "salience remains in [0,1] after dynamics update");
}

void test_hypergraph_multiple_updates() {
    RRHypergraph hg;
    unsigned agent = hg.addMembraneNode(1, "agent", AARType::AGENT);
    unsigned arena = hg.addMembraneNode(2, "arena", AARType::ARENA);
    hg.addRelationEdge(agent, arena, RREdge::CO_CONSTRUCTION, 0.8);

    for (int i = 0; i < 10; ++i) {
        hg.updateRelevanceRealization(0.05);
    }

    assertAllSalienceBounded(hg, "after 10 steps");
}

// --- scheme_like interface tests ---

void test_scheme_make_rr_node() {
    std::map<std::string, double> props;
    props["salience"] = 0.9;
    props["affordance"] = 1.5;
    auto node = scheme_like::make_rr_node(RRNode::MEMBRANE, AARType::AGENT, "agent1", props);
    ASSERT_TRUE(node != nullptr, "make_rr_node returns non-null");
    ASSERT_NEAR(node->salience, 0.9, 1e-9, "salience set from props");
    ASSERT_NEAR(node->affordance_potential, 1.5, 1e-9, "affordance_potential set from props");
    ASSERT_TRUE(node->label == "agent1", "label set");
}

void test_scheme_make_relation() {
    std::map<std::string, double> rel_props;
    rel_props["strength"] = 0.6;
    auto edge = scheme_like::make_relation(1, 2, rel_props);
    ASSERT_TRUE(edge != nullptr, "make_relation returns non-null");
    ASSERT_NEAR(edge->strength, 0.6, 1e-9, "edge strength set");
    ASSERT_TRUE(edge->from_node == 1, "from_node");
    ASSERT_TRUE(edge->to_node == 2, "to_node");
}

// --- AtomSpace tests ---

void test_atomspace_add_concept_node() {
    AtomSpace as;
    unsigned id = as.addConceptNode("foo", 0.8, 0.9);
    ASSERT_TRUE(as.atoms.count(id) == 1, "atom added");
    ASSERT_TRUE(as.atoms[id]->type == Atom::CONCEPT_NODE, "atom type");
    ASSERT_TRUE(as.atoms[id]->name == "foo", "atom name");
    ASSERT_NEAR(as.atoms[id]->strength, 0.8, 1e-9, "atom strength");
    ASSERT_NEAR(as.atoms[id]->confidence, 0.9, 1e-9, "atom confidence");
}

void test_atomspace_find_by_type() {
    AtomSpace as;
    as.addConceptNode("a");
    as.addConceptNode("b");
    as.addPredicateNode("p");
    auto concepts = as.findAtomsOfType(Atom::CONCEPT_NODE);
    ASSERT_TRUE(concepts.size() == 2, "two concept nodes found");
    auto predicates = as.findAtomsOfType(Atom::PREDICATE_NODE);
    ASSERT_TRUE(predicates.size() == 1, "one predicate node found");
}

void test_atomspace_get_atom() {
    AtomSpace as;
    unsigned id = as.addConceptNode("bar");
    auto atom = as.getAtom(id);
    ASSERT_TRUE(atom != nullptr, "getAtom returns non-null");
    ASSERT_TRUE(atom->name == "bar", "getAtom returns correct atom");
    auto missing = as.getAtom(99999);
    ASSERT_TRUE(missing == nullptr, "getAtom returns null for unknown id");
}

void test_atomspace_rr_integration() {
    RRHypergraph hg;
    unsigned agent = hg.addMembraneNode(1, "agent", AARType::AGENT);
    unsigned arena  = hg.addMembraneNode(2, "arena",  AARType::ARENA);
    hg.addRelationEdge(agent, arena, RREdge::CO_CONSTRUCTION, 0.7);

    AtomSpace as;
    RRAtomSpaceIntegrator integrator(&hg, &as);
    integrator.convertRRNodesToAtoms();

    // Each node should create at least a concept node
    ASSERT_TRUE(as.atoms.size() >= 2, "atoms created for hypergraph nodes");
}

// --- end-to-end scenario test ---

void test_e2e_agent_arena_emergence() {
    // Build a small P-system-inspired RR scenario:
    // One agent membrane, two arena membranes, run dynamics, check emergent relations appear.
    RRHypergraph hg;
    unsigned agent  = hg.addMembraneNode(1, "forager",    AARType::AGENT);
    unsigned arena1 = hg.addMembraneNode(2, "environment", AARType::ARENA);
    unsigned arena2 = hg.addMembraneNode(3, "prey_zone",   AARType::ARENA);

    hg.nodes[agent]->salience  = 0.9;
    hg.nodes[arena1]->salience = 0.8;
    hg.nodes[arena2]->salience = 0.85;

    hg.addRelationEdge(agent, arena1, RREdge::CO_CONSTRUCTION, 0.9);
    hg.addRelationEdge(agent, arena2, RREdge::CO_CONSTRUCTION, 0.85);

    size_t initial_nodes = hg.nodes.size();

    // Run enough steps to trigger emergent pattern detection
    for (int i = 0; i < 20; ++i) {
        hg.updateRelevanceRealization(0.1);
    }

    ASSERT_TRUE(hg.nodes.size() >= initial_nodes, "nodes not lost during dynamics");
    ASSERT_TRUE(hg.edges.size() >= 2, "edges not lost during dynamics");
    assertAllSalienceBounded(hg, "after 20 steps");
}

int main() {
    std::cout << "=== RRR-P-Systems E2E Unit Tests ===\n\n";

    test_node_creation();
    test_trialectic_coherence();
    test_relevance_gradient();
    test_hypergraph_add_nodes();
    test_hypergraph_add_edge();
    test_hypergraph_update_dynamics();
    test_hypergraph_multiple_updates();
    test_scheme_make_rr_node();
    test_scheme_make_relation();
    test_atomspace_add_concept_node();
    test_atomspace_find_by_type();
    test_atomspace_get_atom();
    test_atomspace_rr_integration();
    test_e2e_agent_arena_emergence();

    std::cout << "\nResults: " << tests_passed << "/" << tests_run << " tests passed.\n";
    return (tests_passed == tests_run) ? 0 : 1;
}
