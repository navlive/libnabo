# Set compiler flags
set(CMAKE_CXX_STANDARD 17)
add_compile_options(-Wall -Wextra -Wpedantic -Werror=return-type)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
if (NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
  add_definitions(-O3)
endif(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")

# Find macros and libraries
find_package(ament_cmake REQUIRED)
find_package(Eigen3 REQUIRED)
find_package(Boost REQUIRED COMPONENTS python)

set(USE_OPENMP FALSE CACHE BOOL "Set to FALSE to not use OpenMP")
if(USE_OPENMP)
  find_package(OpenMP REQUIRED)
  if (OpenMP_FOUND)
    add_compile_options("${OpenMP_CXX_FLAGS}")
    add_definitions(-DHAVE_OPENMP=${OpenMP_FOUND})
  endif()
endif(USE_OPENMP)


########################
## Library definition ##
########################

include_directories(
  PUBLIC
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/nabo
  SYSTEM
    ${EIGEN3_INCLUDE_DIR}
    ${Boost_INCLUDE_DIRS}
    ${OpenMP_CXX_INCLUDE_DIRS}
)

# Nabo
add_library(nabo
  ${NABO_SRC}
  ${NABO_HEADERS}
)

target_link_libraries(nabo
  ${catkin_LIBRARIES}
  ${Boost_LIBRARIES}
  ${OpenMP_CXX_LIBRARIES}
)

#############
## Install ##
#############
install(
  TARGETS
    nabo
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(
  DIRECTORY ${CMAKE_SOURCE_DIR}/nabo/
  DESTINATION include/nabo/
)

##########
## Test ##
##########

if(BUILD_TESTING)
  find_package(ament_cmake_gtest REQUIRED)
  ament_add_gtest(test_nabo
      tests/empty_test.cpp
  )
  target_include_directories(test_nabo
    PRIVATE
      ${CMAKE_SOURCE_DIR}/nabo
      ${CMAKE_SOURCE_DIR}/tests
    SYSTEM
      ${EIGEN3_INCLUDE_DIR}
      ${catkin_INCLUDE_DIRS}
  )
  target_link_libraries(test_nabo
    gtest_main
    nabo
  )
endif()

#################
## Clang_tools ##
#################
find_package(cmake_clang_tools QUIET)
if(cmake_clang_tools_FOUND)
  add_default_clang_tooling(
    DISABLE_CLANG_FORMAT
  )
endif(cmake_clang_tools_FOUND)




ament_export_include_directories(${CMAKE_SOURCE_DIR} ${EIGEN3_INCLUDE_DIR})
ament_export_libraries(nabo)
ament_export_dependencies(Boost)
ament_package()
