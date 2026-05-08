/*
 * mli_parser.cpp:
 *
 * Parser for M-Lingua (.mli) files — morphogenetic system extensions
 * to P-Lingua. Reads .mli source and produces an MSystem structure.
 *
 * Copyright (C) 2024  P-Lingua/M-Lingua Contributors
 * Licensed under GPL-3.0
 */

#include <msystem/mli_parser.hpp>
#include <fstream>
#include <sstream>
#include <iostream>
#include <regex>
#include <algorithm>
#include <cmath>
#include <stdexcept>
#include <cctype>

namespace plingua {
namespace msystem {

static std::string trim(const std::string& s) {
	size_t start = s.find_first_not_of(" \t\r\n");
	size_t end = s.find_last_not_of(" \t\r\n");
	if (start == std::string::npos) return "";
	return s.substr(start, end - start + 1);
}

static std::vector<std::string> split(const std::string& s, char delim) {
	std::vector<std::string> result;
	std::stringstream ss(s);
	std::string item;
	while (std::getline(ss, item, delim)) {
		std::string trimmed = trim(item);
		if (!trimmed.empty()) result.push_back(trimmed);
	}
	return result;
}

static std::string toLower(const std::string& s) {
	std::string out = s;
	for (size_t i = 0; i < out.size(); ++i) {
		out[i] = static_cast<char>(std::tolower(static_cast<unsigned char>(out[i])));
	}
	return out;
}

static bool parseBoolLiteral(const std::string& s, bool& value) {
	std::string lit = toLower(trim(s));
	if (lit == "true") {
		value = true;
		return true;
	}
	if (lit == "false") {
		value = false;
		return true;
	}
	return false;
}

static std::string stripQuotes(const std::string& s) {
	std::string t = trim(s);
	if (t.size() >= 2) {
		char first = t.front();
		char last = t.back();
		if ((first == '"' && last == '"') || (first == '\'' && last == '\'')) {
			return t.substr(1, t.size() - 2);
		}
	}
	return t;
}

static std::map<std::string, std::string> parseArgumentMap(const std::string& args) {
	std::map<std::string, std::string> out;
	auto parts = split(args, ',');
	for (size_t i = 0; i < parts.size(); ++i) {
		const std::string token = trim(parts[i]);
		size_t eq = token.find('=');
		if (eq == std::string::npos) continue;
		std::string key = toLower(trim(token.substr(0, eq)));
		std::string value = stripQuotes(token.substr(eq + 1));
		if (!key.empty()) out[key] = value;
	}
	return out;
}

static bool tryParseIntValue(const std::string& text, int& value) {
	try {
		size_t idx = 0;
		int parsed = std::stoi(text, &idx);
		if (idx != text.size()) return false;
		value = parsed;
		return true;
	} catch (...) {
		return false;
	}
}

static bool tryParseUIntValue(const std::string& text, size_t& value) {
	try {
		size_t idx = 0;
		unsigned long parsed = std::stoul(text, &idx);
		if (idx != text.size()) return false;
		value = static_cast<size_t>(parsed);
		return true;
	} catch (...) {
		return false;
	}
}

static bool tryParseDoubleValue(const std::string& text, double& value) {
	try {
		size_t idx = 0;
		double parsed = std::stod(text, &idx);
		if (idx != text.size()) return false;
		value = parsed;
		return true;
	} catch (...) {
		return false;
	}
}

static bool getIntArg(const std::map<std::string, std::string>& args, const std::string& key, int& value, std::string* error = 0) {
	std::map<std::string, std::string>::const_iterator it = args.find(key);
	if (it == args.end()) {
		if (error) *error = "missing required integer argument '" + key + "'";
		return false;
	}
	if (!tryParseIntValue(it->second, value)) {
		if (error) *error = "invalid integer value for '" + key + "': " + it->second;
		return false;
	}
	return true;
}

static bool getUIntArg(const std::map<std::string, std::string>& args, const std::string& key, size_t& value, std::string* error = 0) {
	std::map<std::string, std::string>::const_iterator it = args.find(key);
	if (it == args.end()) {
		if (error) *error = "missing required unsigned argument '" + key + "'";
		return false;
	}
	if (!tryParseUIntValue(it->second, value)) {
		if (error) *error = "invalid unsigned value for '" + key + "': " + it->second;
		return false;
	}
	return true;
}

static bool getDoubleArg(const std::map<std::string, std::string>& args, const std::string& key, double& value, std::string* error = 0) {
	std::map<std::string, std::string>::const_iterator it = args.find(key);
	if (it == args.end()) {
		if (error) *error = "missing required floating argument '" + key + "'";
		return false;
	}
	if (!tryParseDoubleValue(it->second, value)) {
		if (error) *error = "invalid floating-point value for '" + key + "': " + it->second;
		return false;
	}
	return true;
}

static bool getBoolArg(const std::map<std::string, std::string>& args, const std::string& key, bool& value) {
	std::map<std::string, std::string>::const_iterator it = args.find(key);
	if (it == args.end()) return false;
	return parseBoolLiteral(it->second, value);
}

static std::string stripComments(const std::string& src) {
	std::string result;
	result.reserve(src.size());
	bool inLineComment = false;
	bool inBlockComment = false;
	for (size_t i = 0; i < src.size(); i++) {
		if (inLineComment) {
			if (src[i] == '\n') { inLineComment = false; result += '\n'; }
			continue;
		}
		if (inBlockComment) {
			if (src[i] == '*' && i+1 < src.size() && src[i+1] == '/') {
				inBlockComment = false; i++;
			}
			continue;
		}
		if (src[i] == '/' && i+1 < src.size()) {
			if (src[i+1] == '/') { inLineComment = true; continue; }
			if (src[i+1] == '*') { inBlockComment = true; i++; continue; }
		}
		result += src[i];
	}
	return result;
}

MliParser::MliParser() {}

bool MliParser::parseFile(const std::string& filename) {
	std::ifstream file(filename);
	if (!file.is_open()) {
		errors_.push_back("Cannot open file: " + filename);
		return false;
	}
	std::stringstream ss;
	ss << file.rdbuf();
	return parseString(ss.str(), filename);
}

bool MliParser::parseString(const std::string& source, const std::string& filename) {
	errors_.clear();
	system_ = MSystem();
	filename_ = filename;

	std::string clean = stripComments(source);
	std::vector<std::string> lines;
	std::istringstream iss(clean);
	std::string line;
	while (std::getline(iss, line)) {
		lines.push_back(line);
	}

	lineNum_ = 0;
	bool inTiling = false;
	bool inTile = false;
	bool inMain = false;
	int braceDepth = 0;
	std::string currentTileName;
	Tile currentTile;

	for (size_t i = 0; i < lines.size(); i++) {
		lineNum_ = i + 1;
		std::string ln = trim(lines[i]);
		if (ln.empty()) continue;

		if (parseModelDecl(ln)) continue;
		if (parseGeometryProfile(ln)) continue;
		if (parseManifold(ln)) continue;
		if (parseMetric(ln)) continue;
		if (parseConnection(ln)) continue;
		if (parseCapability(ln)) continue;
		if (parseFlow(ln)) continue;
		if (parsePolytope(ln)) continue;
		if (parseTilingStart(ln)) { inTiling = true; braceDepth = 1; continue; }

		if (inTiling) {
			for (char c : ln) {
				if (c == '{') braceDepth++;
				else if (c == '}') braceDepth--;
			}

			if (parseTileStart(ln, currentTile)) {
				inTile = true;
				continue;
			}
			if (inTile) {
				if (parseConnector(ln, currentTile)) continue;
				if (parseSurfaceGlue(ln, currentTile)) continue;
				if (parseColor(ln, currentTile)) continue;
				if (parseProtion(ln, currentTile)) continue;
				if (ln.find("}") != std::string::npos && braceDepth <= 2) {
					system_.tiling.tiles.push_back(currentTile);
					inTile = false;
					currentTile = Tile();
					continue;
				}
				continue;
			}
			if (parseGlue(ln)) continue;
			if (parseGlueRelation(ln)) continue;
			if (parseGlueRadius(ln)) continue;
			if (parseSeed(ln)) continue;
			if (parseRod(ln)) continue;

			if (braceDepth <= 0) {
				inTiling = false;
				continue;
			}
			continue;
		}

		if (parseFloating(ln)) continue;
		if (parseProtionDecl(ln)) continue;
		if (parseProtionOnTile(ln)) continue;
		if (parseSigma(ln)) continue;
		if (parseReactionDistance(ln)) continue;

		if (ln.find("def main") != std::string::npos) {
			inMain = true;
			continue;
		}
		if (inMain) {
			if (parseCreateRule(ln)) continue;
			if (parseDestroyRule(ln)) continue;
			if (parseDivideRule(ln)) continue;
			if (parseMetabolicRule(ln)) continue;
			if (ln == "}") { inMain = false; continue; }
		}
	}

	return errors_.empty();
}

bool MliParser::parseModelDecl(const std::string& line) {
	std::regex re(R"(@msystem\s*<\s*(\w+)\s*>)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		system_.modelType = m[1].str();
		return true;
	}
	return false;
}

bool MliParser::parseGeometryProfile(const std::string& line) {
	std::regex re(R"(@geometry\s*<\s*([A-Za-z_][A-Za-z0-9_\-]*)\s*>\s*;)");
	std::smatch m;
	if (!std::regex_search(line, m, re)) return false;

	std::string raw = m[1].str();
	std::string profile = toLower(raw);
	system_.geometryProfileLabel = profile;

	if (profile == "euclidean" || profile == "affine") {
		system_.geometryProfile = GeometryProfile::EUCLIDEAN;
	} else if (profile == "projective" || profile == "spherical") {
		system_.geometryProfile = GeometryProfile::PROJECTIVE;
	} else if (profile == "hyperbolic" || profile == "non_euclidean" || profile == "non-euclidean") {
		system_.geometryProfile = GeometryProfile::HYPERBOLIC;
	} else {
		system_.geometryProfile = GeometryProfile::CUSTOM;
		system_.geometryProfileLabel = raw;
	}
	return true;
}

bool MliParser::parseManifold(const std::string& line) {
	std::regex re(R"(@manifold\s+(\w+)\s*\(\s*([^\)]*)\)\s*;)");
	std::smatch m;
	if (!std::regex_search(line, m, re)) return false;

	std::map<std::string, std::string> args = parseArgumentMap(m[2].str());
	ManifoldSpec manifold;
	manifold.name = m[1].str();
	std::string error;
	if (!getIntArg(args, "charts", manifold.charts, &error)) {
		errors_.push_back("line " + std::to_string(lineNum_) + " @manifold " + manifold.name + ": " + error);
		return false;
	}
	if (!getIntArg(args, "dimension", manifold.dimension, &error)) {
		errors_.push_back("line " + std::to_string(lineNum_) + " @manifold " + manifold.name + ": " + error);
		return false;
	}
	if (!getBoolArg(args, "compact", manifold.compact)) {
		errors_.push_back("line " + std::to_string(lineNum_) + " @manifold " + manifold.name + ": missing or invalid boolean argument 'compact'");
		return false;
	}
	if (args.count("boundary") && !getBoolArg(args, "boundary", manifold.boundary)) {
		errors_.push_back("line " + std::to_string(lineNum_) + " @manifold " + manifold.name + ": invalid boolean argument 'boundary'");
		return false;
	}
	system_.manifolds.push_back(manifold);
	return true;
}

bool MliParser::parseMetric(const std::string& line) {
	std::regex re(R"(@metric\s+(\w+)\s*\(\s*([^\)]*)\)\s*;)");
	std::smatch m;
	if (!std::regex_search(line, m, re)) return false;

	std::map<std::string, std::string> args = parseArgumentMap(m[2].str());
	MetricSpec metric;
	metric.name = m[1].str();
	std::map<std::string, std::string>::const_iterator typeIt = args.find("type");
	if (typeIt != args.end()) metric.type = typeIt->second;
	std::map<std::string, std::string>::const_iterator sigIt = args.find("signature");
	if (sigIt != args.end()) metric.signature = sigIt->second;
	system_.metrics.push_back(metric);
	return true;
}

bool MliParser::parseConnection(const std::string& line) {
	std::regex re(R"(@connection\s+(\w+)\s*\(\s*([^\)]*)\)\s*;)");
	std::smatch m;
	if (!std::regex_search(line, m, re)) return false;

	std::map<std::string, std::string> args = parseArgumentMap(m[2].str());
	ConnectionSpec connection;
	connection.name = m[1].str();
	std::map<std::string, std::string>::const_iterator typeIt = args.find("type");
	if (typeIt != args.end()) connection.type = typeIt->second;
	std::map<std::string, std::string>::const_iterator bundleIt = args.find("bundle");
	if (bundleIt != args.end()) connection.bundle = bundleIt->second;
	system_.connections.push_back(connection);
	return true;
}

bool MliParser::parseCapability(const std::string& line) {
	std::regex re(R"(@capability\s+([A-Za-z_][A-Za-z0-9_\-]*)\s*;)");
	std::smatch m;
	if (!std::regex_search(line, m, re)) return false;
	system_.capabilities.push_back(m[1].str());
	return true;
}

bool MliParser::parseFlow(const std::string& line) {
	std::regex re(R"(@flow\s+(\w+)\s*\(\s*([^\)]*)\)\s*;)");
	std::smatch m;
	if (!std::regex_search(line, m, re)) return false;

	std::map<std::string, std::string> args = parseArgumentMap(m[2].str());
	FlowSpec flow;
	flow.name = m[1].str();
	std::map<std::string, std::string>::const_iterator typeIt = args.find("type");
	if (typeIt != args.end()) flow.type = typeIt->second;
	std::string error;
	if (!getDoubleArg(args, "step", flow.step, &error)) {
		errors_.push_back("line " + std::to_string(lineNum_) + " @flow " + flow.name + ": " + error);
		return false;
	}
	if (!getIntArg(args, "iterations", flow.iterations, &error)) {
		errors_.push_back("line " + std::to_string(lineNum_) + " @flow " + flow.name + ": " + error);
		return false;
	}
	if (args.count("preserve_volume") && !getBoolArg(args, "preserve_volume", flow.preserveVolume)) {
		errors_.push_back("line " + std::to_string(lineNum_) + " @flow " + flow.name + ": invalid boolean argument 'preserve_volume'");
		return false;
	}
	system_.flows.push_back(flow);
	return true;
}

bool MliParser::parsePolytope(const std::string& line) {
	std::regex re(R"(@polytope\s+(\w+)\s*\(\s*([^\)]*)\)\s*;)");
	std::smatch m;
	if (!std::regex_search(line, m, re)) return false;

	std::map<std::string, std::string> args = parseArgumentMap(m[2].str());
	PolytopeSpec poly;
	poly.name = m[1].str();
	std::string error;
	if (!getIntArg(args, "dimension", poly.dimension, &error)) {
		errors_.push_back("line " + std::to_string(lineNum_) + " @polytope " + poly.name + ": " + error);
		return false;
	}
	if (!getUIntArg(args, "vertices", poly.incidenceCounts["vertices"], &error)) {
		errors_.push_back("line " + std::to_string(lineNum_) + " @polytope " + poly.name + ": " + error);
		return false;
	}
	if (!getUIntArg(args, "edges", poly.incidenceCounts["edges"], &error)) {
		errors_.push_back("line " + std::to_string(lineNum_) + " @polytope " + poly.name + ": " + error);
		return false;
	}
	if (!getUIntArg(args, "faces", poly.incidenceCounts["faces"], &error)) {
		errors_.push_back("line " + std::to_string(lineNum_) + " @polytope " + poly.name + ": " + error);
		return false;
	}
	if (!getUIntArg(args, "cells", poly.incidenceCounts["cells"], &error)) {
		errors_.push_back("line " + std::to_string(lineNum_) + " @polytope " + poly.name + ": " + error);
		return false;
	}
	std::map<std::string, std::string>::const_iterator symmetryIt = args.find("symmetry");
	if (symmetryIt != args.end()) poly.symmetryGroup = symmetryIt->second;
	system_.polytopes.push_back(poly);
	return true;
}

bool MliParser::parseTilingStart(const std::string& line) {
	return line.find("@tiling") != std::string::npos &&
	       line.find("{") != std::string::npos;
}

bool MliParser::parseTileStart(const std::string& line, Tile& tile) {
	std::regex re(R"(@tile\s+(\w+)\s*\(\s*sides\s*=\s*(\d+)\s*,\s*radius\s*=\s*([0-9.eE+-]+)\s*(?:,\s*dimension\s*=\s*(\d+))?\s*\))");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		tile = Tile();
		tile.name = m[1].str();
		tile.sides = std::stoi(m[2].str());
		tile.radius = std::stod(m[3].str());
		if (m[4].matched) tile.dimension = std::stoi(m[4].str());

		auto verts = tile.computeVertices();
		for (size_t vi = 0; vi < verts.size(); vi++) {
			tile.positions.push_back({"v" + std::to_string(vi+1), verts[vi]});
		}
		tile.positions.push_back({"center", {0, 0, 0}});
		return true;
	}

	std::regex reRod(R"(@rod\s+(\w+)\s*\(\s*length\s*=\s*([0-9.eE+-]+)\s*\))");
	if (std::regex_search(line, m, reRod)) {
		Rod rod;
		rod.name = m[1].str();
		rod.length = std::stod(m[2].str());
		system_.tiling.rods.push_back(rod);
		return true;
	}
	return false;
}

bool MliParser::parseConnector(const std::string& line, Tile& tile) {
	std::regex re(R"(@connector\s+(\w+)\s*\(\s*vertices\s*=\s*\[([^\]]*)\]\s*,\s*glue\s*=\s*(\w+)\s*(?:,\s*angle\s*=\s*([0-9.eE+-]+))?\s*\))");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		Connector conn;
		conn.name = m[1].str();
		conn.vertexNames = split(m[2].str(), ',');
		conn.glueName = m[3].str();
		if (m[4].matched) {
			double angle = std::stod(m[4].str());
			conn.angles = Angles(angle * M_PI / 180.0, 0);
		} else {
			conn.angles = Angles(tile.connectingAngle, 0);
		}
		tile.connectors.push_back(conn);
		return true;
	}
	return false;
}

bool MliParser::parseSurfaceGlue(const std::string& line, Tile& tile) {
	std::regex re(R"(@surface_glue\s+(\w+))");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		tile.surfaceGlue = m[1].str();
		return true;
	}
	return false;
}

bool MliParser::parseColor(const std::string& line, Tile& tile) {
	std::regex re(R"(@color\s+(\w+)(?:\s+alpha\s*=\s*(\d+))?)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		tile.color.name = m[1].str();
		if (m[2].matched) tile.color.alpha = std::stoi(m[2].str());
		return true;
	}
	return false;
}

bool MliParser::parseProtion(const std::string& line, Tile& tile) {
	std::regex re(R"(@protion\s+(\w+)\s+at\s*\(\s*([0-9.eE+-]+)\s*,\s*([0-9.eE+-]+)\s*\))");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		ProtionOnTile pot;
		pot.protionName = m[1].str();
		pot.tileName = tile.name;
		pot.position = Point3D(std::stod(m[2].str()), std::stod(m[3].str()), 0);
		system_.protionsOnTiles.push_back(pot);
		return true;
	}
	return false;
}

bool MliParser::parseGlue(const std::string& line) {
	std::regex re(R"(@glue\s+(\w+)\s*;)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		system_.tiling.glues.push_back(Glue(m[1].str()));
		return true;
	}
	return false;
}

bool MliParser::parseGlueRelation(const std::string& line) {
	std::regex re(R"(@glue_relation\s*\(\s*(\w+)\s*,\s*(\w+)\s*\)\s*;)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		system_.tiling.glueRelations.push_back(GlueRelation(m[1].str(), m[2].str()));
		return true;
	}
	return false;
}

bool MliParser::parseGlueRadius(const std::string& line) {
	std::regex re(R"(@glue_radius\s+([0-9.eE+-]+)\s*;)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		system_.tiling.glueRadius = std::stod(m[1].str());
		return true;
	}
	return false;
}

bool MliParser::parseSeed(const std::string& line) {
	std::regex re(R"(@seed\s+(\w+)\s+at\s*\(\s*([0-9.eE+-]+)\s*,\s*([0-9.eE+-]+)\s*,\s*([0-9.eE+-]+)\s*\)\s*;)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		SeedTile seed;
		seed.tileName = m[1].str();
		seed.position = Point3D(std::stod(m[2].str()), std::stod(m[3].str()), std::stod(m[4].str()));
		system_.tiling.seedTiles.push_back(seed);
		return true;
	}
	return false;
}

bool MliParser::parseRod(const std::string& line) {
	std::regex re(R"(@rod\s+(\w+)\s*\(\s*length\s*=\s*([0-9.eE+-]+)\s*\)\s*;)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		Rod rod;
		rod.name = m[1].str();
		rod.length = std::stod(m[2].str());
		system_.tiling.rods.push_back(rod);
		return true;
	}
	return false;
}

bool MliParser::parseFloating(const std::string& line) {
	std::regex re(R"(@floating\s+(\w+)\s*\(\s*mobility\s*=\s*([0-9.eE+-]+)\s*,\s*radius\s*=\s*([0-9.eE+-]+)\s*,\s*concentration\s*=\s*([0-9.eE+-]+)\s*\)\s*;)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		FloatingObject fo;
		fo.name = m[1].str();
		fo.mobility = std::stod(m[2].str());
		fo.radius = std::stod(m[3].str());
		fo.concentration = std::stod(m[4].str());
		system_.floatingObjects.push_back(fo);
		return true;
	}
	return false;
}

bool MliParser::parseProtionDecl(const std::string& line) {
	std::regex re(R"(@protion\s+(\w+)\s*;)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		system_.protions.push_back(Protion(m[1].str()));
		return true;
	}
	return false;
}

bool MliParser::parseProtionOnTile(const std::string& line) {
	std::regex re(R"(@protion\s+(\w+)\s+on\s+(\w+)\s+at\s*\(\s*([0-9.eE+-]+)\s*,\s*([0-9.eE+-]+)\s*\)\s*;)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		ProtionOnTile pot;
		pot.protionName = m[1].str();
		pot.tileName = m[2].str();
		pot.position = Point3D(std::stod(m[3].str()), std::stod(m[4].str()), 0);
		system_.protionsOnTiles.push_back(pot);
		return true;
	}
	return false;
}

bool MliParser::parseSigma(const std::string& line) {
	std::regex re(R"(@sigma\s*\(\s*(\w+)\s*,\s*(\w+)\s*\)\s*=\s*([^;]+);)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		SignalRelease sr;
		sr.glue1 = m[1].str();
		sr.glue2 = m[2].str();
		auto objs = split(m[3].str(), ',');
		for (auto& o : objs) {
			sr.released[ObjectString(o)]++;
		}
		system_.signalReleases.push_back(sr);
		return true;
	}
	return false;
}

bool MliParser::parseReactionDistance(const std::string& line) {
	std::regex re(R"(@reaction_distance\s+([0-9.eE+-]+)\s*;)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		system_.reactionDistance = std::stod(m[1].str());
		return true;
	}
	return false;
}

static Multiset parseMultiset(const std::string& s) {
	Multiset ms;
	auto parts = split(s, ',');
	for (auto& part : parts) {
		std::string p = trim(part);
		std::regex reMul(R"((\w+)\s*\*\s*(\d+))");
		std::smatch m;
		if (std::regex_match(p, m, reMul)) {
			ms[ObjectString(m[1].str())] = Multiplicity(std::stoul(m[2].str()));
		} else if (!p.empty()) {
			ms[ObjectString(p)]++;
		}
	}
	return ms;
}

bool MliParser::parseCreateRule(const std::string& line) {
	std::regex re(R"(@create\s+([^-]+)\s*-->\s*(\w+)\s*;)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		MRule rule;
		rule.type = MRuleType::CREATION;
		rule.leftObjects = parseMultiset(m[1].str());
		rule.tileName = trim(m[2].str());
		system_.rules.push_back(rule);
		return true;
	}
	return false;
}

bool MliParser::parseDestroyRule(const std::string& line) {
	std::regex re(R"(@destroy\s+([^,]+),\s*(\w+)\s*-->\s*([^;]+);)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		MRule rule;
		rule.type = MRuleType::DESTRUCTION;
		rule.leftObjects = parseMultiset(m[1].str());
		rule.tileName = trim(m[2].str());
		rule.rightObjects = parseMultiset(m[3].str());
		system_.rules.push_back(rule);
		return true;
	}
	return false;
}

bool MliParser::parseDivideRule(const std::string& line) {
	std::regex re(R"(@divide\s+(\w+)\s*,\s*([^,]+),\s*(\w+)\s*-->\s*(\w+)\s*,\s*(\w+)\s*;)");
	std::smatch m;
	if (std::regex_search(line, m, re)) {
		MRule rule;
		rule.type = MRuleType::DIVISION;
		rule.glue1 = trim(m[1].str());
		rule.leftObjects = parseMultiset(m[2].str());
		rule.glue2 = trim(m[3].str());
		system_.rules.push_back(rule);
		return true;
	}
	return false;
}

bool MliParser::parseMetabolicRule(const std::string& line) {
	// Catalytic: protion: LHS --> RHS;
	std::regex reCat(R"((\w+)\s*:\s*([^-]+)\s*-->\s*([^;]+);)");
	std::smatch m;
	if (std::regex_search(line, m, reCat)) {
		MRule rule;
		rule.type = MRuleType::METABOLIC_CATALYTIC;
		rule.protionName = trim(m[1].str());
		rule.leftObjects = parseMultiset(m[2].str());
		rule.rightObjects = parseMultiset(m[3].str());
		system_.rules.push_back(rule);
		return true;
	}

	// Symport in: LHS [| protion --> [| protion LHS;
	std::regex reSympIn(R"(([^[]+)\s*\[\|\s*(\w+)\s*-->\s*\[\|\s*\w+\s+([^;]+);)");
	if (std::regex_search(line, m, reSympIn)) {
		MRule rule;
		rule.type = MRuleType::METABOLIC_SYMPORT_IN;
		rule.leftObjects = parseMultiset(m[1].str());
		rule.protionName = trim(m[2].str());
		rule.rightObjects = parseMultiset(m[3].str());
		system_.rules.push_back(rule);
		return true;
	}

	// Simple: LHS --> RHS;
	std::regex reSimple(R"(([a-zA-Z_][^-]*)\s*-->\s*([^;]+);)");
	if (std::regex_search(line, m, reSimple)) {
		std::string lhs = trim(m[1].str());
		if (lhs.find("@") != std::string::npos) return false;
		MRule rule;
		rule.type = MRuleType::METABOLIC_SIMPLE;
		rule.leftObjects = parseMultiset(lhs);
		rule.rightObjects = parseMultiset(m[2].str());
		system_.rules.push_back(rule);
		return true;
	}
	return false;
}

} // namespace msystem
} // namespace plingua
