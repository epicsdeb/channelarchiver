# EPICS R3.14 Makefile for the Export Tool
TOP=./..
include $(TOP)/configure/CONFIG
include $(TOP)/make.cfg

USR_CXXFLAGS += -I ../../Tools -I ../../Storage 

SRCS += main.cpp

PROD_HOST := ArchiveExport
PROD_LIBS_DEFAULT := Storage Tools ca Com
PROD_LIBS_WIN32 := StorageObj ToolsObj ca Com
SYS_PROD_LIBS_WIN32 = ws2_32 advapi32 user32

PROD_SYS_LIBS += xerces-c

include $(TOP)/configure/RULES

test:
	sh test.sh

valgrind:
	IN_VALGRIND=1 valgrind $(VALGRIND_FLAGS) O.$(EPICS_HOST_ARCH)/ArchiveExport ../DemoData/index fred janet

.PHONY: test valgrind

