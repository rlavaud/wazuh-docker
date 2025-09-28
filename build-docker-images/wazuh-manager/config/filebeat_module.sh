## variables
REPOSITORY="packages-dev.wazuh.com/pre-release"
WAZUH_TAG=$(curl --silent https://api.github.com/repos/wazuh/wazuh/git/refs/tags | grep '["]ref["]:' | sed -E 's/.*\"([^\"]+)\".*/\1/'  | cut -c 11- | grep ^v${WAZUH_VERSION}$)

## check tag to use the correct repository
if [[ -n "${WAZUH_TAG}" ]]; then
  REPOSITORY="packages.wazuh.com/4.x"
fi

function getArchBasedFilebeatVersion() {
  case $(arch) in
    'aarch64' | 'arm64') echo ${FILEBEAT_CHANNEL}-${FILEBEAT_VERSION}"-aarch64.rpm"   ;;
    'x86_64'  | 'amd64') echo ${FILEBEAT_CHANNEL}-${FILEBEAT_VERSION}"-x86_64.rpm"     ;;
    *)
      echo "Architecture $(arch) not supported" >> /dev/stderr;
      exit 1;
    ;;
  esac
}

FILEBEAT_FILE=$(getArchBasedFilebeatVersion);

curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/${FILEBEAT_FILE} &&\
yum install -y ${FILEBEAT_FILE} && rm -f ${FILEBEAT_FILE} && \
curl -s https://${REPOSITORY}/filebeat/${WAZUH_FILEBEAT_MODULE} | tar -xvz -C /usr/share/filebeat/module