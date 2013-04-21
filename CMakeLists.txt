CMAKE_MINIMUM_REQUIRED(VERSION 2.6 FATAL_ERROR)
CMAKE_POLICY(VERSION 2.6)
INSTALL(
	FILES
		cmake/Lua2DoxConfig.cmake
		cmake/TorchDox.cmake
		cmake/Doxyfile.in
	DESTINATION
		share/cmake/lua2dox
)
INSTALL(PROGRAMS bin/lua2dox DESTINATION bin)	
