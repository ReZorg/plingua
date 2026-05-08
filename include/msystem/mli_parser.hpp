#ifndef _MLI_PARSER_HPP_
#define _MLI_PARSER_HPP_

#include <string>
#include <vector>
#include "msystem/msystem.hpp"

namespace plingua {
namespace msystem {

class MliParser {
public:
	MliParser();

	bool parseFile(const std::string& filename);
	bool parseString(const std::string& source, const std::string& filename = "<string>");

	const MSystem& system() const { return system_; }
	const std::vector<std::string>& errors() const { return errors_; }

private:
	MSystem system_;
	std::vector<std::string> errors_;
	std::string filename_;
	int lineNum_;

	bool parseModelDecl(const std::string& line);
	bool parseGeometryProfile(const std::string& line);
	bool parseManifold(const std::string& line);
	bool parseMetric(const std::string& line);
	bool parseConnection(const std::string& line);
	bool parseCapability(const std::string& line);
	bool parseFlow(const std::string& line);
	bool parsePolytope(const std::string& line);
	bool parseTilingStart(const std::string& line);
	bool parseTileStart(const std::string& line, Tile& tile);
	bool parseConnector(const std::string& line, Tile& tile);
	bool parseSurfaceGlue(const std::string& line, Tile& tile);
	bool parseColor(const std::string& line, Tile& tile);
	bool parseProtion(const std::string& line, Tile& tile);
	bool parseGlue(const std::string& line);
	bool parseGlueRelation(const std::string& line);
	bool parseGlueRadius(const std::string& line);
	bool parseSeed(const std::string& line);
	bool parseRod(const std::string& line);
	bool parseFloating(const std::string& line);
	bool parseProtionDecl(const std::string& line);
	bool parseProtionOnTile(const std::string& line);
	bool parseSigma(const std::string& line);
	bool parseReactionDistance(const std::string& line);
	bool parseCreateRule(const std::string& line);
	bool parseDestroyRule(const std::string& line);
	bool parseDivideRule(const std::string& line);
	bool parseMetabolicRule(const std::string& line);
};

} // namespace msystem
} // namespace plingua

#endif // _MLI_PARSER_HPP_
