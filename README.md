# Singular-SKAdnetwork-App
Sample Apps demonstrating the logic needed to implement SKAdNetwork as an ad network, publisher and advertiser.

This repo contains:
1. Advertiser sample app
2. Publisher sample app
3. A server that simulates an ad network API (including signing)

***Note: to run the sample apps use XCode 12 (currently in beta version)***

## How to use the Advertiser sample app:
- Open `SingularAdvertiserSampleApp.xcodeproj`
- Run the app and follow the on-screen instructions

## How to use the Publisher sample app:
- Open `SingularPublisherSampleApp.xcodeproj`
- Make sure that the `skadnetwork_server.py` is running (instructions below)
- Modify the consts placeholders in `ViewController.m` to set your own parameters
- Follow the steps in `ViewController.m` starting in `showAdClick`
- Run the app and follow the on-screen instructions

## How to run skadnetwork_server.py
- Place your private key in the same directory as the server in file called `key.pem`
- `cd skadnetwork-server`
- `pip install -r requirements.txt` (make sure you are using python3)
- `python skadnetwork_server.py`

Now should have a server listening on port 8000 that serves ad network responses to the publisher sample app.

To learn more about Singular visit: [https://www.singular.net](https://www.singular.net)
