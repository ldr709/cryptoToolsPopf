include(CheckSymbolExists)

## Relic
###########################################################################

if (ENABLE_RELIC)

  if(NOT RLC_LIBRARY)
      if(MSVC)
            if(NOT RLC_INCLUDE_DIR)
                set(RLC_INCLUDE_DIR "c:/libs/include")
                set(RLC_LIBRARY "c:/libs/lib/relic_s.lib")
            endif()

          if (NOT EXISTS "${RLC_INCLUDE_DIR}/relic")
            message(FATAL_ERROR "Failed to find Relic at ${RLC_INCLUDE_DIR}/relic. Please set RLC_INCLUDE_DIR and RLC_LIBRARY manually.")
          endif ()
      else()
          find_package(Relic REQUIRED)

          if (NOT Relic_FOUND)
            message(FATAL_ERROR "Failed to find Relic")
          endif (NOT Relic_FOUND)
      endif()
  endif()
  set(RLC_LIBRARY "${RELIC_LIBRARIES}${RLC_LIBRARY}")
  set(RLC_INCLUDE_DIR "${RELIC_INCLUDE_DIR}${RLC_INCLUDE_DIR}")

  message(STATUS "Relic_LIB:  ${RLC_LIBRARY}")
  message(STATUS "Relic_inc:  ${RLC_INCLUDE_DIR}\n")


endif (ENABLE_RELIC)


# libsodium
###########################################################################

if (ENABLE_SODIUM)
  pkg_check_modules(SODIUM REQUIRED libsodium)

  if (NOT SODIUM_FOUND)
    message(FATAL_ERROR "Failed to find libsodium")
  endif (NOT SODIUM_FOUND)

  message(STATUS "SODIUM_INCLUDE_DIRS:  ${SODIUM_INCLUDE_DIRS}")
  message(STATUS "SODIUM_LIBRARY_DIRS:  ${SODIUM_LIBRARY_DIRS}")
  message(STATUS "SODIUM_LIBRARIES:  ${SODIUM_LIBRARIES}\n")

  set(CMAKE_REQUIRED_INCLUDES ${SODIUM_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_LINK_OPTIONS ${SODIUM_LDFLAGS})
  set(CMAKE_REQUIRED_LIBRARIES ${SODIUM_LIBRARIES})
  check_symbol_exists(crypto_scalarmult_noclamp "sodium.h" SODIUM_MONTGOMERY)
  unset(CMAKE_REQUIRED_LIBRARIES)
  unset(CMAKE_REQUIRED_LINK_OPTIONS)
  unset(CMAKE_REQUIRED_INCLUDES)

  if (SODIUM_MONTGOMERY)
    message(STATUS "Sodium supports Montgomery curve noclamp operations.")
  else()
    message(STATUS "Sodium does not support Montgomery curve noclamp operations.")
  endif()
endif (ENABLE_SODIUM)


## WolfSSL
###########################################################################

if(ENABLE_WOLFSSL)

  if(NOT DEFINED WolfSSL_DIR)
    set(WolfSSL_DIR "/usr/local/")
  endif()


  find_library(WOLFSSL_LIB NAMES wolfssl  HINTS "${WolfSSL_DIR}")
  set(WOLFSSL_LIB_INCLUDE_DIRS "${WolfSSL_DIR}include/")

  # if we cant find it, throw an error
  if(NOT WOLFSSL_LIB)
      message(FATAL_ERROR "Failed to find WolfSSL at " ${WolfSSL_DIR})
  endif()

  message(STATUS "WOLFSSL_LIB:  ${WOLFSSL_LIB}")
  message(STATUS "WOLFSSL_INC:  ${WOLFSSL_LIB_INCLUDE_DIRS}\n")

endif(ENABLE_WOLFSSL)


## Boost
###########################################################################



if(ENABLE_BOOST)

    set(BOOST_SEARCH_PATHS "${BOOST_ROOT}")

    if(NOT BOOST_ROOT OR NOT EXISTS "${BOOST_ROOT}")
        if(MSVC)
            set(BOOST_ROOT_local "${CMAKE_CURRENT_LIST_DIR}/../thirdparty/boost/")
            set(BOOST_ROOT_install "c:/libs/boost/")


            set(BOOST_SEARCH_PATHS "${BOOST_SEARCH_PATHS} ${BOOST_ROOT_local} ${BOOST_ROOT_install}")

            if(EXISTS "${BOOST_ROOT_local}")
                set(BOOST_ROOT "${BOOST_ROOT_local}")
            else()
                set(BOOST_ROOT "${BOOST_ROOT_install}")
            endif()
        else()
            set(BOOST_ROOT "${CMAKE_CURRENT_LIST_DIR}/../thirdparty/boost/")

            set(BOOST_SEARCH_PATHS "${BOOST_SEARCH_PATHS} ${BOOST_ROOT}")
        endif()
    endif()


    if(MSVC)
        set(Boost_LIB_PREFIX "lib")
    endif()

    #set(Boost_USE_STATIC_LIBS        ON) # only find static libs
    set(Boost_USE_MULTITHREADED      ON)
    #set(Boost_USE_STATIC_RUNTIME     OFF)
    #set (Boost_DEBUG ON)  #<---------- Real life saver

    macro(findBoost)
        if(MSVC)
            find_package(Boost 1.75 COMPONENTS system thread regex)
        else()
            find_package(Boost 1.75 COMPONENTS system thread)
        endif()
    endmacro()

    # then look at system dirs
    if(NOT Boost_FOUND)
        findBoost()
    endif()

    if(NOT Boost_FOUND)
        message(FATAL_ERROR "Failed to find boost 1.75+ at ${BOOST_ROOT} or at system install")
    endif()

    message(STATUS "Boost_LIB: ${Boost_LIBRARIES}" )
    message(STATUS "Boost_INC: ${Boost_INCLUDE_DIR}\n\n" )

endif()
