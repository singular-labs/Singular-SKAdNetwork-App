# Singular-SKAdNetwork-App
Sample apps demonstrating the logic needed to implement SKAdNetwork as an ad network, publisher and advertiser.

This repo contains:
1. Advertiser sample app
2. Publisher sample app
3. A server that simulates an ad network API (including ad signing)

***Note: to run the sample apps use XCode 12 (currently in beta)***

## How to Use the Advertiser Sample App
- Open `SingularAdvertiserSampleApp.xcodeproj`
- Run the app and follow the on-screen instructions

## How to Use the Publisher Sample App
- Open `SingularPublisherSampleApp.xcodeproj`
- Make sure that the `skadnetwork_server.py` is running (instructions below)
- Modify the consts placeholders in `ViewController.m` to set your own parameters
- Follow the steps in `ViewController.m` starting in `showAdClick`
- Run the app and follow the on-screen instructions

## How to Run skadnetwork_server.py
- Place your private key (see below on how to generate it) in the same directory as the server in a file called `key.pem`
- `cd skadnetwork-server`
- `pip install -r requirements.txt` (make sure you are using python3)
- `python skadnetwork_server.py`

Now you should have a server listening on port 8000 that serves ad network responses to the publisher sample app.

## How to generate your public-private key pair
- SKAdNetwork uses an ECDSA keypair with the `prime192v1` curve, generate it by using:\
`openssl ecparam -name prime192v1 -genkey -noout -out companyname_skadnetwork_private_key.pem`
- For more details see Apple's instructions [Here](https://developer.apple.com/documentation/storekit/skadnetwork/registering_an_ad_network)

\
\
\
To learn more about Singular visit: [https://www.singular.net](https://www.singular.net)
