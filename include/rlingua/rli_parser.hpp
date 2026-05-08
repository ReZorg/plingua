#ifndef _RLI_PARSER_HPP_
#define _RLI_PARSER_HPP_

/*
 * rli_parser.hpp
 *
 * Parser for R-Lingua (.rli) files — Relevance Realization DSL extension.
 * Reads .rli source and produces an RLinguaSystem structure that can be
 * used to initialise an RRHypergraph with ennead state and constraints.
 *
 * Copyright (C) 2024  P-Lingua/R-Lingua Contributors
 * Licensed under GPL-3.0
 */

#include <string>
#include <vector>
#include <map>
#include <set>
#include <relevance_realization.hpp>

namespace plingua {
namespace rlingua {

// ─────────────────────────────────────────────────────────────────────────────
// Data structures produced by the parser
// ─────────────────────────────────────────────────────────────────────────────

// A declared node (@agent / @arena / @relate)
struct NodeDecl {
    enum Kind { AGENT, ARENA, RELATE };

    std::string id;          // unique identifier used in coupling rules
    std::string label;       // human-readable label
    Kind        kind;        // AGENT, ARENA, or RELATE

    // For RELATE nodes only
    std::string from_id;     // source node id
    std::string to_id;       // target node id

    double salience;             // initial salience       ∈ [0,1]
    double affordance_potential; // initial affordance potential > 0

    NodeDecl()
        : kind(AGENT), salience(0.5), affordance_potential(1.0) {}
};

// A coupling rule
struct CouplingRule {
    enum Direction { BIDIRECTIONAL, UNIDIRECTIONAL, EMERGENT_DIR };

    std::string   from_id;     // source node id
    std::string   to_id;       // target node id
    Direction     direction;   // <->, ->, or ~>
    std::string   coupling_type; // co_constitution, application, emergent
    double        strength;    // edge weight ∈ [0,1]

    CouplingRule()
        : direction(BIDIRECTIONAL), coupling_type("co_constitution"), strength(0.5) {}
};

// R-Lingua constraint parameters (@constraints block)
struct RLinguaConstraints {
    double salience_threshold;
    double affordance_decay;
    double grip_threshold;
    double convergence_window;
    double emergence_sensitivity;

    RLinguaConstraints()
        : salience_threshold(0.05), affordance_decay(0.0),
          grip_threshold(0.3), convergence_window(50.0),
          emergence_sensitivity(0.7) {}
};

// Observability / reporting block (@observe)
struct RLinguaObserve {
    int sample_period;
    std::vector<std::string> report_fields;

    RLinguaObserve() : sample_period(10) {}
};

// Top-level parsed R-Lingua system
struct RLinguaSystem {
    std::string   model_type;       // e.g. "relevance_realization"

    plingua::rr::EnneadState ennead; // initial system ennead

    std::vector<NodeDecl>    nodes;          // @agent / @arena / @relate declarations
    std::vector<CouplingRule> coupling_rules; // @coupling block entries

    RLinguaConstraints constraints;
    RLinguaObserve     observe;

    std::vector<std::string> errors;
    std::vector<std::string> warnings;

    bool hasErrors() const { return !errors.empty(); }
};

// ─────────────────────────────────────────────────────────────────────────────
// Parser class
// ─────────────────────────────────────────────────────────────────────────────
class RliParser {
public:
    RliParser();

    // Parse a .rli file; returns true on success (no errors).
    bool parseFile(const std::string& filename);

    // Parse R-Lingua source from a string; filename is used for error messages.
    bool parseString(const std::string& source,
                     const std::string& filename = "<string>");

    const RLinguaSystem& system() const { return system_; }

    // Convenience: build and return a fully initialised RRHypergraph from the
    // parsed system.  Returns nullptr if there are parse errors.
    std::shared_ptr<plingua::rr::RRHypergraph> buildHypergraph() const;

private:
    RLinguaSystem system_;
    std::string   filename_;
    int           lineNum_;

    // Section-level parsers
    bool parseModelDecl(const std::string& line);

    // @ennead block
    bool parseEnneadBlock(const std::vector<std::string>& lines, size_t& i);
    bool parseTriadLine(const std::string& line, plingua::rr::EnneadState& state);

    // def main() node declarations
    bool parseNodeDecl(const std::string& line);

    // @coupling block
    bool parseCouplingBlock(const std::vector<std::string>& lines, size_t& i);
    bool parseCouplingLine(const std::string& line);

    // @constraints block
    bool parseConstraintsBlock(const std::vector<std::string>& lines, size_t& i);
    bool parseConstraintLine(const std::string& line);

    // @observe block
    bool parseObserveBlock(const std::vector<std::string>& lines, size_t& i);
    bool parseObserveLine(const std::string& line);

    // Utilities
    static std::string trim(const std::string& s);
    static std::vector<std::string> split(const std::string& s, char delim);
    static std::string stripComments(const std::string& src);
    static bool parseKeyValue(const std::string& line,
                              std::string& key, std::string& value);
    static double parseDouble(const std::string& s, double defval = 0.0);

    void addError(const std::string& msg);
    void addWarning(const std::string& msg);
};

} // namespace rlingua
} // namespace plingua

#endif // _RLI_PARSER_HPP_
