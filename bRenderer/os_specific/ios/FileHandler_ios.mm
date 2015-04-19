#include "../../headers/FileHandler.h"

namespace bRenderer
{
	
	std::string getFilePath(const std::string &fileName)
    {
        NSString *fullFile = [NSString stringWithCString:fileName.c_str()
                                                   encoding:[NSString defaultCStringEncoding]];
        
        NSString* path = [[fullFile lastPathComponent] stringByDeletingPathExtension];
        NSString* extension = [fullFile pathExtension];
        
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:path ofType:extension]];
        
        NSString *urlString = [url path];
        
        return std::string([urlString UTF8String]);
    }
    
    bool fileExists(const std::string &fileName)
    {
        NSString *fullFile = [NSString stringWithCString:fileName.c_str()
                                                encoding:[NSString defaultCStringEncoding]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: fullFile];
        
        return [fileManager fileExistsAtPath:path];
    }

} // namespace bRenderer