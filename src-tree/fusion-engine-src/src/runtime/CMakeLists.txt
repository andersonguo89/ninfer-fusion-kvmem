# The measured device route profiles ship inside the binary: device_profiles.json (ninfer-calibrate
# --print output of each part, merged) becomes a string in the generated source.
set(NINFER_DEVICE_PROFILES_FILE ${CMAKE_CURRENT_SOURCE_DIR}/engine/device_profiles.json)
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${NINFER_DEVICE_PROFILES_FILE})
file(READ ${NINFER_DEVICE_PROFILES_FILE} NINFER_DEVICE_PROFILES_JSON)
# feat/anti-loop: MSVC 19.44 rejects raw string literals of ~30KB with C2026
# (observed on the device-route-profiles table; split at a line boundary into
# two concatenated raw literals so each chunk stays well under the limit).
set(_ninfer_nl "\n")
set(NINFER_DEVICE_PROFILES_LITERALS "")
set(_ninfer_chunk_size 8000)
string(LENGTH "${NINFER_DEVICE_PROFILES_JSON}" _ninfer_profiles_len)
set(_ninfer_off 0)
set(_ninfer_idx 0)
while(_ninfer_off LESS _ninfer_profiles_len)
  string(SUBSTRING "${NINFER_DEVICE_PROFILES_JSON}" ${_ninfer_off} ${_ninfer_chunk_size} _ninfer_chunk)
  string(APPEND NINFER_DEVICE_PROFILES_LITERALS "R\"ninfer_c${_ninfer_idx}(${_ninfer_chunk})ninfer_c${_ninfer_idx}\"")
  math(EXPR _ninfer_off "_ninfer_off + _ninfer_chunk_size")
  math(EXPR _ninfer_idx "_ninfer_idx + 1")
endwhile()

configure_file(engine/device_profiles_builtin.cpp.in
               ${CMAKE_CURRENT_BINARY_DIR}/engine/device_profiles_builtin.cpp @ONLY)

add_library(ninfer_runtime_support STATIC
  engine/admission_policy.cpp
  engine/context_cache/context_cost.cpp
  engine/context_cache/context_cost_defaults.cpp
  engine/device_profile.cpp
  ${CMAKE_CURRENT_BINARY_DIR}/engine/device_profiles_builtin.cpp
  engine/kv_capacity.cpp
  engine/public_types.cpp
  prefix_cache/block_hash.cpp
  prefix_cache/prefix_index.cpp
  prefix_cache/tap_planner.cpp
)
ninfer_internal_includes(ninfer_runtime_support)
target_link_libraries(ninfer_runtime_support PUBLIC ninfer_core ninfer_ops PRIVATE ninfer::json)

# Public Engine and common contracts; model execution remains in the model layer.
add_library(ninfer_engine STATIC
  engine/model_instance.cpp
  contract/sampling.cpp
  engine/engine.cpp
)
ninfer_internal_includes(ninfer_engine)
target_include_directories(ninfer_engine PUBLIC ${PROJECT_SOURCE_DIR}/include)
target_link_libraries(ninfer_engine PRIVATE
  ninfer_calibration
  ninfer_model_runtime
  ninfer_artifact
  ninfer_core
  ninfer_runtime_support
  ninfer_ops
  ninfer_text
  ninfer_media_decode)
add_library(ninfer::engine ALIAS ninfer_engine)
