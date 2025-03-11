import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oyo/buttonAndText.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription? subscription;
  RemoteConfigUpdate? update;
  bool newUpdate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Config Example'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ButtonAndText widget to initialize Remote Config
            ButtonAndText(
              // Default text to display before initialization
              defaultText: 'Not initialized',
              // Text on the button
              buttonText: 'Initialize',
              // Function to execute when the button is pressed
              onPressed: () async {
                // Get the instance of FirebaseRemoteConfig
                final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

                // Set default values for Remote Config parameters
                await remoteConfig.setDefaults(<String, dynamic>{
                  'welcome': 'welcome', // Default value for 'welcome' key
                  'new_update': false // Default value for 'new_update' key
                });

                // Set configuration settings for Remote Config
                await remoteConfig.setConfigSettings(
                  RemoteConfigSettings(
                    fetchTimeout: const Duration(seconds: 10), // Timeout for fetching
                    minimumFetchInterval: const Duration(minutes: 5), // Minimum interval between fetches
                  ),
                );

                // Return a message indicating initialization is complete
                return 'Initialized';
              },
            ),
            const SizedBox(height: 16),
            // ButtonAndText widget to fetch and activate Remote Config
            ButtonAndText(
              defaultText: 'No data',
              buttonText: 'Fetch Activate',
              onPressed: () async {
                try {
                  // Get the instance of FirebaseRemoteConfig
                  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

                  // Set configuration settings for Remote Config
                  await remoteConfig.setConfigSettings(
                    RemoteConfigSettings(
                      fetchTimeout: const Duration(seconds: 10), // Timeout for fetching
                      minimumFetchInterval: Duration.zero, // Minimum interval between fetches
                    ),
                  );

                  // Fetch and activate the remote config values
                  await remoteConfig.fetchAndActivate();
                  print("Fetched: ${remoteConfig.getString('welcome')}");
                  return 'Fetched: ${remoteConfig.getString('welcome')}';
                } on PlatformException catch (exception) {
                  print(exception);
                  return 'Exception: $exception';
                } catch (exception) {
                  print(exception);
                  return 'Unable to fetch';
                }
              },
            ),
            const SizedBox(height: 16),
            // ButtonAndText widget to listen for Remote Config updates
            ButtonAndText(
              defaultText: update != null ? 'Updated keys: ${update?.updatedKeys}' : 'No data',
              buttonText: subscription != null ? 'Cancel' : 'Listen',
              onPressed: () async {
                try {
                  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
                  if (subscription != null) {
                    await subscription!.cancel();
                    setState(() {
                      subscription = null;
                    });
                    return 'Listening cancelled';
                  }

                  // Update the state to start listening for Remote Config updates
                  setState(() {
                    // Subscribe to the Remote Config update stream
                    subscription = remoteConfig.onConfigUpdated.listen((event) async {
                      // Activate the fetched remote config values
                      await remoteConfig.activate();
                      // Update the state with the new config values
                      setState(() {
                        update = event; // Store the update event
                        newUpdate = remoteConfig.getBool('new_update'); // Check if there is a new update
                      });
                    });
                  });
                  return 'Listening, waiting for update...';
                } on PlatformException catch (exception) {
                  print(exception);
                  return 'Exception: $exception';
                } catch (exception) {
                  print(exception);
                  return 'Unable to listen';
                }
              },
            ),
            const SizedBox(height: 20),
            // Display a message if there is a new update
            if (newUpdate)
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "This is a new dynamic update from firebase",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
