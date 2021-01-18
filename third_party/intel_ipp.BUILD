load("@rules_cc//cc:defs.bzl", "cc_library")

licenses(["notice"])  # BSD license

exports_files(["LICENSE"])

cc_library(
  name = "ipp",
  srcs = ["lib/intel64/libippicv.a"],
  hdrs = [
      "include/ipp.h",
      "include/ippversion.h",
      "include/ippicv_base.h",
      "include/ippicv_redefs.h",
      "include/ippicv_types.h",
      "include/ippicv_defs.h"
    ],
  includes = ["include/"],
  linkstatic = 1,
  visibility = ["//visibility:public"],
)
