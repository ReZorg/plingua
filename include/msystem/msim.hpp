#ifndef _MSIM_HPP_
#define _MSIM_HPP_

#include <string>
#include <vector>
#include <map>
#include <set>
#include <random>
#include <functional>
#include "msystem/msystem.hpp"

namespace plingua {
namespace msystem {

struct TileInstance {
	size_t tileIndex;
	std::string tileName;
	Point3D position;
	Point3D rotation;
	size_t id;

	struct ConnState {
		size_t connectorIndex;
		long connectedToTile;
		long connectedToConn;
		ConnState() : connectorIndex(0), connectedToTile(-1), connectedToConn(-1) {}
	};
	std::vector<ConnState> connectors;
};

struct FloatingInstance {
	size_t objIndex;
	std::string name;
	Point3D position;
	bool consumed;

	FloatingInstance() : objIndex(0), consumed(false) {}
};

struct SimConfig {
	int maxSteps;
	int seed;
	double environmentSize;
	bool verbose;

	SimConfig() : maxSteps(100), seed(42), environmentSize(100.0), verbose(false) {}
};

struct StepStats {
	int step;
	size_t tileCount;
	size_t floatingCount;
	size_t rulesApplied;
	size_t connectionsFormed;
	size_t connectionsBroken;

	StepStats() : step(0), tileCount(0), floatingCount(0),
	              rulesApplied(0), connectionsFormed(0), connectionsBroken(0) {}
};

class MSimulator {
public:
	MSimulator(const MSystem& system, const SimConfig& config = SimConfig());

	void initialize();
	bool step();
	void run();

	const std::vector<TileInstance>& tiles() const { return tiles_; }
	const std::vector<FloatingInstance>& floatingObjects() const { return floatingObjs_; }
	const std::vector<StepStats>& stats() const { return stats_; }
	int currentStep() const { return currentStep_; }

	using StepCallback = std::function<void(int step, const StepStats&)>;
	void setStepCallback(StepCallback cb) { stepCallback_ = cb; }

private:
	const MSystem& system_;
	SimConfig config_;
	std::mt19937 rng_;
	int currentStep_;

	std::vector<TileInstance> tiles_;
	std::vector<FloatingInstance> floatingObjs_;
	std::vector<StepStats> stats_;
	size_t nextTileId_;
	StepCallback stepCallback_;

	void initializeSeedTiles();
	void initializeFloatingObjects();
	void applyCreationRules(StepStats& st);
	void applyDestructionRules(StepStats& st);
	void applyDivisionRules(StepStats& st);
	void applyMetabolicRules(StepStats& st);
	void tryConnect(StepStats& st);
	void moveFloatingObjects();
	void cleanupConsumed();

	bool canConnect(const TileInstance& t1, size_t c1,
	                const TileInstance& t2, size_t c2) const;
	Point3D randomPosition();
	std::vector<size_t> findNearbyFloating(const Point3D& pos, double radius);
};

} // namespace msystem
} // namespace plingua

#endif // _MSIM_HPP_
