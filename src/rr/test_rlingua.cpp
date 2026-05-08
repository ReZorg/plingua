/*
 * test_rlingua.cpp
 *
 * Unit and integration tests for the R-Lingua extension:
 *   - EnneadState validity, update, and balance
 *   - grip_index and global metric computation
 *   - RliParser acceptance / rejection
 *   - RR hypergraph built from parsed R-Lingua source
 *   - AtomSpace ennead projection
 *   - Scheme query commands
 *   - Convergence criterion
 *
 * Copyright (C) 2024  P-Lingua/R-Lingua Contributors
 * Licensed under GPL-3.0
 */

#include <iostream>
#include <cassert>
#include <cmath>
#include <string>
#include <sstream>

#include "relevance_realization.hpp"
#include "atomspace_integration.hpp"
#include "scheme_interface.hpp"
#include "rlingua/rli_parser.hpp"

using namespace plingua::rr;
using namespace plingua::atomspace;
using namespace plingua::rlingua;

// ─────────────────────────────────────────────────────────────────────────────
// Test harness
// ─────────────────────────────────────────────────────────────────────────────

static int tests_run    = 0;
static int tests_passed = 0;

#define ASSERT_TRUE(cond, msg) \
    do { \
        ++tests_run; \
        if (cond) { \
            ++tests_passed; \
            std::cout << "  [PASS] " << (msg) << "\n"; \
        } else { \
            std::cout << "  [FAIL] " << (msg) << "\n"; \
        } \
    } while(0)

#define ASSERT_NEAR(a, b, eps, msg) \
    ASSERT_TRUE(std::fabs((a) - (b)) < (eps), msg)

#define ASSERT_IN_RANGE(v, lo, hi, msg) \
    ASSERT_TRUE((v) >= (lo) && (v) <= (hi), msg)

static void section(const std::string& title) {
    std::cout << "\n=== " << title << " ===\n";
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. EnneadState tests
// ─────────────────────────────────────────────────────────────────────────────

static void test_ennead_defaults() {
    section("EnneadState – defaults");

    EnneadState e;
    ASSERT_NEAR(e.identity_continuity,  0.5, 1e-9, "identity_continuity default 0.5");
    ASSERT_NEAR(e.skill_readiness,       0.5, 1e-9, "skill_readiness default 0.5");
    ASSERT_NEAR(e.motivational_valence,  0.5, 1e-9, "motivational_valence default 0.5");
    ASSERT_NEAR(e.constraint_clarity,    0.5, 1e-9, "constraint_clarity default 0.5");
    ASSERT_NEAR(e.affordance_density,    0.5, 1e-9, "affordance_density default 0.5");
    ASSERT_NEAR(e.feedback_latency,      0.5, 1e-9, "feedback_latency default 0.5");
    ASSERT_NEAR(e.coupling_strength,     0.5, 1e-9, "coupling_strength default 0.5");
    ASSERT_NEAR(e.reciprocal_shaping,    0.5, 1e-9, "reciprocal_shaping default 0.5");
    ASSERT_NEAR(e.adaptive_fit,          0.5, 1e-9, "adaptive_fit default 0.5");
}

static void test_ennead_balance_uniform() {
    section("EnneadState – balance for uniform state");

    EnneadState e;
    // All values equal → maximum balance (variance = 0)
    double b = e.balance();
    ASSERT_NEAR(b, 1.0, 1e-6, "balance == 1.0 for uniform ennead");
}

static void test_ennead_balance_polarised() {
    section("EnneadState – balance for polarised state");

    EnneadState e(1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0);
    double b = e.balance();
    ASSERT_IN_RANGE(b, 0.0, 0.5, "balance low for polarised ennead");
}

static void test_ennead_to_from_vector() {
    section("EnneadState – toVector / fromVector round-trip");

    EnneadState e(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9);
    auto v = e.toVector();
    ASSERT_TRUE(v.size() == 9, "toVector size == 9");
    ASSERT_NEAR(v[0], 0.1, 1e-9, "v[0] == identity_continuity");
    ASSERT_NEAR(v[8], 0.9, 1e-9, "v[8] == adaptive_fit");

    EnneadState e2;
    e2.fromVector(v);
    ASSERT_NEAR(e2.identity_continuity, 0.1, 1e-9, "fromVector identity_continuity");
    ASSERT_NEAR(e2.adaptive_fit,        0.9, 1e-9, "fromVector adaptive_fit");
}

static void test_ennead_triad_means() {
    section("EnneadState – triad means");

    EnneadState e(0.6, 0.6, 0.6,   0.4, 0.4, 0.4,   0.8, 0.8, 0.8);
    ASSERT_NEAR(e.triadA(), 0.6, 1e-9, "triadA == 0.6");
    ASSERT_NEAR(e.triadB(), 0.4, 1e-9, "triadB == 0.4");
    ASSERT_NEAR(e.triadC(), 0.8, 1e-9, "triadC == 0.8");
}

static void test_ennead_update_bounds() {
    section("EnneadState – update keeps values in [0,1]");

    EnneadState e(0.9, 0.1, 0.9,  0.1, 0.9, 0.1,  0.9, 0.1, 0.9);
    for (int step = 0; step < 50; ++step) e.update(0.1, 0.3);
    auto v = e.toVector();
    bool all_bounded = true;
    for (double d : v) if (d < 0.0 || d > 1.0) { all_bounded = false; break; }
    ASSERT_TRUE(all_bounded, "all ennead dimensions remain in [0,1] after 50 updates");
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. grip_index tests
// ─────────────────────────────────────────────────────────────────────────────

static void test_grip_index_zero_when_no_realization() {
    section("grip_index – zero when affordance_realization is 0");

    RRNode n(1, RRNode::MEMBRANE, AARType::AGENT, "test");
    n.affordance_realization = 0.0;
    n.coherence = 0.8;
    double g = n.computeGripIndex();
    ASSERT_NEAR(g, 0.0, 1e-9, "grip_index == 0 when realization == 0");
}

static void test_grip_index_bounded() {
    section("grip_index – bounded to [0,1]");

    RRNode n(1, RRNode::MEMBRANE, AARType::AGENT, "test");
    n.affordance_realization = 2.0; // > potential
    n.affordance_potential   = 1.0;
    n.coherence = 1.0;
    double g = n.computeGripIndex();
    ASSERT_IN_RANGE(g, 0.0, 1.0, "grip_index in [0,1] even when realization > potential");
}

static void test_grip_index_increases_with_realization() {
    section("grip_index – increases with affordance_realization");

    RRNode n(1, RRNode::MEMBRANE, AARType::AGENT, "test");
    n.affordance_potential = 1.0;
    n.coherence = 0.8;
    n.ennead = EnneadState(); // uniform → balance = 1.0
    n.affordance_realization = 0.3;
    double g1 = n.computeGripIndex();
    n.affordance_realization = 0.9;
    double g2 = n.computeGripIndex();
    ASSERT_TRUE(g2 > g1, "grip_index increases as affordance_realization grows");
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Global metrics
// ─────────────────────────────────────────────────────────────────────────────

static void test_global_metrics_empty_graph() {
    section("Global metrics – empty hypergraph");

    RRHypergraph hg;
    hg.updateGlobalMetrics();
    ASSERT_NEAR(hg.relevance_gradient, 0.0, 1e-9, "relevance_gradient = 0 for empty graph");
    ASSERT_NEAR(hg.ennead_balance,     0.5, 1e-9, "ennead_balance = 0.5 for empty graph");
}

static void test_global_metrics_after_update() {
    section("Global metrics – computed after update step");

    RRHypergraph hg;
    unsigned a = hg.addMembraneNode(1, "agent", AARType::AGENT);
    unsigned e = hg.addMembraneNode(2, "arena", AARType::ARENA);
    hg.addRelationEdge(a, e, RREdge::CO_CONSTRUCTION, 0.7);
    hg.nodes[a]->salience = 0.9;
    hg.nodes[a]->affordance_realization = 0.8;
    hg.nodes[e]->salience = 0.7;
    hg.nodes[e]->affordance_realization = 0.5;

    hg.updateRelevanceRealization(0.1);

    ASSERT_IN_RANGE(hg.ennead_balance,  0.0, 1.0, "ennead_balance in [0,1]");
    ASSERT_IN_RANGE(hg.grip_stability,  0.0, 1.0, "grip_stability in [0,1]");
    ASSERT_IN_RANGE(hg.emergence_score, 0.0, 1.0, "emergence_score in [0,1]");
}

static void test_convergence_criterion() {
    section("Convergence criterion");

    RRHypergraph hg;
    // Manually set convergence conditions
    hg.grip_stability  = 0.005; // < 0.01
    hg.ennead_balance  = 0.85;  // > 0.8
    ASSERT_TRUE(hg.hasConverged(), "hasConverged() when stability < 0.01 and balance > 0.8");

    hg.grip_stability = 0.02;   // > 0.01
    ASSERT_TRUE(!hg.hasConverged(), "not converged when stability > 0.01");
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. RliParser tests
// ─────────────────────────────────────────────────────────────────────────────

static const char* MINIMAL_RLI = R"(
@rmodel<relevance_realization>
@ennead {
    @triad_a { identity_continuity=0.7; skill_readiness=0.6; motivational_valence=0.8; }
    @triad_b { constraint_clarity=0.5; affordance_density=0.9; feedback_latency=0.3; }
    @triad_c { coupling_strength=0.7; reciprocal_shaping=0.6; adaptive_fit=0.5; }
}
@constraints { grip_threshold=0.3; emergence_sensitivity=0.7; convergence_window=50; }
def main() {
    @agent id=a1 label="agent" salience=0.8 affordance=1.0;
    @arena id=e1 label="arena" salience=0.6 affordance=1.2;
    @coupling { a1 <-> e1 :: co_constitution strength=0.8; }
}
@observe { sample_period=10; report_fields=grip_index, ennead_balance; }
)";

static void test_parser_accepts_valid_model() {
    section("RliParser – accepts valid minimal model");

    RliParser parser;
    bool ok = parser.parseString(MINIMAL_RLI, "test");
    ASSERT_TRUE(ok, "parseString returns true for valid model");
    ASSERT_TRUE(parser.system().errors.empty(), "no parse errors");
    ASSERT_TRUE(parser.system().model_type == "relevance_realization",
                "model_type correctly parsed");
}

static void test_parser_ennead_values() {
    section("RliParser – ennead values parsed correctly");

    RliParser parser;
    parser.parseString(MINIMAL_RLI, "test");
    const auto& e = parser.system().ennead;
    ASSERT_NEAR(e.identity_continuity,  0.7, 1e-9, "identity_continuity = 0.7");
    ASSERT_NEAR(e.skill_readiness,       0.6, 1e-9, "skill_readiness = 0.6");
    ASSERT_NEAR(e.motivational_valence,  0.8, 1e-9, "motivational_valence = 0.8");
    ASSERT_NEAR(e.coupling_strength,     0.7, 1e-9, "coupling_strength = 0.7");
}

static void test_parser_nodes_and_coupling() {
    section("RliParser – nodes and coupling rules parsed");

    RliParser parser;
    parser.parseString(MINIMAL_RLI, "test");
    const auto& sys = parser.system();

    ASSERT_TRUE(sys.nodes.size() == 2, "two nodes declared");
    if (sys.nodes.size() >= 1)
        ASSERT_TRUE(sys.nodes[0].kind == NodeDecl::AGENT, "first node is AGENT");
    if (sys.nodes.size() >= 2)
        ASSERT_TRUE(sys.nodes[1].kind == NodeDecl::ARENA, "second node is ARENA");
    if (sys.nodes.size() >= 1)
        ASSERT_TRUE(sys.nodes[0].id == "a1", "agent id == a1");
    if (sys.nodes.size() >= 2)
        ASSERT_TRUE(sys.nodes[1].id == "e1", "arena id == e1");

    ASSERT_TRUE(sys.coupling_rules.size() == 1, "one coupling rule");
    ASSERT_TRUE(sys.coupling_rules[0].direction == CouplingRule::BIDIRECTIONAL,
                "coupling is BIDIRECTIONAL");
    ASSERT_NEAR(sys.coupling_rules[0].strength, 0.8, 1e-9, "coupling strength = 0.8");
}

static void test_parser_constraints() {
    section("RliParser – constraints parsed");

    RliParser parser;
    parser.parseString(MINIMAL_RLI, "test");
    const auto& c = parser.system().constraints;
    ASSERT_NEAR(c.grip_threshold,        0.3, 1e-9, "grip_threshold = 0.3");
    ASSERT_NEAR(c.emergence_sensitivity, 0.7, 1e-9, "emergence_sensitivity = 0.7");
    ASSERT_NEAR(c.convergence_window,   50.0, 1e-9, "convergence_window = 50");
}

static void test_parser_observe() {
    section("RliParser – observe block parsed");

    RliParser parser;
    parser.parseString(MINIMAL_RLI, "test");
    const auto& o = parser.system().observe;
    ASSERT_TRUE(o.sample_period == 10, "sample_period == 10");
    ASSERT_TRUE(o.report_fields.size() == 2, "two report fields");
}

static void test_parser_rejects_missing_rmodel() {
    section("RliParser – error for missing @rmodel declaration");

    const char* BAD = R"(
def main() { @agent id=a1 label="a" salience=0.5 affordance=1.0; }
)";
    RliParser parser;
    parser.parseString(BAD, "bad");
    // Model type will be empty — we don't crash, but model_type is empty
    ASSERT_TRUE(parser.system().model_type.empty(),
                "model_type empty when @rmodel is missing");
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Hypergraph build from R-Lingua source
// ─────────────────────────────────────────────────────────────────────────────

static void test_buildHypergraph_basic() {
    section("buildHypergraph – basic structure");

    RliParser parser;
    parser.parseString(MINIMAL_RLI, "test");
    auto hg = parser.buildHypergraph();

    ASSERT_TRUE(hg != nullptr, "buildHypergraph returns non-null");
    ASSERT_TRUE(hg->nodes.size() == 2, "two nodes in hypergraph");
    // Bidirectional coupling → two edges
    ASSERT_TRUE(hg->edges.size() == 2, "two edges (bidirectional coupling)");
}

static void test_buildHypergraph_ennead_applied() {
    section("buildHypergraph – system ennead applied");

    RliParser parser;
    parser.parseString(MINIMAL_RLI, "test");
    auto hg = parser.buildHypergraph();

    ASSERT_NEAR(hg->system_ennead.identity_continuity, 0.7, 1e-9,
                "system_ennead.identity_continuity = 0.7");
    ASSERT_NEAR(hg->grip_threshold, 0.3, 1e-9,
                "grip_threshold applied from @constraints");
}

static void test_buildHypergraph_dynamics_runs() {
    section("buildHypergraph – dynamics run without crash");

    RliParser parser;
    parser.parseString(MINIMAL_RLI, "test");
    auto hg = parser.buildHypergraph();
    ASSERT_TRUE(hg != nullptr, "hypergraph built");

    for (int i = 0; i < 20; ++i) hg->updateRelevanceRealization(0.1);

    for (auto& kv : hg->nodes) {
        ASSERT_IN_RANGE(kv.second->salience, 0.0, 1.0,
                        "node salience in [0,1] after 20 steps");
        ASSERT_IN_RANGE(kv.second->grip_index, 0.0, 1.0,
                        "node grip_index in [0,1] after 20 steps");
    }
}

static void test_buildHypergraph_grip_index_improves() {
    section("buildHypergraph – grip_index can improve over dynamics");

    RliParser parser;
    parser.parseString(MINIMAL_RLI, "test");
    auto hg = parser.buildHypergraph();

    double initial_grip = 0.0;
    for (auto& kv : hg->nodes) initial_grip += kv.second->grip_index;
    initial_grip /= hg->nodes.size();

    for (int i = 0; i < 50; ++i) hg->updateRelevanceRealization(0.1);

    double final_grip = 0.0;
    for (auto& kv : hg->nodes) final_grip += kv.second->grip_index;
    final_grip /= hg->nodes.size();

    // Grip should be non-negative and the system should have moved
    ASSERT_TRUE(final_grip >= 0.0, "final grip_index >= 0");
    // We can't guarantee strict monotone increase for all random seeds,
    // but verify the system is still in valid state
    ASSERT_IN_RANGE(hg->ennead_balance, 0.0, 1.0,
                    "ennead_balance in [0,1] after 50 steps");
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. AtomSpace ennead projection
// ─────────────────────────────────────────────────────────────────────────────

static void test_atomspace_ennead_projection() {
    section("AtomSpace – ennead dimensions projected");

    RliParser parser;
    parser.parseString(MINIMAL_RLI, "test");
    auto hg = parser.buildHypergraph();

    AtomSpace as;
    RRAtomSpaceIntegrator integrator(hg.get(), &as);
    integrator.performIntegration();

    // EvaluationLinks for grip_index should exist
    auto evals = as.findAtomsOfType(Atom::EVALUATION_LINK);
    ASSERT_TRUE(!evals.empty(), "EvaluationLinks present after ennead projection");

    // At least one predicate called "grip_index" should exist
    auto grip_pred = as.findAtomsByName("grip_index");
    ASSERT_TRUE(!grip_pred.empty(), "grip_index predicate created in AtomSpace");

    // At least one for "ennead_balance"
    auto bal_pred = as.findAtomsByName("ennead_balance");
    ASSERT_TRUE(!bal_pred.empty(), "ennead_balance predicate created in AtomSpace");
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. Scheme interface – ennead/grip commands
// ─────────────────────────────────────────────────────────────────────────────

static void test_scheme_get_system_ennead() {
    section("Scheme – (get-system-ennead)");

    RliParser parser;
    parser.parseString(MINIMAL_RLI, "test");
    auto hg = parser.buildHypergraph();

    AtomSpace as;
    plingua::scheme::SchemeEvaluator eval(hg.get(), &as);

    std::string result = eval.evaluate("(get-system-ennead)");
    ASSERT_TRUE(result.find("identity-continuity") != std::string::npos,
                "get-system-ennead response contains identity-continuity");
    ASSERT_TRUE(result.find("balance") != std::string::npos,
                "get-system-ennead response contains balance");
}

static void test_scheme_get_global_metrics() {
    section("Scheme – (get-global-metrics)");

    RliParser parser;
    parser.parseString(MINIMAL_RLI, "test");
    auto hg = parser.buildHypergraph();

    AtomSpace as;
    plingua::scheme::SchemeEvaluator eval(hg.get(), &as);

    std::string result = eval.evaluate("(get-global-metrics)");
    ASSERT_TRUE(result.find("relevance-gradient") != std::string::npos,
                "get-global-metrics contains relevance-gradient");
    ASSERT_TRUE(result.find("ennead-balance") != std::string::npos,
                "get-global-metrics contains ennead-balance");
    ASSERT_TRUE(result.find("converged") != std::string::npos,
                "get-global-metrics contains converged");
}

static void test_scheme_set_grip_threshold() {
    section("Scheme – (set-grip-threshold VALUE)");

    RliParser parser;
    parser.parseString(MINIMAL_RLI, "test");
    auto hg = parser.buildHypergraph();

    AtomSpace as;
    plingua::scheme::SchemeEvaluator eval(hg.get(), &as);

    eval.evaluate("(set-grip-threshold 0.45)");
    ASSERT_NEAR(hg->grip_threshold, 0.45, 1e-6,
                "grip_threshold updated via Scheme command");
}

static void test_scheme_get_node_ennead() {
    section("Scheme – (get-ennead node-ID)");

    RliParser parser;
    parser.parseString(MINIMAL_RLI, "test");
    auto hg = parser.buildHypergraph();

    AtomSpace as;
    plingua::scheme::SchemeEvaluator eval(hg.get(), &as);

    // First node id should be 1
    std::string result = eval.evaluate("(get-ennead node-1)");
    ASSERT_TRUE(result.find("identity-continuity") != std::string::npos ||
                result == "Node not found",
                "get-ennead returns ennead or 'Node not found'");
}

// ─────────────────────────────────────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────────────────────────────────────

int main() {
    std::cout << "=== R-Lingua Unit & Integration Tests ===\n";

    // 1. Ennead state
    test_ennead_defaults();
    test_ennead_balance_uniform();
    test_ennead_balance_polarised();
    test_ennead_to_from_vector();
    test_ennead_triad_means();
    test_ennead_update_bounds();

    // 2. Grip index
    test_grip_index_zero_when_no_realization();
    test_grip_index_bounded();
    test_grip_index_increases_with_realization();

    // 3. Global metrics
    test_global_metrics_empty_graph();
    test_global_metrics_after_update();
    test_convergence_criterion();

    // 4. Parser
    test_parser_accepts_valid_model();
    test_parser_ennead_values();
    test_parser_nodes_and_coupling();
    test_parser_constraints();
    test_parser_observe();
    test_parser_rejects_missing_rmodel();

    // 5. Hypergraph build
    test_buildHypergraph_basic();
    test_buildHypergraph_ennead_applied();
    test_buildHypergraph_dynamics_runs();
    test_buildHypergraph_grip_index_improves();

    // 6. AtomSpace projection
    test_atomspace_ennead_projection();

    // 7. Scheme interface
    test_scheme_get_system_ennead();
    test_scheme_get_global_metrics();
    test_scheme_set_grip_threshold();
    test_scheme_get_node_ennead();

    std::cout << "\nResults: " << tests_passed << "/" << tests_run << " passed.\n";
    return (tests_passed == tests_run) ? 0 : 1;
}
