#include "../../headers/OSdetect.h"

#ifdef OS_DESKTOP

#include "../../headers/FileHandler.h"
#include "../../headers/Logger.h"
#include <sys/stat.h>

namespace bRenderer
{
	/* Internal variables */
	
	std::string standardFilePath = "data/";

	/* External functions */

	void setStandardFilePath(const std::string &path)
	{
		standardFilePath = path;

		if (path.find_last_of("/") != path.length()-1)
			standardFilePath.append("/");
	}

	std::string getFilePath(const std::string &fileName)
	{	
		std::string filePath = standardFilePath;
		filePath.append(fileName);

		if (!fileExists(filePath))
		{
			log("File not found: " + fileName, LM_ERROR);
		}

		return filePath;
	}

	bool fileExists(const std::string &fileName)
	{
		struct stat buffer;

		if (fileName.find(standardFilePath) == std::string::npos){
			std::string filePath = standardFilePath;
			filePath.append(fileName);
			return (stat(filePath.c_str(), &buffer) == 0);
		}	
		else {
			return (stat(fileName.c_str(), &buffer) == 0);
		}
		
	}

} // namespace bRenderer

#endif