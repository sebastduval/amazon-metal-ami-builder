#!/bin/bash
# FUNCTIONS
function callback {
    STATUS=$1
    MESSAGE=$2
    URL=$3
    UNIQUEID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    if [ "$STATUS" = "SUCCESS" ]; then
        curl -s -X PUT -H 'Content-Type:' --data-binary "{\"Status\" : \"SUCCESS\",\"Reason\" : \"${!MESSAGE}\",\"UniqueId\" : \"${!UNIQUEID}\",\"Data\" :\"${!MESSAGE}\"}" ${!URL}
    else
        curl -s -X PUT -H 'Content-Type:' --data-binary "{\"Status\" : \"FAILURE\",\"Reason\" : \"${!MESSAGE}\",\"UniqueId\" : \"${!UNIQUEID}\",\"Data\" : \"${!MESSAGE}\"}" ${!URL}
    fi
}
# VARIABLES
PACKER_URL="https://releases.hashicorp.com/packer/1.3.3/packer_1.3.3_linux_amd64.zip"
GITHUB_REPO="https://github.com/j2clerck/amazon-metal-ami-builder.git"
ISO_URL="s3://clerckj/packer-windows/iso/Win10_1803_English_x64.iso"
PACKER_BUILD_FILE="windows_10.json"
BUILD_NAME="Windows_10"
BUILD_VERSION="20181212"
EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
EC2_REGION=$(echo $EC2_AVAIL_ZONE | sed 's/[a-z]$//')
SIGNAL_URL="${rWaitHandle}"
# SETUP ENVIRONMENT
apt update
apt -y install unzip awscli nvme-cli git virtualbox jq
DEVICE=$(nvme list | grep Instance -m 1 | awk -F ' ' '{ print $1 }')
parted --script $DEVICE mklabel gpt
parted --script $DEVICE mkpart primary 0% 100%
sleep 5
mkfs.ext4 ${!DEVICE}p1
mkdir /opt/workdir/
mount ${!DEVICE}p1 /opt/workdir
cd /opt/workdir
wget --quiet $PACKER_URL
unzip packer_1.3.3_linux_amd64.zip
chmod +x packer
mv packer /usr/bin/
# DOWNLOAD PACKER BUILD CONFIGURATION
git clone $GITHUB_REPO
cd amazon-metal-ami-builder/packer/
aws s3 cp $ISO_URL ./iso/ --no-progress
if [ $? -ne 0 ]
then
    echo "Unable to download iso"
    callback "FAILURE" "Unable to download ISO" ${!SIGNAL_URL} 
    exit 1
fi
# LAUNCH BUILD
packer build --only virtualbox-iso $PACKER_BUILD_FILE
if [ $? -ne 0 ]
then
    echo "Packer build failed"
    callback "FAILURE" "Unable to build with Packer" ${!SIGNAL_URL} 
    exit 1
fi
# UPLOAD OUTPUT TO S3
aws s3 cp output-virtualbox-iso/*.ova s3://clerckj/vmimport/${!BUILD_NAME}_${!BUILD_VERSION}.ova
if [ $? -ne 0 ]
then
    echo "Upload to S3 failed"
    callback "FAILURE" "Unable to upload to S3" ${!SIGNAL_URL} 
    exit 1
fi
# LAUNCH VM IMPORT
cat << EOF > disk.json
[
{
    "Description": "Windows10",
    "Format": "ova",
    "UserBucket": {
    "S3Bucket": "clerckj",
    "S3Key": "vmimport/${!BUILD_NAME}_${!BUILD_VERSION}.ova"
    }
}
]
EOF
ImportTaskId=$(aws ec2 import-image --architecture x86_64 --description "Import packer build of ${!BUILD_NAME}_${!BUILD_VERSION}" --license-type BYOL --platform Windows --disk-containers file://disk.json --output json --region $EC2_REGION | jq -r .ImportTaskId)
if [ $? -ne 0 ]
then
    echo "Start import task failed"
    callback "FAILURE" "Unable to start import task" ${!SIGNAL_URL} 
    exit 1
fi
echo "Task id is ${!ImportTaskId}. Run aws ec2 describe-import-image-tasks --import-task-ids ${!ImportTaskId} --region ${!EC2_REGION}"
callback "SUCCESS" "Build complete" ${!SIGNAL_URL}