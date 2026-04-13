#include <iostream>

//#include <simulators/psim/psim_core.hpp>

#include <simulator/simulator.hpp>
#include <serialization.hpp>


using namespace plingua::simulator;
using namespace plingua;




int main(int argc, char *argv[])
{
	Simulator simulator;
	try{
		if (simulator.parse(argc,argv)) {
			while(simulator.ok()) {
				simulator.step();
			}
			// Save the final configuration to the output file
			try {
				saveToFile(simulator.getOutputFile(), simulator.getCurrentConfiguration(), "file");
			} catch (std::exception& ex) {
				std::cerr << "Error writing output file '" << simulator.getOutputFile() << "': " << ex.what() << std::endl;
				return 1;
			}
		}
	} catch (std::exception& ex) {
		std::cout << ex.what() << std::endl;
		std::cout << "type '" << argv[0] << " --help' for help" << std::endl;
		return 1;
	} 
	return 0;
}
