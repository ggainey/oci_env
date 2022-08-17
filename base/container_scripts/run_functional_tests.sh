#!/bin/bash

declare PROJECT=$1

set -e

export XDG_CONFIG_HOME=/opt/settings/
export PULP_API_ROOT=$(bash /src/${COMPOSE_PROJECT_NAME}/base/container_scripts/get_dynaconf_var.sh API_ROOT)

mkdir -p /opt/settings/pulp_smash/

cat > /opt/settings/pulp_smash/settings.json <<EOF
{
  "hosts": [
    {
      "hostname": "${API_HOST}",
      "roles": {
        "api": {
          "port": ${API_PORT},
          "scheme": "${API_PROTOCOL}",
          "service": "nginx",
          "verify": false
        },
        "content": {
          "port": ${API_PORT},
          "scheme": "${API_PROTOCOL}",
          "service": "pulp_content_app",
          "verify": false
        },
        "pulp resource manager": {},
        "pulp workers": {},
        "redis": {},
        "shell": {
          "transport": "local"
        }
      }
    }
  ],
  "pulp": {
    "auth": [
      "${DJANGO_SUPERUSER_USERNAME}",
      "${DJANGO_SUPERUSER_PASSWORD}"
    ],
    "selinux enabled": false,
    "version": "3"
  }
}
EOF

cd /src/$PROJECT/

pytest -r sx --color=yes --pyargs $PROJECT.tests.functional ${@:2}
