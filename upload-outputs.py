import argparse
# Python 3.7 using Cryptography
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend
from cryptography import x509
import requests
import boto3
from botocore.exceptions import ClientError
import json
import os
import shutil
from os.path import abspath
from contextlib import contextmanager
import time
import logging
import datetime
import tempfile

def uploadConfs(thingGroup, destinationBucket, sourceDir, version):
    logging.info("Preparing config zip")

    sourceDir = abspath(sourceDir)

    with tempfile.TemporaryFile() as confZip:
        filename = shutil.make_archive(base_name=confZip.name,
                        format='zip',
                        root_dir=sourceDir)

        s3_client = boto3.client(service_name='s3')

        s3Key = "thing/{0}/conf/{0}-{1}.{2}".format(
            thingGroup, version, "zip")
        logging.info("Sending config zip to s3")
        s3_client.upload_file(filename,
                                destinationBucket,
                                s3Key)
        latestKey = "thing/{0}/conf/latest".format(thingGroup)
        logging.info("Uploading to S3 Bucket: {0}. Key: {1}".format(
            destinationBucket, latestKey))
        s3_client.put_object(
            Body=s3Key, Bucket=destinationBucket, Key=latestKey)
        os.remove(filename)


@contextmanager
def cwd(path):
    oldpwd = os.getcwd()
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(oldpwd)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    parser = argparse.ArgumentParser()
    parser.add_argument('--destinationBucket',
                        help='configuration s3 bucket',
                        required=True)
    parser.add_argument('--sourceDir',
                        help='source dir',
                        default="./outputs")
    parser.add_argument('--thingGroup',
                        help='thing group', required=True)
    parser.add_argument('--version',
                        help='thing config version', required=True)

    args = parser.parse_args()

    uploadConfs(destinationBucket=args.destinationBucket, sourceDir=args.sourceDir, thingGroup=args.thingGroup, version=args.version)