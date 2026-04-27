#ifndef _CYTOS_XML_HPP_
#define _CYTOS_XML_HPP_

#include <string>
#include <sstream>
#include "msystem/msystem.hpp"

namespace plingua {
namespace msystem {

class CytosXmlGenerator {
public:
	static std::string generate(const MSystem& sys);

private:
	static void generateTiling(std::ostringstream& os, const MSystem& sys);
	static void generateMSystem(std::ostringstream& os, const MSystem& sys);
	static void generateRule(std::ostringstream& os, const MRule& rule);
};

} // namespace msystem
} // namespace plingua

#endif // _CYTOS_XML_HPP_
