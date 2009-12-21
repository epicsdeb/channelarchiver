# EPICS R3.14 Makefile for the IndexTool
TOP=./..
include $(TOP)/configure/CONFIG
include $(TOP)/make.cfg

USR_CXXFLAGS += -I ../../Storage -I ../../rtree

SRCS += main.cpp

SCRIPTS_HOST += make_indexconfig.pl

PROD_HOST := ArchiveIndexTool
PROD_LIBS_DEFAULT := Storage Tools ca Com 
PROD_LIBS_WIN32 := StorageObj ToolsObj ca Com
SYS_PROD_LIBS_WIN32 = ws2_32 advapi32 user32

PROD_SYS_LIBS += xerces-c

include $(TOP)/configure/RULES

test:
	sh test.sh

.PHONY: test
