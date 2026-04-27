/*
 * msim_main.cpp:
 *
 * Main entry point for the M-system simulator (msim).
 * Reads .mli files and simulates the M system step by step.
 *
 * Usage:
 *   msim input.mli [-s steps] [-r seed] [-e envsize] [-o output.csv] [-v]
 *
 * Copyright (C) 2024  P-Lingua/M-Lingua Contributors
 * Licensed under GPL-3.0
 */

#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <msystem/mli_parser.hpp>
#include <msystem/msim.hpp>

void printUsage(const char* progName) {
	std::cerr << "M-System Simulator (msim) — Morphogenetic System Simulation\n"
	          << "Usage: " << progName << " <input.mli> [options]\n"
	          << "\nOptions:\n"
	          << "  -s <steps>   Maximum steps (default: 100)\n"
	          << "  -r <seed>    Random seed (default: 42)\n"
	          << "  -e <size>    Environment size (default: 100.0)\n"
	          << "  -o <file>    Output CSV file for statistics\n"
	          << "  -v           Verbose step-by-step output\n"
	          << "  -h           Show this help\n"
	          << "\nExamples:\n"
	          << "  " << progName << " boxy_hallows.mli -s 50 -v\n"
	          << "  " << progName << " cytoskeleton.mli -s 200 -o stats.csv\n";
}

int main(int argc, char* argv[]) {
	if (argc < 2) {
		printUsage(argv[0]);
		return 1;
	}

	std::string inputFile;
	std::string outputFile;
	plingua::msystem::SimConfig config;
	bool verbose = false;

	for (int i = 1; i < argc; i++) {
		if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
			printUsage(argv[0]);
			return 0;
		}
		if (strcmp(argv[i], "-s") == 0 && i + 1 < argc) {
			config.maxSteps = std::stoi(argv[++i]);
		} else if (strcmp(argv[i], "-r") == 0 && i + 1 < argc) {
			config.seed = std::stoi(argv[++i]);
		} else if (strcmp(argv[i], "-e") == 0 && i + 1 < argc) {
			config.environmentSize = std::stod(argv[++i]);
		} else if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) {
			outputFile = argv[++i];
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

	std::cerr << "M-System Simulator initialized:\n"
	          << "  Model: " << sys.modelType << "\n"
	          << "  Tiles: " << sys.tiling.tiles.size() << "\n"
	          << "  Rules: " << sys.rules.size() << "\n"
	          << "  Steps: " << config.maxSteps << "\n"
	          << "  Seed: " << config.seed << "\n";

	config.verbose = verbose;
	plingua::msystem::MSimulator sim(sys, config);

	sim.setStepCallback([verbose](int step, const plingua::msystem::StepStats& st) {
		if (verbose) {
			std::cerr << "Step " << step
			          << " | Tiles: " << st.tileCount
			          << " | Floating: " << st.floatingCount
			          << " | Rules: " << st.rulesApplied
			          << " | +Conn: " << st.connectionsFormed
			          << " | -Conn: " << st.connectionsBroken
			          << "\n";
		}
	});

	sim.run();

	const auto& allStats = sim.stats();

	std::cerr << "\nSimulation complete:\n"
	          << "  Final tiles: " << sim.tiles().size() << "\n"
	          << "  Final floating: " << sim.floatingObjects().size() << "\n"
	          << "  Steps run: " << sim.currentStep() << "\n";

	if (!outputFile.empty()) {
		std::ofstream ofs(outputFile);
		if (!ofs.is_open()) {
			std::cerr << "Cannot open output file: " << outputFile << "\n";
			return 1;
		}
		ofs << "step,tiles,floating,rules_applied,connections_formed,connections_broken\n";
		for (const auto& st : allStats) {
			ofs << st.step << ","
			    << st.tileCount << ","
			    << st.floatingCount << ","
			    << st.rulesApplied << ","
			    << st.connectionsFormed << ","
			    << st.connectionsBroken << "\n";
		}
		std::cerr << "Statistics written to " << outputFile << "\n";
	}

	return 0;
}
