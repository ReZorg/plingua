#ifndef _MSYSTEM_HPP_
#define _MSYSTEM_HPP_

#include <string>
#include <vector>
#include <map>
#include <set>
#include <cmath>
#include <iostream>
#include "cereal/types/vector.hpp"
#include "cereal/types/map.hpp"
#include "cereal/types/set.hpp"
#include "cereal/types/string.hpp"
#include "serialization.hpp"

namespace plingua {
namespace msystem {

struct Point3D {
	double x, y, z;
	Point3D() : x(0), y(0), z(0) {}
	Point3D(double x, double y, double z) : x(x), y(y), z(z) {}

	Point3D operator+(const Point3D& o) const { return {x+o.x, y+o.y, z+o.z}; }
	Point3D operator-(const Point3D& o) const { return {x-o.x, y-o.y, z-o.z}; }
	Point3D operator*(double s) const { return {x*s, y*s, z*s}; }
	double dot(const Point3D& o) const { return x*o.x + y*o.y + z*o.z; }
	Point3D cross(const Point3D& o) const {
		return {y*o.z - z*o.y, z*o.x - x*o.z, x*o.y - y*o.x};
	}
	double norm() const { return std::sqrt(x*x + y*y + z*z); }
	Point3D normalized() const { double n = norm(); return n > 0 ? (*this)*(1.0/n) : *this; }

	bool operator==(const Point3D& o) const {
		return std::abs(x-o.x) < 1e-9 && std::abs(y-o.y) < 1e-9 && std::abs(z-o.z) < 1e-9;
	}
	bool operator<(const Point3D& o) const {
		if (x != o.x) return x < o.x;
		if (y != o.y) return y < o.y;
		return z < o.z;
	}

	template<class A> void serialize(A& archive) {
		archive(x, y, z);
	}
};

struct Angles {
	double phi1;
	double phi2;
	Angles() : phi1(0), phi2(0) {}
	Angles(double p1, double p2) : phi1(p1), phi2(p2) {}

	template<class A> void serialize(A& archive) {
		archive(phi1, phi2);
	}
};

struct Glue {
	std::string name;
	Glue() {}
	Glue(const std::string& n) : name(n) {}

	bool operator==(const Glue& o) const { return name == o.name; }
	bool operator<(const Glue& o) const { return name < o.name; }

	template<class A> void serialize(A& archive) {
		archive(name);
	}
};

struct GlueRelation {
	std::string glue1;
	std::string glue2;
	GlueRelation() {}
	GlueRelation(const std::string& g1, const std::string& g2) : glue1(g1), glue2(g2) {}

	bool matches(const std::string& a, const std::string& b) const {
		return (glue1 == a && glue2 == b) || (glue1 == b && glue2 == a);
	}

	template<class A> void serialize(A& archive) {
		archive(glue1, glue2);
	}
};

struct Connector {
	std::string name;
	std::vector<std::string> vertexNames;
	std::string glueName;
	Angles angles;
	double resistance;

	Connector() : resistance(0) {}

	template<class A> void serialize(A& archive) {
		archive(name, vertexNames, glueName, angles, resistance);
	}
};

struct NamedPosition {
	std::string name;
	Point3D position;
	NamedPosition() {}
	NamedPosition(const std::string& n, const Point3D& p) : name(n), position(p) {}

	template<class A> void serialize(A& archive) {
		archive(name, position);
	}
};

struct Color {
	std::string name;
	int alpha;
	Color() : alpha(255) {}
	Color(const std::string& n, int a) : name(n), alpha(a) {}

	template<class A> void serialize(A& archive) {
		archive(name, alpha);
	}
};

struct Tile {
	std::string name;
	int sides;
	double radius;
	double connectingAngle;
	std::string surfaceGlue;
	std::vector<Connector> connectors;
	std::vector<NamedPosition> positions;
	Color color;
	int dimension;

	Tile() : sides(4), radius(1.0), connectingAngle(M_PI/2.0),
	         dimension(2) {}

	std::vector<Point3D> computeVertices() const {
		std::vector<Point3D> verts;
		for (int i = 0; i < sides; i++) {
			double angle = 2.0 * M_PI * i / sides;
			verts.push_back({radius * std::cos(angle), radius * std::sin(angle), 0.0});
		}
		return verts;
	}

	template<class A> void serialize(A& archive) {
		archive(name, sides, radius, connectingAngle, surfaceGlue,
		        connectors, positions, color, dimension);
	}
};

struct Rod {
	std::string name;
	double length;
	std::vector<Connector> connectors;
	Color color;

	Rod() : length(1.0) {}

	template<class A> void serialize(A& archive) {
		archive(name, length, connectors, color);
	}
};

struct Protion {
	std::string name;
	Protion() {}
	Protion(const std::string& n) : name(n) {}

	bool operator==(const Protion& o) const { return name == o.name; }
	bool operator<(const Protion& o) const { return name < o.name; }

	template<class A> void serialize(A& archive) {
		archive(name);
	}
};

struct ProtionOnTile {
	std::string protionName;
	std::string tileName;
	Point3D position;

	ProtionOnTile() {}

	template<class A> void serialize(A& archive) {
		archive(protionName, tileName, position);
	}
};

struct FloatingObject {
	std::string name;
	double mobility;
	double radius;
	double concentration;
	std::string shape;

	FloatingObject() : mobility(1.0), radius(0.05), concentration(0.0), shape("sphere") {}

	template<class A> void serialize(A& archive) {
		archive(name, mobility, radius, concentration, shape);
	}
};

struct SeedTile {
	std::string tileName;
	Point3D position;
	Point3D rotation;

	SeedTile() {}

	template<class A> void serialize(A& archive) {
		archive(tileName, position, rotation);
	}
};

struct SignalRelease {
	std::string glue1;
	std::string glue2;
	Multiset released;

	SignalRelease() {}

	template<class A> void serialize(A& archive) {
		archive(glue1, glue2, released);
	}
};

enum class MRuleType {
	METABOLIC_SIMPLE,
	METABOLIC_CATALYTIC,
	METABOLIC_SYMPORT_IN,
	METABOLIC_SYMPORT_OUT,
	METABOLIC_ANTIPORT,
	CREATION,
	DESTRUCTION,
	DIVISION
};

struct MRule {
	MRuleType type;
	Multiset leftObjects;
	Multiset rightObjects;
	std::string protionName;
	std::string tileName;
	std::string glue1;
	std::string glue2;
	int priority;

	MRule() : type(MRuleType::METABOLIC_SIMPLE), priority(0) {}

	template<class A> void serialize(A& archive) {
		archive(type, leftObjects, rightObjects, protionName,
		        tileName, glue1, glue2, priority);
	}
};

struct PolytoticTileSystem {
	std::vector<Tile> tiles;
	std::vector<Rod> rods;
	std::vector<Glue> glues;
	std::vector<GlueRelation> glueRelations;
	double glueRadius;
	double randomMovement;
	std::vector<SeedTile> seedTiles;

	PolytoticTileSystem() : glueRadius(0.1), randomMovement(0.0) {}

	template<class A> void serialize(A& archive) {
		archive(tiles, rods, glues, glueRelations, glueRadius,
		        randomMovement, seedTiles);
	}
};

struct MSystem {
	std::string name;
	std::string modelType;
	PolytoticTileSystem tiling;
	std::vector<FloatingObject> floatingObjects;
	std::vector<Protion> protions;
	std::vector<ProtionOnTile> protionsOnTiles;
	std::vector<MRule> rules;
	std::vector<SignalRelease> signalReleases;
	double reactionDistance;

	MSystem() : modelType("morphogenetic"), reactionDistance(1.0) {}

	template<class A> void serialize(A& archive) {
		archive(name, modelType, tiling, floatingObjects, protions,
		        protionsOnTiles, rules, signalReleases, reactionDistance);
	}
};

} // namespace msystem
} // namespace plingua

#endif // _MSYSTEM_HPP_
