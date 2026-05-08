/*
 * rlingua_main.cpp
 *
 * Main entry point for the R-Lingua compiler (rlingua).
 * Reads .rli files, builds an RR hypergraph, optionally runs RR dynamics,
 * and outputs a JSON grip report.
 *
 * Usage:
 *   rlingua input.rli [-o output.json] [-s steps] [-v]
 *
 * Copyright (C) 2024  P-Lingua/R-Lingua Contributors
 * Licensed under GPL-3.0
 */

#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <iomanip>
#include <rlingua/rli_parser.hpp>

static void printUsage(const char* prog) {
    std::cerr
        << "R-Lingua Compiler — Relevance Realization DSL\n"
        << "Usage: " << prog << " <input.rli> [options]\n"
        << "\nOptions:\n"
        << "  -o <file>    Output JSON file (default: stdout)\n"
        << "  -s <steps>   Run RR dynamics for N steps (default: 0)\n"
        << "  -v           Verbose output\n"
        << "  -h           Show this help\n"
        << "\nExample:\n"
        << "  " << prog << " minimal_ennead.rli -o report.json -s 100\n";
}

// Emit a JSON grip report for the hypergraph
static std::string generateGripReport(
    const plingua::rr::RRHypergraph& hg, int steps_run)
{
    std::ostringstream j;
    j << std::fixed << std::setprecision(6);
    j << "{\n";
    j << "  \"steps_run\": " << steps_run << ",\n";
    j << "  \"converged\": " << (hg.hasConverged() ? "true" : "false") << ",\n";
    j << "  \"system_metrics\": {\n";
    j << "    \"relevance_gradient\": " << hg.relevance_gradient << ",\n";
    j << "    \"ennead_balance\": "     << hg.ennead_balance      << ",\n";
    j << "    \"grip_stability\": "     << hg.grip_stability      << ",\n";
    j << "    \"emergence_score\": "    << hg.emergence_score     << "\n";
    j << "  },\n";

    // System ennead
    j << "  \"system_ennead\": {\n";
    const auto& e = hg.system_ennead;
    j << "    \"identity_continuity\": "  << e.identity_continuity  << ",\n";
    j << "    \"skill_readiness\": "       << e.skill_readiness       << ",\n";
    j << "    \"motivational_valence\": "  << e.motivational_valence  << ",\n";
    j << "    \"constraint_clarity\": "    << e.constraint_clarity    << ",\n";
    j << "    \"affordance_density\": "    << e.affordance_density    << ",\n";
    j << "    \"feedback_latency\": "      << e.feedback_latency      << ",\n";
    j << "    \"coupling_strength\": "     << e.coupling_strength     << ",\n";
    j << "    \"reciprocal_shaping\": "    << e.reciprocal_shaping    << ",\n";
    j << "    \"adaptive_fit\": "          << e.adaptive_fit          << ",\n";
    j << "    \"balance\": "               << e.balance()             << "\n";
    j << "  },\n";

    // Per-node metrics
    j << "  \"nodes\": [\n";
    bool first = true;
    for (auto& kv : hg.nodes) {
        if (!first) j << ",\n";
        first = false;
        const auto& n = *kv.second;
        j << "    {\n";
        j << "      \"id\": "                        << n.id                           << ",\n";
        j << "      \"label\": \""                   << n.label                        << "\",\n";
        j << "      \"salience\": "                  << n.salience                     << ",\n";
        j << "      \"affordance_potential\": "      << n.affordance_potential         << ",\n";
        j << "      \"affordance_realization\": "    << n.affordance_realization       << ",\n";
        j << "      \"coherence\": "                 << n.coherence                    << ",\n";
        j << "      \"grip_index\": "                << n.grip_index                   << ",\n";
        j << "      \"ennead_balance\": "            << n.ennead.balance()             << "\n";
        j << "    }";
    }
    j << "\n  ]\n";
    j << "}\n";
    return j.str();
}

int main(int argc, char* argv[]) {
    if (argc < 2) { printUsage(argv[0]); return 1; }

    std::string inputFile;
    std::string outputFile;
    int   steps   = 0;
    bool  verbose = false;

    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            printUsage(argv[0]); return 0;
        } else if (strcmp(argv[i], "-o") == 0 && i+1 < argc) {
            outputFile = argv[++i];
        } else if (strcmp(argv[i], "-s") == 0 && i+1 < argc) {
            steps = std::atoi(argv[++i]);
        } else if (strcmp(argv[i], "-v") == 0) {
            verbose = true;
        } else if (argv[i][0] != '-') {
            inputFile = argv[i];
        } else {
            std::cerr << "Unknown option: " << argv[i] << "\n";
            return 1;
        }
    }

    if (inputFile.empty()) {
        std::cerr << "Error: no input file specified\n";
        printUsage(argv[0]);
        return 1;
    }

    // Parse
    plingua::rlingua::RliParser parser;
    if (!parser.parseFile(inputFile)) {
        std::cerr << "Parse errors in " << inputFile << ":\n";
        for (const auto& err : parser.system().errors)
            std::cerr << "  " << err << "\n";
        return 1;
    }

    for (const auto& w : parser.system().warnings)
        std::cerr << "  " << w << "\n";

    // Build hypergraph
    auto hg = parser.buildHypergraph();
    if (!hg) {
        std::cerr << "Failed to build hypergraph\n";
        return 1;
    }

    if (verbose) {
        const auto& sys = parser.system();
        std::cerr << "R-Lingua compilation successful:\n"
                  << "  Model type:    " << sys.model_type          << "\n"
                  << "  Nodes:         " << hg->nodes.size()        << "\n"
                  << "  Edges:         " << hg->edges.size()        << "\n"
                  << "  Ennead balance:" << hg->system_ennead.balance() << "\n";
    }

    // Run dynamics
    const int sample = parser.system().observe.sample_period > 0
                       ? parser.system().observe.sample_period : 10;

    for (int step = 0; step < steps; ++step) {
        hg->updateRelevanceRealization(0.1);

        if (verbose && (step + 1) % sample == 0) {
            std::cerr << "  step " << (step+1)
                      << " | grip_stability=" << std::fixed << std::setprecision(4) << hg->grip_stability
                      << " | ennead_balance=" << hg->ennead_balance
                      << " | emergence="      << hg->emergence_score
                      << (hg->hasConverged() ? " [CONVERGED]" : "") << "\n";
        }

        if (hg->hasConverged()) {
            if (verbose)
                std::cerr << "  Converged at step " << (step+1) << "\n";
            steps = step + 1;
            break;
        }
    }

    // Generate output
    std::string report = generateGripReport(*hg, steps);

    if (outputFile.empty()) {
        std::cout << report;
    } else {
        std::ofstream ofs(outputFile);
        if (!ofs.is_open()) {
            std::cerr << "Cannot open output file: " << outputFile << "\n";
            return 1;
        }
        ofs << report;
        if (verbose)
            std::cerr << "Report written to " << outputFile << "\n";
    }

    return 0;
}
