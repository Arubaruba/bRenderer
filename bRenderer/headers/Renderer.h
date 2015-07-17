#ifndef B_RENDERER_H
#define B_RENDERER_H

/* bRenderer includes */
#include "OSdetect.h"
#include "Renderer_GL.h"
#include "Logger.h"
#include "View.h"
#include "Input.h"
#include "AssetManagement.h"

/* vmmlib includes */
#include "vmmlib/util.hpp"

class IRenderProject;

/** @brief The main class that is able to initialize and maintain everything that is necessary to render an image to the screen
*
*	Using the singleton pattern the renderer is accessible from everywhere in the project
*
*	@author Benjamin B�rgisser
*/
class Renderer
{
    friend class BViewLink;
public:

	/* Functions */

	/**	@brief Returns the single instance of the Renderer
	 */
	static Renderer& get()
	{
		static Renderer renderer;
		return renderer;
	}

	/**	@brief Returns a pointer to the view of the renderer
	*
	*	This function returns a pointer to the view of the renderer. The view is where the OpenGL context and
	*	on desktop systems a window is created and managed. On iOS a UIView is created instead.
	*
	*/
	ViewPtr getView();

	/**	@brief Returns a pointer to the input handler of the renderer
	*/
	InputPtr getInput();

	/**	@brief Returns a pointer to the asset management of the renderer
	*/
	AssetManagementPtr getAssets();

	/**	@brief Returns true if the renderer has already been initialized
	*/
	bool isInitialized();

	/**	@brief Returns true if the renderer is running
	*/
	bool isRunning();

	/**	@brief Sets the project instance to be used for function calls
	*
	*	The init, loop and terminate function of the set instance get called automatically.
	*
	*	@param[in] p The project instance
	*/
	void setRenderProject(IRenderProject *p);

	/**	@brief Sets a static function that gets called when initializing the renderer
	*
	*	In an application a function can be defined that gets called immediately after the renderer is initialized.
	*
	*	@param[in] f The function to be called
	*/
	void setInitFunction(void(*f)());

	/**	@brief Sets a static function that gets called repeatedly when looping
	*
	*	The set function gets called repeatedly while the renderer is running.
	*	Usually the scene gets drawn and setup in the defined function.
	*
	*	@param[in] f The function to be called
	*/
	void setLoopFunction(void(*f)(const double deltaTime, const double elapsedTime));

	/**	@brief Sets a static function that gets called when terminating the renderer
	*
	*	The set function gets called when the renderer is terminated.
	*	Here allocated memory can be freed, instances deleted and statuses changed.
	*
	*	@param[in] f The function to be called
	*/
	void setTerminateFunction(void(*f)());

	/* Initialization method for iOS without full screen and window size options */

	/**	@brief Do all necessary initializations for the renderer to be ready to run
	*	@param[in] windowTitle The title for the window on desktop systems (optional)
	*/
	bool initRenderer(std::string windowTitle = bRenderer::DEFAULT_WINDOW_TITLE());

	/* Initialization methods for desktop with full screen and window size options */

	/**	@brief Do all necessary initializations for the renderer to be ready to run
	*	@param[in] fullscreen Decides whether or not the application runs in full screen mode
	*	@param[in] windowTitle The title for the window on desktop systems (optional)
	*/
	bool initRenderer(bool fullscreen, std::string windowTitle = bRenderer::DEFAULT_WINDOW_TITLE());

	/**	@brief Do all necessary initializations for the renderer to be ready to run
	*	@param[in] width The width of the window in pixels
	*	@param[in] height The height of the window in pixels
	*	@param[in] fullscreen Decides whether or not the application runs in full screen mode (optional)
	*	@param[in] windowTitle The title for the window on desktop systems (optional)
	*/
	bool initRenderer(GLint width, GLint height, bool fullscreen = false, std::string windowTitle = bRenderer::DEFAULT_WINDOW_TITLE());

	/**	@brief Start the render loop
	*/
	void runRenderer();

	/**	@brief Stop the render loop
	*/
	void stopRenderer();

	/**	@brief Terminate the renderer
	*/
	void terminateRenderer();

	/**	@brief Draw specified model into the current framebuffer
	*	@param[in] modelName Name of the model
	*	@param[in] cameraName Name of the camera
	*	@param[in] modelMatrix 
	*	@param[in] lightNames Names of the lights in a vector
	*/
	void drawModel(const std::string &modelName, const std::string &cameraName, const vmml::mat4f &modelMatrix, const std::vector<std::string> &lightNames);

	/**	@brief Draw specified model into the current framebuffer
	*	@param[in] modelName Name of the model
	*	@param[in] modelMatrix
	*	@param[in] viewMatrix
	*	@param[in] projectionMatrix
	*	@param[in] lightNames Names of the lights in a vector
	*/
	void drawModel(const std::string &modelName, const vmml::mat4f &modelMatrix, const vmml::mat4f &viewMatrix, const vmml::mat4f &projectionMatrix, const std::vector<std::string> &lightNames);

private:
	/* Functions */

	/**	@brief Private constructor
	 */
	Renderer();

	/**	@brief Private constructor to prevent instantiation via copy constructor
	 */
	Renderer(const Renderer&){}

	/**	@brief Private operator overloading to prevent instantiation of the renderer
	 */
	Renderer & operator = (const Renderer &){}

	/**	@brief Private destructor
	 */
	~Renderer(){}

    /**	@brief Draw the scene
     */
    void draw(double currentTime);
    
	/**	@brief Reset all variables
	*/
	void reset();

	/* Variables */

	bool _initialized;
	bool _running;

	double _elapsedTime, _stopTime, _initialTime;

	ViewPtr				_view;
	InputPtr			_input;
	AssetManagementPtr	_assetManagement;

	IRenderProject *_renderProject;
	
	void(*_initFunction)();
	void(*_loopFunction)(const double deltaTime, const double elapsedTime);
	void(*_terminateFunction)();

};



#endif /* defined(B_RENDERER_H) */
