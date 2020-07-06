#!/usr/bin/env tclsh

package require sqlite3


# This is a prove of concept.
# I wanted a db with todo's. Todo's have a main topic and zero or more
# non main topics.
# I create the tables with triggers and execute a serie of checks.
# Necessary checks:
# - On toDos:
#   1.01 Insert with wrong topic
#   1.02 Insert duplicate todo
#   1.03 Update main topic to a non main topic
#   1.04 Update to wrong topic
#   1.05 Delete while still refered from toDosTopics
# - On topics:
#   2.01 Insert duplicate
#   2.02 Delete used in toDos
#   2.03 Delete used in toDosTopics
#   2.04 Update id used in toDos
#   2.05 Update id used in toDosTopics
# - On toDosTopics:
#   3.01 Insert with wrong toDoID
#   3.02 Insert with wrong topicID
#   3.03 Insert with main topic
#   3.04 Insert already used topic
#   3.05 Update used to wrong toDoID
#   3.06 Update used to wrong topicID
#   3.07 Update to main topic
#   3.08 Update to already used topic


proc checkConstraint {testDescription SQLStr expectedError {startString False}} {
    if {[catch {db eval ${SQLStr}} SQLError]} {
        set checkError ${SQLError}
        if {${startString}} {
            set checkError [string range ${checkError} \
                              0 [expr {[string length ${expectedError}] - 1}]]
        }
        if {${checkError} ne ${expectedError}} {
            puts stderr [format "%s\nUNEXPECTED ERROR: '%s' (%s)" \
                             ${testDescription} ${SQLError} ${expectedError}]
        }
    } else {
        puts stderr [format "%s\nDid not get an error, expected: '%s'" \
                         ${testDescription} ${expectedError}]
    }
}

proc deinit {} {
    db close
}

proc doChecks {} {
    foreach constraintsStruct ${::constraintsStructList} {
        set constraints [lassign ${constraintsStruct} expectedError startString]
        foreach {testDescription SQLStr} ${constraints} {
            puts ${testDescription}
            checkConstraint ${testDescription} ${SQLStr} ${expectedError} ${startString}
        }
    }
}

proc init {} {
    sqlite db     ${::database}
    db     eval   ${::checkForeignKeys}
    db     eval   ${::dropTablesAndViews}
    db     eval   ${::createTopics}
    db     eval   ${::createToDos}
    db     eval   ${::createToDosTopics}
    db     eval   ${::createTriggers}
    db     eval   ${::createViews}
    db     eval   ${::insertTopics}
    db     eval   ${::insertToDos}
    db     eval   ${::insertToDosTopics}
}


cd     [file dirname ${::argv0}]
source setVariables.tcl
init
doChecks
deinit
