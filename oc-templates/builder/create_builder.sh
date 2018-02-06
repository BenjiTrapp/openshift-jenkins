#!/bin/bash
BASEDIR=$(dirname "$0")
FULL_BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

SCRIPT_DIR="${FULL_BASEDIR}"
OPENSHIFT_TEMPLATE_DIR=${SCRIPT_DIR}/openshift-templates

source ${OPENSHIFT_TEMPLATE_DIR}/utils/evaluate_exit_status_from_last_command.sh
# load config von ausfuehrenden Verzeichnis
source ./secret_github.cfg

echo "#################### loesche alle OC Objekte ##############################"
echo "#################### Vorhandene Secrets im Projekt ########################"
oc get secrets $SECRET_NAME
echo "############################################################################"
read -p "Sollen Secret ${SECRET_NAME} entfernt werden? (y/n)" REMOVE

echo "#################### loeschen des Secrets ##################################"
if [ ${REMOVE} == "y" ] || [ ${REMOVE} == "Y" ]; then
    echo "Lösche Secret ..."
    sh ${OPENSHIFT_TEMPLATE_DIR}/secrets/delete_secret.sh ${SECRET_NAME} ${SERVICE_ACCOUNT}
else
    echo "Übersprungen - Secret \"${SECRET_NAME}\" wurde nicht gelöscht!"
fi
print_last_cmd_status

source ./dev/builder.cfg
${OPENSHIFT_TEMPLATE_DIR}/buildconfig/delete_builder.sh ${BUILDER_NAME}
source ./master/builder.cfg
${OPENSHIFT_TEMPLATE_DIR}/buildconfig/delete_builder.sh ${BUILDER_NAME}
sh ${OPENSHIFT_TEMPLATE_DIR}/buildconfig/delete_imagestream.sh ${IMAGE_NAME}
echo "############################################################################"

echo "#################### erstelle alle OC Objekte ##############################"
sh ${OPENSHIFT_TEMPLATE_DIR}/secrets/create_secret_github.sh
sh ${OPENSHIFT_TEMPLATE_DIR}/buildconfig/create_imagestream.sh ${IMAGE_NAME}

source ./dev/builder.cfg
sh ${OPENSHIFT_TEMPLATE_DIR}/buildconfig/create_builder.sh ${BUILDER_NAME} ${IMAGE_NAME} ${IMAGE_VERSION} ${SECRET_NAME} ${GIT_SOURCE_URL} ${GIT_SOURCE_REF}
source ./master/builder.cfg
sh ${OPENSHIFT_TEMPLATE_DIR}/buildconfig/create_builder.sh ${BUILDER_NAME} ${IMAGE_NAME} ${IMAGE_VERSION}  ${SECRET_NAME} ${GIT_SOURCE_URL} ${GIT_SOURCE_REF}
echo "############################################################################"