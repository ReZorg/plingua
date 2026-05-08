/*
 * mlingua_main.cpp:
 *
 * Main entry point for the M-Lingua compiler.
 * Reads .mli files and outputs Cytos XML or binary format.
 *
 * Usage:
 *   mlingua input.mli [-o output.xml] [-f xml|json|binary]
 *
 * Copyright (C) 2024  P-Lingua/M-Lingua Contributors
 * Licensed under GPL-3.0
 */

#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <msystem/mli_parser.hpp>
#include <msystem/cytos_xml.hpp>

void printUsage(const char* progName) {
	std::cerr << "M-Lingua Compiler — Morphogenetic System Language\n"
	          << "Usage: " << progName << " <input.mli> [options]\n"
	          << "\nOptions:\n"
	          << "  -o <file>    Output file (default: stdout)\n"
	          << "  -f <format>  Output format: xml (default), json\n"
	          << "  -v           Verbose output\n"
	          << "  -h           Show this help\n"
	          << "\nExamples:\n"
	          << "  " << progName << " boxy_hallows.mli -o boxy.xml\n"
	          << "  " << progName << " cytoskeleton.mli -f xml\n";
}

int main(int argc, char* argv[]) {
	if (argc < 2) {
		printUsage(argv[0]);
		return 1;
	}

	std::string inputFile;
	std::string outputFile;
	std::string format = "xml";
	bool verbose = false;

	for (int i = 1; i < argc; i++) {
		if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
			printUsage(argv[0]);
			return 0;
		}
		if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) {
			outputFile = argv[++i];
		} else if (strcmp(argv[i], "-f") == 0 && i + 1 < argc) {
			format = argv[++i];
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
		std::cerr << "Error: No input file specified\n";
		printUsage(argv[0]);
		return 1;
	}

	plingua::msystem::MliParser parser;
	if (!parser.parseFile(inputFile)) {
		std::cerr << "Parse errors in " << inputFile << ":\n";
		for (const auto& err : parser.errors()) {
			std::cerr << "  " << err << "\n";
		}
		return 1;
	}

	const auto& sys = parser.system();

	if (verbose) {
		std::cerr << "M-Lingua compilation successful:\n"
		          << "  Model type: " << sys.modelType << "\n"
		          << "  Tiles: " << sys.tiling.tiles.size() << "\n"
		          << "  Rods: " << sys.tiling.rods.size() << "\n"
		          << "  Glues: " << sys.tiling.glues.size() << "\n"
		          << "  Glue relations: " << sys.tiling.glueRelations.size() << "\n"
		          << "  Floating objects: " << sys.floatingObjects.size() << "\n"
		          << "  Protions: " << sys.protions.size() << "\n"
		          << "  Rules: " << sys.rules.size() << "\n"
		          << "  Seed tiles: " << sys.tiling.seedTiles.size() << "\n"
		          << "  Geometry profile: " << sys.geometryProfileLabel << "\n"
		          << "  Manifolds: " << sys.manifolds.size() << "\n"
		          << "  Metrics: " << sys.metrics.size() << "\n"
		          << "  Connections: " << sys.connections.size() << "\n"
		          << "  Polytopes: " << sys.polytopes.size() << "\n"
		          << "  Flows: " << sys.flows.size() << "\n"
		          << "  Capabilities: " << sys.capabilities.size() << "\n";
	}

	std::string output;
	if (format == "xml") {
		output = plingua::msystem::CytosXmlGenerator::generate(sys);
	} else {
		std::cerr << "Unsupported format: " << format << "\n";
		return 1;
	}

	if (outputFile.empty()) {
		std::cout << output;
	} else {
		std::ofstream ofs(outputFile);
		if (!ofs.is_open()) {
			std::cerr << "Cannot open output file: " << outputFile << "\n";
			return 1;
		}
		ofs << output;
		if (verbose) {
			std::cerr << "Output written to " << outputFile << "\n";
		}
	}

	return 0;
}
