#!/bin/bash

#ecrAcc=$1
#ecrRepo=$2
myDockerAcc=$1
myDockerRepo=$2
ebApp=$3
ebEnv=$4

tmpLog="tmp.log"

if [ ! -d eb ]; then 
  mkdir eb
fi
cd eb

# Create Dockerrun file
cat > Dockerrun.aws.json << EOF
{
    "AWSEBDockerrunVersion": "1",
    "Image": {
        "Name": "$myDockerAcc/$myDockerRepo:latest",
        "Update": "true"
    },
    "Ports": [
    {
        "ContainerPort": "80"
    }
    ]
}
EOF

mkdir .elasticbeanstalk
cat > .elasticbeanstalk/config.yml << EOF
branch-defaults:
  default:
    environment: ${ebEnv}
    group_suffix: null
global:
  application_name: ${ebApp}
  default_ec2_keyname: buildMachine
  default_platform: Docker
  default_region: us-east-2
  profile: null
  sc: null

EOF

mv ../infr/.ebextensions/ .

/usr/local/bin/eb deploy ${ebEnv} --timeout "60"

# Check Eb environment status
/usr/local/bin/eb status | grep Status > "${tmpLog}"
grep -q "Ready" "$tmpLog"
if [ $? -ne 0 ]; then {
    echo "Eb Env has been updated with error"
    exit 1
} else {
    echo "Eb Env has been updated successfully"
}
fi
