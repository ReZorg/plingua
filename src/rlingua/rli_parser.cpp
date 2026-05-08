/*
 * rli_parser.cpp
 *
 * Parser for R-Lingua (.rli) files.
 *
 * Copyright (C) 2024  P-Lingua/R-Lingua Contributors
 * Licensed under GPL-3.0
 */

#include <rlingua/rli_parser.hpp>
#include <fstream>
#include <sstream>
#include <iostream>
#include <regex>
#include <algorithm>
#include <cstdlib>

namespace plingua {
namespace rlingua {

// ─────────────────────────────────────────────────────────────────────────────
// Static utilities
// ─────────────────────────────────────────────────────────────────────────────

std::string RliParser::trim(const std::string& s) {
    size_t a = s.find_first_not_of(" \t\r\n");
    size_t b = s.find_last_not_of(" \t\r\n");
    return (a == std::string::npos) ? "" : s.substr(a, b - a + 1);
}

std::vector<std::string> RliParser::split(const std::string& s, char delim) {
    std::vector<std::string> result;
    std::istringstream iss(s);
    std::string token;
    while (std::getline(iss, token, delim)) {
        std::string t = trim(token);
        if (!t.empty()) result.push_back(t);
    }
    return result;
}

std::string RliParser::stripComments(const std::string& src) {
    std::string out;
    out.reserve(src.size());
    bool inLine = false, inBlock = false;
    for (size_t i = 0; i < src.size(); ++i) {
        if (inLine) {
            if (src[i] == '\n') { inLine = false; out += '\n'; }
            continue;
        }
        if (inBlock) {
            if (src[i] == '*' && i+1 < src.size() && src[i+1] == '/') {
                inBlock = false; ++i;
            } else if (src[i] == '\n') out += '\n';
            continue;
        }
        if (src[i] == '/' && i+1 < src.size()) {
            if (src[i+1] == '/') { inLine = true; continue; }
            if (src[i+1] == '*') { inBlock = true; ++i; continue; }
        }
        out += src[i];
    }
    return out;
}

bool RliParser::parseKeyValue(const std::string& line,
                               std::string& key, std::string& value) {
    size_t eq = line.find('=');
    if (eq == std::string::npos) return false;
    key   = trim(line.substr(0, eq));
    value = trim(line.substr(eq + 1));
    // Remove trailing semicolon
    if (!value.empty() && value.back() == ';') value.pop_back();
    value = trim(value);
    return !key.empty() && !value.empty();
}

double RliParser::parseDouble(const std::string& s, double defval) {
    try { return std::stod(s); } catch (...) { return defval; }
}

void RliParser::addError(const std::string& msg) {
    system_.errors.push_back(filename_ + ":" + std::to_string(lineNum_) + ": error: " + msg);
}

void RliParser::addWarning(const std::string& msg) {
    system_.warnings.push_back(filename_ + ":" + std::to_string(lineNum_) + ": warning: " + msg);
}

// ─────────────────────────────────────────────────────────────────────────────
// Constructor
// ─────────────────────────────────────────────────────────────────────────────

RliParser::RliParser() : lineNum_(0) {}

// ─────────────────────────────────────────────────────────────────────────────
// File / string entry points
// ─────────────────────────────────────────────────────────────────────────────

bool RliParser::parseFile(const std::string& filename) {
    std::ifstream f(filename);
    if (!f.is_open()) {
        system_.errors.push_back("Cannot open file: " + filename);
        return false;
    }
    std::ostringstream ss;
    ss << f.rdbuf();
    return parseString(ss.str(), filename);
}

bool RliParser::parseString(const std::string& source, const std::string& filename) {
    system_   = RLinguaSystem();
    filename_ = filename;

    std::string clean = stripComments(source);
    std::vector<std::string> lines;
    {
        std::istringstream iss(clean);
        std::string ln;
        while (std::getline(iss, ln)) lines.push_back(ln);
    }

    bool inMain       = false;
    int  braceDepth   = 0;

    for (size_t i = 0; i < lines.size(); ++i) {
        lineNum_ = static_cast<int>(i + 1);
        std::string ln = trim(lines[i]);
        if (ln.empty()) continue;

        // ── @rmodel declaration ──────────────────────────────────────────────
        if (ln.find("@rmodel") != std::string::npos) {
            parseModelDecl(ln);
            continue;
        }

        // ── @ennead block ────────────────────────────────────────────────────
        if (ln.find("@ennead") != std::string::npos &&
            ln.find("{") != std::string::npos) {
            parseEnneadBlock(lines, i); // advances i past the closing brace
            continue;
        }

        // ── @constraints block ───────────────────────────────────────────────
        if (ln.find("@constraints") != std::string::npos &&
            ln.find("{") != std::string::npos) {
            parseConstraintsBlock(lines, i);
            continue;
        }

        // ── @observe block ───────────────────────────────────────────────────
        if (ln.find("@observe") != std::string::npos &&
            ln.find("{") != std::string::npos) {
            parseObserveBlock(lines, i);
            continue;
        }

        // ── def main() ───────────────────────────────────────────────────────
        if (ln.find("def main") != std::string::npos) {
            inMain = true;
            braceDepth = 0;
            if (ln.find("{") != std::string::npos) braceDepth = 1;
            continue;
        }

        if (inMain) {
            for (char c : ln) {
                if (c == '{') ++braceDepth;
                else if (c == '}') --braceDepth;
            }
            if (braceDepth <= 0) { inMain = false; continue; }

            // @coupling block inside main
            if (ln.find("@coupling") != std::string::npos &&
                ln.find("{") != std::string::npos) {
                parseCouplingBlock(lines, i);
                continue;
            }

            if (parseNodeDecl(ln)) continue;
        }

        // ── top-level @coupling block ─────────────────────────────────────
        if (ln.find("@coupling") != std::string::npos &&
            ln.find("{") != std::string::npos) {
            parseCouplingBlock(lines, i);
            continue;
        }
    }

    return !system_.hasErrors();
}

// ─────────────────────────────────────────────────────────────────────────────
// Section parsers
// ─────────────────────────────────────────────────────────────────────────────

bool RliParser::parseModelDecl(const std::string& line) {
    std::regex re(R"(@rmodel\s*<\s*(\w+)\s*>)");
    std::smatch m;
    if (std::regex_search(line, m, re)) {
        system_.model_type = m[1].str();
        return true;
    }
    addError("Invalid @rmodel declaration: " + line);
    return false;
}

// Collect lines between the opening '{' and matching closing '}'.
// Handles two cases:
//   1. Same-line block:  @keyword { stmt; stmt; }  → splits inner content by ';'
//   2. Multi-line block: opening '{' is the last token on 'lines[i]', content
//      follows on subsequent lines.
// In both cases 'i' is advanced past the closing '}'.
static std::vector<std::string> collectBlock(
    const std::vector<std::string>& lines, size_t& i)
{
    std::vector<std::string> block;
    const std::string& ln0 = lines[i];
    size_t open_pos  = ln0.find('{');
    size_t close_pos = ln0.rfind('}');

    // Same-line block (no nested '{' inside the content between the braces)
    if (open_pos  != std::string::npos &&
        close_pos != std::string::npos &&
        close_pos  > open_pos) {
        std::string inner = ln0.substr(open_pos + 1, close_pos - open_pos - 1);
        bool has_nested = inner.find('{') != std::string::npos;
        if (!has_nested) {
            // Split by ';' to produce individual statements
            std::istringstream iss(inner);
            std::string stmt;
            while (std::getline(iss, stmt, ';')) {
                size_t a = stmt.find_first_not_of(" \t\r\n");
                size_t b = stmt.find_last_not_of(" \t\r\n");
                std::string t = (a == std::string::npos) ? "" : stmt.substr(a, b - a + 1);
                if (!t.empty()) block.push_back(t);
            }
            return block;  // i unchanged; caller sees no advance needed
        }
    }

    // Multi-line block
    int depth = 1;
    ++i; // skip line with opening '{'
    while (i < lines.size() && depth > 0) {
        const std::string& ln = lines[i];
        for (char c : ln) {
            if (c == '{') ++depth;
            else if (c == '}') --depth;
        }
        if (depth > 0) block.push_back(ln);
        ++i;
    }
    --i; // caller's loop will increment i once more
    return block;
}

bool RliParser::parseEnneadBlock(const std::vector<std::string>& lines, size_t& i) {
    auto block = collectBlock(lines, i);
    bool inTriad = false;
    for (const auto& ln : block) {
        std::string t = trim(ln);
        if (t.empty()) continue;

        bool isTriad = t.find("@triad_a") != std::string::npos ||
                       t.find("@triad_b") != std::string::npos ||
                       t.find("@triad_c") != std::string::npos;

        if (isTriad) {
            inTriad = true;
            // Handle inline: @triad_x { key=val; key=val; }
            size_t open  = t.find('{');
            size_t close = t.rfind('}');
            if (open != std::string::npos) {
                if (close != std::string::npos && close > open) {
                    // Inline triad — parse content between { }
                    std::string inner = t.substr(open + 1, close - open - 1);
                    std::istringstream iss(inner);
                    std::string stmt;
                    while (std::getline(iss, stmt, ';')) {
                        std::string s = trim(stmt);
                        if (!s.empty()) parseTriadLine(s, system_.ennead);
                    }
                    inTriad = false; // closed on same line
                }
                // else: multi-line triad (opening '{' without closing '}')
            }
            continue;
        }

        if (inTriad) {
            if (t == "}" || t == "};") { inTriad = false; continue; }
            parseTriadLine(t, system_.ennead);
        }
    }
    return true;
}

bool RliParser::parseTriadLine(const std::string& line, plingua::rr::EnneadState& state) {
    std::string key, val;
    if (!parseKeyValue(line, key, val)) return false;
    double v = parseDouble(val, 0.5);
    v = std::max(0.0, std::min(1.0, v));

    if (key == "identity_continuity")   { state.identity_continuity  = v; return true; }
    if (key == "skill_readiness")        { state.skill_readiness       = v; return true; }
    if (key == "motivational_valence")   { state.motivational_valence  = v; return true; }
    if (key == "constraint_clarity")     { state.constraint_clarity    = v; return true; }
    if (key == "affordance_density")     { state.affordance_density    = v; return true; }
    if (key == "feedback_latency")       { state.feedback_latency      = v; return true; }
    if (key == "coupling_strength")      { state.coupling_strength     = v; return true; }
    if (key == "reciprocal_shaping")     { state.reciprocal_shaping    = v; return true; }
    if (key == "adaptive_fit")           { state.adaptive_fit          = v; return true; }

    addWarning("Unknown ennead key: " + key);
    return false;
}

bool RliParser::parseNodeDecl(const std::string& line) {
    // @agent id=X  label="Y"  salience=Z  affordance=W;
    // @arena id=X  label="Y"  salience=Z  affordance=W;
    // @relate id=X  from=A  to=B  strength=S;
    NodeDecl::Kind kind;
    if      (line.find("@agent")  != std::string::npos) kind = NodeDecl::AGENT;
    else if (line.find("@arena")  != std::string::npos) kind = NodeDecl::ARENA;
    else if (line.find("@relate") != std::string::npos) kind = NodeDecl::RELATE;
    else return false;

    NodeDecl decl;
    decl.kind = kind;

    // Extract key=value pairs after the keyword
    size_t kw_end = line.find_first_of(" \t", line.find('@'));
    std::string rest = (kw_end != std::string::npos) ? line.substr(kw_end) : "";

    // Tokenise on whitespace, each token may be key=value or key="value"
    std::regex kv_re(R"((\w+)\s*=\s*(?:\"([^\"]*)\"|([^\s;,]+)))");
    auto begin = std::sregex_iterator(rest.begin(), rest.end(), kv_re);
    auto end   = std::sregex_iterator();

    for (auto it = begin; it != end; ++it) {
        std::string key = (*it)[1].str();
        std::string val = (*it)[2].matched ? (*it)[2].str() : (*it)[3].str();

        if (key == "id")          decl.id                  = val;
        else if (key == "label")  decl.label               = val;
        else if (key == "from")   decl.from_id             = val;
        else if (key == "to")     decl.to_id               = val;
        else if (key == "salience")    decl.salience            = parseDouble(val, 0.5);
        else if (key == "affordance")  decl.affordance_potential = parseDouble(val, 1.0);
    }

    if (decl.id.empty()) {
        addError("Node declaration missing 'id': " + line);
        return false;
    }
    if (decl.label.empty()) decl.label = decl.id;

    system_.nodes.push_back(decl);
    return true;
}

bool RliParser::parseCouplingBlock(const std::vector<std::string>& lines, size_t& i) {
    auto block = collectBlock(lines, i);
    for (const auto& ln : block) {
        std::string t = trim(ln);
        if (!t.empty()) parseCouplingLine(t);
    }
    return true;
}

bool RliParser::parseCouplingLine(const std::string& line) {
    // Patterns:
    //   from_id <-> to_id :: type  strength=S;
    //   from_id ->  to_id :: type  strength=S;
    //   from_id ~>  to_id :: type  strength=S;
    CouplingRule rule;

    // Determine direction
    if (line.find("<->") != std::string::npos) {
        rule.direction = CouplingRule::BIDIRECTIONAL;
    } else if (line.find("~>") != std::string::npos) {
        rule.direction = CouplingRule::EMERGENT_DIR;
    } else if (line.find("->") != std::string::npos) {
        rule.direction = CouplingRule::UNIDIRECTIONAL;
    } else {
        addWarning("No arrow found in coupling line: " + line);
        return false;
    }

    // Split on arrow
    std::string arrow;
    if (rule.direction == CouplingRule::BIDIRECTIONAL) arrow = "<->";
    else if (rule.direction == CouplingRule::EMERGENT_DIR) arrow = "~>";
    else arrow = "->";

    size_t arrow_pos = line.find(arrow);
    std::string lhs = trim(line.substr(0, arrow_pos));
    std::string rhs = trim(line.substr(arrow_pos + arrow.size()));

    rule.from_id = lhs;

    // Split rhs on '::'
    size_t dc = rhs.find("::");
    std::string rhs_to, rhs_props;
    if (dc != std::string::npos) {
        rhs_to    = trim(rhs.substr(0, dc));
        rhs_props = trim(rhs.substr(dc + 2));
    } else {
        rhs_to = rhs;
    }
    rule.to_id = rhs_to;

    // Parse coupling_type and strength from rhs_props
    if (!rhs_props.empty()) {
        // First token (before whitespace/semicolon) is coupling_type
        size_t ws = rhs_props.find_first_of(" \t;");
        rule.coupling_type = (ws != std::string::npos)
            ? rhs_props.substr(0, ws) : rhs_props;
        // Look for strength=X
        std::regex sr(R"(strength\s*=\s*([0-9.eE+-]+))");
        std::smatch sm;
        if (std::regex_search(rhs_props, sm, sr)) {
            rule.strength = parseDouble(sm[1].str(), 0.5);
        }
    }

    if (rule.from_id.empty() || rule.to_id.empty()) {
        addError("Coupling rule missing from/to: " + line);
        return false;
    }

    system_.coupling_rules.push_back(rule);
    return true;
}

bool RliParser::parseConstraintsBlock(const std::vector<std::string>& lines, size_t& i) {
    auto block = collectBlock(lines, i);
    for (const auto& ln : block) {
        std::string t = trim(ln);
        if (!t.empty()) parseConstraintLine(t);
    }
    return true;
}

bool RliParser::parseConstraintLine(const std::string& line) {
    std::string key, val;
    if (!parseKeyValue(line, key, val)) return false;
    double v = parseDouble(val, 0.0);

    auto& c = system_.constraints;
    if (key == "salience_threshold")    { c.salience_threshold    = v; return true; }
    if (key == "affordance_decay")      { c.affordance_decay      = v; return true; }
    if (key == "grip_threshold")        { c.grip_threshold        = v; return true; }
    if (key == "convergence_window")    { c.convergence_window    = v; return true; }
    if (key == "emergence_sensitivity") { c.emergence_sensitivity = v; return true; }

    addWarning("Unknown constraint key: " + key);
    return false;
}

bool RliParser::parseObserveBlock(const std::vector<std::string>& lines, size_t& i) {
    auto block = collectBlock(lines, i);
    for (const auto& ln : block) {
        std::string t = trim(ln);
        if (!t.empty()) parseObserveLine(t);
    }
    return true;
}

bool RliParser::parseObserveLine(const std::string& line) {
    std::string key, val;
    if (!parseKeyValue(line, key, val)) return false;

    auto& o = system_.observe;
    if (key == "sample_period") {
        o.sample_period = static_cast<int>(parseDouble(val, 10.0));
        return true;
    }
    if (key == "report_fields") {
        o.report_fields = split(val, ',');
        return true;
    }
    addWarning("Unknown observe key: " + key);
    return false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Hypergraph builder
// ─────────────────────────────────────────────────────────────────────────────

std::shared_ptr<plingua::rr::RRHypergraph> RliParser::buildHypergraph() const {
    if (system_.hasErrors()) return nullptr;

    auto hg = std::make_shared<plingua::rr::RRHypergraph>();

    // Apply system ennead
    hg->system_ennead = system_.ennead;

    // Apply constraint parameters
    hg->salience_threshold    = system_.constraints.salience_threshold;
    hg->affordance_decay      = system_.constraints.affordance_decay;
    hg->grip_threshold        = system_.constraints.grip_threshold;
    hg->convergence_window_size = system_.constraints.convergence_window;
    hg->emergence_sensitivity = system_.constraints.emergence_sensitivity;

    // Map node id strings → hypergraph node ids
    std::map<std::string, unsigned> id_map;

    unsigned membrane_counter = 1;
    for (const auto& decl : system_.nodes) {
        unsigned node_id = 0;
        plingua::rr::AARType aar;

        if (decl.kind == NodeDecl::AGENT) {
            aar = plingua::rr::AARType::AGENT;
            node_id = hg->addMembraneNode(membrane_counter++, decl.label, aar);
        } else if (decl.kind == NodeDecl::ARENA) {
            aar = plingua::rr::AARType::ARENA;
            node_id = hg->addMembraneNode(membrane_counter++, decl.label, aar);
        } else {
            // RELATE nodes are added after AGENT/ARENA nodes are resolved
            continue;
        }

        // Set initial properties
        auto& n = *hg->nodes[node_id];
        n.salience             = std::max(0.0, std::min(1.0, decl.salience));
        n.affordance_potential = std::max(1e-6, decl.affordance_potential);
        n.affordance_realization = n.affordance_potential * 0.3;

        id_map[decl.id] = node_id;
    }

    // Add RELATE nodes (need from/to resolved first)
    for (const auto& decl : system_.nodes) {
        if (decl.kind != NodeDecl::RELATE) continue;
        if (id_map.find(decl.from_id) == id_map.end() ||
            id_map.find(decl.to_id)   == id_map.end()) continue;

        auto node_id = hg->addObjectNode(decl.label, plingua::rr::AARType::RELATION);
        hg->nodes[node_id]->salience = std::max(0.0, std::min(1.0, decl.salience));
        id_map[decl.id] = node_id;
    }

    // Apply coupling rules
    for (const auto& rule : system_.coupling_rules) {
        if (id_map.find(rule.from_id) == id_map.end() ||
            id_map.find(rule.to_id)   == id_map.end()) continue;

        unsigned from_nid = id_map[rule.from_id];
        unsigned to_nid   = id_map[rule.to_id];

        plingua::rr::RREdge::Type edge_type;
        if (rule.coupling_type == "co_constitution")
            edge_type = plingua::rr::RREdge::CO_CONSTRUCTION;
        else if (rule.coupling_type == "emergent")
            edge_type = plingua::rr::RREdge::EMERGENT;
        else if (rule.coupling_type == "application")
            edge_type = plingua::rr::RREdge::APPLICATION;
        else
            edge_type = plingua::rr::RREdge::INTERACTION;

        double s = std::max(0.0, std::min(1.0, rule.strength));

        hg->addRelationEdge(from_nid, to_nid, edge_type, s);
        if (rule.direction == CouplingRule::BIDIRECTIONAL) {
            hg->addRelationEdge(to_nid, from_nid, edge_type, s);
        }
    }

    // Run initial metrics update
    hg->updateGlobalMetrics();

    return hg;
}

} // namespace rlingua
} // namespace plingua
