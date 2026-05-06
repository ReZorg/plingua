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
