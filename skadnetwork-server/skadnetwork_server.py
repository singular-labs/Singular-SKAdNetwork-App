import sys
import time
import uuid

from flask import Flask, request, jsonify
from ecdsa_wrapper import ECDSA

app = Flask(__name__)

# noinspection PyBroadException
try:
    # The key.pem should be in the same directory as this server script
    ECDSA_PRIVATE = open('key.pem').read()
except Exception:
    print("Please create a key.pem file with your private key")
    sys.exit(-1)

CAMPAIGN_ID = u'<ENTER_CAMPAIGN_ID_HERE>'  # Should be between 1-100
TARGET_ITUNES_ID = '<ENTER_TARGET_APP_ID_HERE>'
SIGNATURE_SEPARATOR = u'\u2063'  # This separator is required to generate a valid signature
SKADNETWORK_1_VERSION = '1.0'
SKADNETWORK_2_VERSION = '2.0'


@app.route('/get-ad-impression', methods=['GET'])
def get_skadnetwork_parameters():
    skadnet_version = request.args.get('skadnetwork_version')
    adnet_id = request.args.get('adnetwork_id')
    source_app_id = request.args.get('source_app_id')
    nonce = str(uuid.uuid4())
    timestamp = str(int(time.time()*1000))

    # In SKAdNetwork Version '1.0' we use less parameters to generate a signature
    if skadnet_version == SKADNETWORK_1_VERSION:
        fields = [
            SKADNETWORK_1_VERSION,
            CAMPAIGN_ID,
            TARGET_ITUNES_ID,
            nonce,
            timestamp,
        ]
    elif skadnet_version == SKADNETWORK_2_VERSION:
        fields = [
            SKADNETWORK_2_VERSION,
            adnet_id,
            CAMPAIGN_ID,
            TARGET_ITUNES_ID,
            nonce,
            source_app_id,
            timestamp,
        ]
    else:
        return jsonify({'error': 'unsupported protocol version'}), 400

    message = SIGNATURE_SEPARATOR.join(fields)
    ecdsa = ECDSA(ECDSA_PRIVATE)
    signature = ecdsa.sign(message).decode('utf8')

    return jsonify({
        'signature': signature,
        'campaignId': CAMPAIGN_ID,
        'adNetworkId': adnet_id,
        'nonce': nonce,
        'timestamp': timestamp,
        'sourceAppId': source_app_id,
        'id': TARGET_ITUNES_ID,
        'adNetworkVersion': skadnet_version,
    })


if __name__ == '__main__':
    app.run('0.0.0.0', port=8000)
