#include <iostream>
#include <msystem/mli_parser.hpp>

using namespace plingua::msystem;

namespace {
	int tests_run = 0;
	int tests_passed = 0;

	void expect(bool condition, const std::string& message) {
		++tests_run;
		if (condition) {
			++tests_passed;
			std::cout << "[PASS] " << message << "\n";
		} else {
			std::cout << "[FAIL] " << message << "\n";
		}
	}
}

int main() {
	const std::string src = R"(
@msystem<morphogenetic>
@geometry<projective>;
@manifold sphere(charts=8, dimension=2, compact=true);
@metric g(type=riemannian, signature=+++);
@connection nabla(type=levi_civita, bundle=tangent);
@capability gauge_invariance;
@flow rf(type=discrete_ricci, step=0.02, iterations=25, preserve_volume=true);
@polytope c120(dimension=4, vertices=600, edges=1200, faces=720, cells=120, symmetry=H4);

@tiling {
    @glue g1;
    @tile d(sides=4, radius=1.0) {
        @connector c1(vertices=[v1,v2], glue=g1, angle=90);
    }
    @seed d at (0,0,0);
}
)";

	MliParser parser;
	bool ok = parser.parseString(src, "<test>");
	expect(ok, "parser accepts geometry extension syntax");

	const MSystem& sys = parser.system();
	expect(sys.geometryProfileLabel == "projective", "geometry profile parsed");
	expect(sys.manifolds.size() == 1 && sys.manifolds[0].compact, "manifold parsed");
	expect(sys.metrics.size() == 1 && sys.metrics[0].signature == "+++", "metric parsed");
	expect(sys.connections.size() == 1 && sys.connections[0].bundle == "tangent", "connection parsed");
	expect(sys.capabilities.size() == 1 && sys.capabilities[0] == "gauge_invariance", "capability parsed");
	expect(sys.flows.size() == 1 && sys.flows[0].iterations == 25, "flow parsed");
	expect(sys.polytopes.size() == 1 && sys.polytopes[0].incidenceCounts.at("cells") == 120, "polytope parsed");

	std::cout << "\nResults: " << tests_passed << "/" << tests_run << " passed.\n";
	return (tests_passed == tests_run) ? 0 : 1;
}
