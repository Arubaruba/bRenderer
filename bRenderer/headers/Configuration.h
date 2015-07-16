#ifndef B_CONFIGURATION_H
#define B_CONFIGURATION_H

#include <string>
#include "Renderer_GL.h"
#include "vmmlib/addendum.hpp"

namespace bRenderer
{
	/* Renderer configuration */
	vmml::vec3f DEFAULT_AMBIENT_COLOR();

	/* Logger */
	std::string LOG_MODE_INFO();
	std::string LOG_MODE_WARNING();
	std::string LOG_MODE_ERROR();
	std::string LOG_MODE_SYSTEM();

	/* Desktop specific view configuration */
	GLint DEFAULT_VIEW_WIDTH();
	GLint DEFAULT_VIEW_HEIGHT();
	std::string DEFAULT_WINDOW_TITLE();

	/* Desktop specific file path configuration */
	std::string DEFAULT_FILE_PATH();

	/* Shader macros*/
	std::string SHADER_VERSION_MACRO();
	std::string SHADER_MAX_LIGHTS_MACRO();

	/* Shader configuration */
	std::string DEFAULT_SHADER_VERSION_DESKTOP();
	std::string DEFAULT_SHADER_VERSION_ES();
	GLuint DEFAULT_SHADER_MAX_LIGHTS();
	std::string DEFAULT_FRAGMENT_SHADER_FILENAME_EXTENSION();
	std::string DEFAULT_VERTEX_SHADER_FILENAME_EXTENSION();

	/* Shader uniforms */
	std::string DEFAULT_SHADER_UNIFORM_DIFFUSE_MAP();
	std::string DEFAULT_SHADER_UNIFORM_SPECULAR_MAP();
	std::string DEFAULT_SHADER_UNIFORM_NORMAL_MAP();
	std::string DEFAULT_SHADER_UNIFORM_NORMAL_MATRIX();
	std::string DEFAULT_SHADER_UNIFORM_MODEL_MATRIX();
	std::string DEFAULT_SHADER_UNIFORM_VIEW_MATRIX();
	std::string DEFAULT_SHADER_UNIFORM_MODEL_VIEW_MATRIX();
	std::string DEFAULT_SHADER_UNIFORM_PROJECTION_MATRIX();
	std::string DEFAULT_SHADER_UNIFORM_NUMBER_OF_LIGHTS();
	std::string DEFAULT_SHADER_UNIFORM_LIGHT_POSITION_VIEW_SPACE();
	std::string DEFAULT_SHADER_UNIFORM_DIFFUSE_LIGHT_COLOR();
	std::string DEFAULT_SHADER_UNIFORM_SPECULAR_LIGHT_COLOR();
	std::string DEFAULT_SHADER_UNIFORM_LIGHT_INTENSITY();
	std::string DEFAULT_SHADER_UNIFORM_LIGHT_ATTENUATION();
	std::string DEFAULT_SHADER_UNIFORM_AMBIENT_COLOR();
	
	/* Shader attributes */
	std::string DEFAULT_SHADER_ATTRIBUTE_POSITION();
	std::string DEFAULT_SHADER_ATTRIBUTE_NORMAL();
	std::string DEFAULT_SHADER_ATTRIBUTE_TANGENT();
	std::string DEFAULT_SHADER_ATTRIBUTE_BITANGENT();
	std::string DEFAULT_SHADER_ATTRIBUTE_TEXCOORD();

	/* Material key words */
	std::string WAVEFRONT_MATERIAL_NEWMTL();
	std::string WAVEFRONT_MATERIAL_AMBIENT_COLOR();
	std::string WAVEFRONT_MATERIAL_DIFFUSE_COLOR();
	std::string WAVEFRONT_MATERIAL_SPECULAR_COLOR();
	std::string WAVEFRONT_MATERIAL_TRANSMISSION_FILTER();
	std::string WAVEFRONT_MATERIAL_SPECULAR_EXPONENT();
	std::string WAVEFRONT_MATERIAL_OPTICAL_DENSITY();
	std::string WAVEFRONT_MATERIAL_ILLUMINATION_MODEL();
	std::string WAVEFRONT_MATERIAL_DIFFUSE_MAP();
	std::string WAVEFRONT_MATERIAL_SPECULAR_MAP();
	std::string WAVEFRONT_MATERIAL_NORMAL_MAP();

	/* Camera configuration */
	GLfloat DEFAULT_FIELD_OF_VIEW();
	GLfloat DEFAULT_ASPECT_RATIO();
	GLfloat DEFAULT_NEAR_CLIPPING_PLANE();
	GLfloat DEFAULT_FAR_CLIPPING_PLANE();
	vmml::vec3f DEFAULT_CAMERA_POSITION();
	vmml::vec3f DEFAULT_CAMERA_ROTATION_AXES();

	/* Light configuration */
	vmml::vec4f DEFAULT_LIGHT_POSITION();
	vmml::vec3f DEFAULT_LIGHT_COLOR();
	GLfloat DEFAULT_LIGHT_INTENSITY();
	GLfloat DEFAULT_LIGHT_ATTENUATION();

} // namespace bRenderer


#endif /* defined(B_CONFIGURATION_H) */
