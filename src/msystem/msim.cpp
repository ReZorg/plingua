/*
 * msim.cpp:
 *
 * M-system simulator — discrete-step simulation engine for morphogenetic
 * systems, inspired by the Cytos simulator architecture.
 *
 * Copyright (C) 2024  P-Lingua/M-Lingua Contributors
 * Licensed under GPL-3.0
 */

#include <msystem/msim.hpp>
#include <algorithm>
#include <iostream>
#include <cmath>

namespace plingua {
namespace msystem {

MSimulator::MSimulator(const MSystem& system, const SimConfig& config)
	: system_(system), config_(config), rng_(config.seed),
	  currentStep_(0), nextTileId_(0) {}

void MSimulator::initialize() {
	currentStep_ = 0;
	tiles_.clear();
	floatingObjs_.clear();
	stats_.clear();
	nextTileId_ = 0;

	initializeSeedTiles();
	initializeFloatingObjects();
}

void MSimulator::initializeSeedTiles() {
	for (const auto& seed : system_.tiling.seedTiles) {
		TileInstance ti;
		for (size_t i = 0; i < system_.tiling.tiles.size(); i++) {
			if (system_.tiling.tiles[i].name == seed.tileName) {
				ti.tileIndex = i;
				break;
			}
		}
		ti.tileName = seed.tileName;
		ti.position = seed.position;
		ti.rotation = seed.rotation;
		ti.id = nextTileId_++;

		const auto& tileDef = system_.tiling.tiles[ti.tileIndex];
		for (size_t c = 0; c < tileDef.connectors.size(); c++) {
			TileInstance::ConnState cs;
			cs.connectorIndex = c;
			ti.connectors.push_back(cs);
		}
		tiles_.push_back(ti);
	}
}

void MSimulator::initializeFloatingObjects() {
	double envSize = config_.environmentSize;
	for (const auto& fo : system_.floatingObjects) {
		size_t count = static_cast<size_t>(
			fo.concentration * envSize * envSize * envSize / 1000.0);
		if (count < 1 && fo.concentration > 0) count = static_cast<size_t>(fo.concentration * 100);

		size_t foIdx = 0;
		for (size_t i = 0; i < system_.floatingObjects.size(); i++) {
			if (system_.floatingObjects[i].name == fo.name) { foIdx = i; break; }
		}

		for (size_t i = 0; i < count; i++) {
			FloatingInstance fi;
			fi.objIndex = foIdx;
			fi.name = fo.name;
			fi.position = randomPosition();
			floatingObjs_.push_back(fi);
		}
	}
}

Point3D MSimulator::randomPosition() {
	std::uniform_real_distribution<double> dist(-config_.environmentSize/2,
	                                             config_.environmentSize/2);
	return {dist(rng_), dist(rng_), dist(rng_)};
}

std::vector<size_t> MSimulator::findNearbyFloating(const Point3D& pos, double radius) {
	std::vector<size_t> result;
	for (size_t i = 0; i < floatingObjs_.size(); i++) {
		if (floatingObjs_[i].consumed) continue;
		double d = (floatingObjs_[i].position - pos).norm();
		if (d <= radius) {
			result.push_back(i);
		}
	}
	return result;
}

bool MSimulator::step() {
	if (currentStep_ >= config_.maxSteps) return false;

	StepStats st;
	st.step = currentStep_;

	applyCreationRules(st);
	applyDestructionRules(st);
	applyDivisionRules(st);
	applyMetabolicRules(st);
	tryConnect(st);
	moveFloatingObjects();
	cleanupConsumed();

	st.tileCount = tiles_.size();
	st.floatingCount = floatingObjs_.size();
	stats_.push_back(st);

	if (stepCallback_) stepCallback_(currentStep_, st);
	currentStep_++;
	return true;
}

void MSimulator::run() {
	initialize();
	while (step()) {}
}

void MSimulator::applyCreationRules(StepStats& st) {
	for (const auto& rule : system_.rules) {
		if (rule.type != MRuleType::CREATION) continue;

		for (auto& tile : tiles_) {
			for (size_t ci = 0; ci < tile.connectors.size(); ci++) {
				if (tile.connectors[ci].connectedToTile >= 0) continue;

				auto nearby = findNearbyFloating(tile.position, system_.reactionDistance);
				std::map<std::string, std::vector<size_t>> byName;
				for (size_t fi : nearby) {
					byName[floatingObjs_[fi].name].push_back(fi);
				}

				bool canApply = true;
				for (const auto& pair : rule.leftObjects) {
					auto it = byName.find(pair.first.str());
					if (it == byName.end() || it->second.size() < pair.second.raw()) {
						canApply = false;
						break;
					}
				}

				if (canApply) {
					for (const auto& pair : rule.leftObjects) {
						auto& indices = byName[pair.first.str()];
						for (size_t k = 0; k < pair.second.raw() && !indices.empty(); k++) {
							floatingObjs_[indices.back()].consumed = true;
							indices.pop_back();
						}
					}

					size_t tileDefIdx = 0;
					for (size_t ti = 0; ti < system_.tiling.tiles.size(); ti++) {
						if (system_.tiling.tiles[ti].name == rule.tileName) {
							tileDefIdx = ti;
							break;
						}
					}

					TileInstance newTile;
					newTile.tileIndex = tileDefIdx;
					newTile.tileName = rule.tileName;
					newTile.position = tile.position + Point3D(
						system_.tiling.tiles[tileDefIdx].radius * 2.0, 0, 0);
					newTile.id = nextTileId_++;

					const auto& tileDef = system_.tiling.tiles[tileDefIdx];
					for (size_t c = 0; c < tileDef.connectors.size(); c++) {
						TileInstance::ConnState cs;
						cs.connectorIndex = c;
						newTile.connectors.push_back(cs);
					}

					tiles_.push_back(newTile);
					st.rulesApplied++;
					break;
				}
			}
		}
	}
}

void MSimulator::applyDestructionRules(StepStats& st) {
	for (const auto& rule : system_.rules) {
		if (rule.type != MRuleType::DESTRUCTION) continue;

		for (size_t ti = 0; ti < tiles_.size(); ti++) {
			if (tiles_[ti].tileName != rule.tileName) continue;

			auto nearby = findNearbyFloating(tiles_[ti].position, system_.reactionDistance);
			std::map<std::string, std::vector<size_t>> byName;
			for (size_t fi : nearby) {
				byName[floatingObjs_[fi].name].push_back(fi);
			}

			bool canApply = true;
			for (const auto& pair : rule.leftObjects) {
				auto it = byName.find(pair.first.str());
				if (it == byName.end() || it->second.size() < pair.second.raw()) {
					canApply = false;
					break;
				}
			}

			if (canApply) {
				for (const auto& pair : rule.leftObjects) {
					auto& indices = byName[pair.first.str()];
					for (size_t k = 0; k < pair.second.raw() && !indices.empty(); k++) {
						floatingObjs_[indices.back()].consumed = true;
						indices.pop_back();
					}
				}

				for (const auto& pair : rule.rightObjects) {
					for (size_t k = 0; k < pair.second.raw(); k++) {
						FloatingInstance fi;
						for (size_t oi = 0; oi < system_.floatingObjects.size(); oi++) {
							if (system_.floatingObjects[oi].name == pair.first.str()) {
								fi.objIndex = oi;
								break;
							}
						}
						fi.name = pair.first.str();
						fi.position = tiles_[ti].position;
						floatingObjs_.push_back(fi);
					}
				}

				for (auto& conn : tiles_[ti].connectors) {
					if (conn.connectedToTile >= 0 && conn.connectedToTile < (long)tiles_.size()) {
						auto& otherTile = tiles_[conn.connectedToTile];
						if (conn.connectedToConn >= 0 && conn.connectedToConn < (long)otherTile.connectors.size()) {
							otherTile.connectors[conn.connectedToConn].connectedToTile = -1;
							otherTile.connectors[conn.connectedToConn].connectedToConn = -1;
						}
					}
				}

				tiles_.erase(tiles_.begin() + ti);
				ti--;
				st.rulesApplied++;
			}
		}
	}
}

void MSimulator::applyDivisionRules(StepStats& st) {
	for (const auto& rule : system_.rules) {
		if (rule.type != MRuleType::DIVISION) continue;

		for (size_t ti = 0; ti < tiles_.size(); ti++) {
			for (size_t ci = 0; ci < tiles_[ti].connectors.size(); ci++) {
				auto& conn = tiles_[ti].connectors[ci];
				if (conn.connectedToTile < 0) continue;

				const auto& tileDef = system_.tiling.tiles[tiles_[ti].tileIndex];
				if (ci >= tileDef.connectors.size()) continue;

				const std::string& g1 = tileDef.connectors[ci].glueName;

				auto& otherTile = tiles_[conn.connectedToTile];
				if (conn.connectedToConn < 0 || conn.connectedToConn >= (long)otherTile.connectors.size())
					continue;
				const auto& otherTileDef = system_.tiling.tiles[otherTile.tileIndex];
				if (conn.connectedToConn >= (long)otherTileDef.connectors.size()) continue;
				const std::string& g2 = otherTileDef.connectors[conn.connectedToConn].glueName;

				if (g1 != rule.glue1 || g2 != rule.glue2) continue;

				auto nearby = findNearbyFloating(tiles_[ti].position, system_.reactionDistance);
				std::map<std::string, std::vector<size_t>> byName;
				for (size_t fi : nearby) {
					byName[floatingObjs_[fi].name].push_back(fi);
				}

				bool canApply = true;
				for (const auto& pair : rule.leftObjects) {
					auto it = byName.find(pair.first.str());
					if (it == byName.end() || it->second.size() < pair.second.raw()) {
						canApply = false;
						break;
					}
				}

				if (canApply) {
					for (const auto& pair : rule.leftObjects) {
						auto& indices = byName[pair.first.str()];
						for (size_t k = 0; k < pair.second.raw() && !indices.empty(); k++) {
							floatingObjs_[indices.back()].consumed = true;
							indices.pop_back();
						}
					}

					long otherIdx = conn.connectedToTile;
					long otherConn = conn.connectedToConn;
					conn.connectedToTile = -1;
					conn.connectedToConn = -1;
					if (otherIdx >= 0 && otherIdx < (long)tiles_.size() &&
					    otherConn >= 0 && otherConn < (long)tiles_[otherIdx].connectors.size()) {
						tiles_[otherIdx].connectors[otherConn].connectedToTile = -1;
						tiles_[otherIdx].connectors[otherConn].connectedToConn = -1;
					}

					st.rulesApplied++;
					st.connectionsBroken++;
					break;
				}
			}
		}
	}
}

void MSimulator::applyMetabolicRules(StepStats& st) {
	for (const auto& rule : system_.rules) {
		if (rule.type != MRuleType::METABOLIC_SIMPLE &&
		    rule.type != MRuleType::METABOLIC_CATALYTIC) continue;

		std::map<std::string, std::vector<size_t>> byName;
		for (size_t i = 0; i < floatingObjs_.size(); i++) {
			if (!floatingObjs_[i].consumed) {
				byName[floatingObjs_[i].name].push_back(i);
			}
		}

		bool canApply = true;
		for (const auto& pair : rule.leftObjects) {
			auto it = byName.find(pair.first.str());
			if (it == byName.end() || it->second.size() < pair.second.raw()) {
				canApply = false;
				break;
			}
		}

		if (canApply) {
			for (const auto& pair : rule.leftObjects) {
				auto& indices = byName[pair.first.str()];
				for (size_t k = 0; k < pair.second.raw() && !indices.empty(); k++) {
					floatingObjs_[indices.back()].consumed = true;
					indices.pop_back();
				}
			}

			for (const auto& pair : rule.rightObjects) {
				for (size_t k = 0; k < pair.second.raw(); k++) {
					FloatingInstance fi;
					for (size_t oi = 0; oi < system_.floatingObjects.size(); oi++) {
						if (system_.floatingObjects[oi].name == pair.first.str()) {
							fi.objIndex = oi;
							break;
						}
					}
					fi.name = pair.first.str();
					fi.position = randomPosition();
					floatingObjs_.push_back(fi);
				}
			}
			st.rulesApplied++;
		}
	}
}

bool MSimulator::canConnect(const TileInstance& t1, size_t c1,
                            const TileInstance& t2, size_t c2) const {
	const auto& td1 = system_.tiling.tiles[t1.tileIndex];
	const auto& td2 = system_.tiling.tiles[t2.tileIndex];

	if (c1 >= td1.connectors.size() || c2 >= td2.connectors.size()) return false;

	const std::string& g1 = td1.connectors[c1].glueName;
	const std::string& g2 = td2.connectors[c2].glueName;

	for (const auto& gr : system_.tiling.glueRelations) {
		if (gr.matches(g1, g2)) return true;
	}
	return false;
}

void MSimulator::tryConnect(StepStats& st) {
	for (size_t i = 0; i < tiles_.size(); i++) {
		for (size_t ci = 0; ci < tiles_[i].connectors.size(); ci++) {
			if (tiles_[i].connectors[ci].connectedToTile >= 0) continue;

			for (size_t j = i + 1; j < tiles_.size(); j++) {
				double dist = (tiles_[i].position - tiles_[j].position).norm();
				if (dist > system_.tiling.glueRadius + system_.tiling.tiles[tiles_[i].tileIndex].radius * 2.5)
					continue;

				for (size_t cj = 0; cj < tiles_[j].connectors.size(); cj++) {
					if (tiles_[j].connectors[cj].connectedToTile >= 0) continue;

					if (canConnect(tiles_[i], ci, tiles_[j], cj)) {
						tiles_[i].connectors[ci].connectedToTile = j;
						tiles_[i].connectors[ci].connectedToConn = cj;
						tiles_[j].connectors[cj].connectedToTile = i;
						tiles_[j].connectors[cj].connectedToConn = ci;
						st.connectionsFormed++;

						for (const auto& sr : system_.signalReleases) {
							const auto& td1 = system_.tiling.tiles[tiles_[i].tileIndex];
							const auto& td2 = system_.tiling.tiles[tiles_[j].tileIndex];
							const std::string& g1 = td1.connectors[ci].glueName;
							const std::string& g2 = td2.connectors[cj].glueName;
							if ((sr.glue1 == g1 && sr.glue2 == g2) ||
							    (sr.glue1 == g2 && sr.glue2 == g1)) {
								for (const auto& pair : sr.released) {
									for (size_t k = 0; k < pair.second.raw(); k++) {
										FloatingInstance fi;
										fi.name = pair.first.str();
										fi.position = (tiles_[i].position + tiles_[j].position) * 0.5;
										floatingObjs_.push_back(fi);
									}
								}
							}
						}
						break;
					}
				}
			}
		}
	}
}

void MSimulator::moveFloatingObjects() {
	for (auto& fo : floatingObjs_) {
		if (fo.consumed) continue;
		double mobility = 1.0;
		if (fo.objIndex < system_.floatingObjects.size()) {
			mobility = system_.floatingObjects[fo.objIndex].mobility;
		}
		std::normal_distribution<double> dist(0, mobility);
		fo.position.x += dist(rng_);
		fo.position.y += dist(rng_);
		fo.position.z += dist(rng_);
	}
}

void MSimulator::cleanupConsumed() {
	floatingObjs_.erase(
		std::remove_if(floatingObjs_.begin(), floatingObjs_.end(),
			[](const FloatingInstance& fi) { return fi.consumed; }),
		floatingObjs_.end());
}

} // namespace msystem
} // namespace plingua
