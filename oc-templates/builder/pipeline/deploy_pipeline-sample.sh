#!/bin/bash
APPLICATION_NAME=pipeline-sample
JENKINS_FILE='jenkinsfile-test-sample.gdsl'
GIT_SECRET_NAME=github-de-technical-secret
SVN_SECRET_NAME=svn-de-technical-secret

oc process -f pipeline-sample.yaml -p APPLICATION_NAME=$APPLICATION_NAME JENKINS_FILE=$JENKINS_FILE GIT_SECRET_NAME=${GIT_SECRET_NAME} SVN_SECRET_NAME=${SVN_SECRET_NAME} | oc delete -f -
oc process -f pipeline-sample.yaml -p APPLICATION_NAME=$APPLICATION_NAME JENKINS_FILE=$JENKINS_FILE GIT_SECRET_NAME=${GIT_SECRET_NAME} SVN_SECRET_NAME=${SVN_SECRET_NAME} | oc create -f -
