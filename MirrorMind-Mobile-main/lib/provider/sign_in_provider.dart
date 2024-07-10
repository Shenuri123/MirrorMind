import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:mirrormind/util/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twitter_login/twitter_login.dart';

import 'dart:async';
import 'package:twitter_api_v2/twitter_api_v2.dart' as v2;

class SignInProvider extends ChangeNotifier {
  // instance of firebaseauth, facebook and google
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final twitterLogin = TwitterLogin(
      apiKey: Config.apikey_twitter,
      apiSecretKey: Config.secretkey_twitter,
      redirectURI: "socialauth://");

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  //hasError, errorCode, provider,uid, email, name, imageUrl
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _name;
  String? get name => _name;

  String? _email;
  String? get email => _email;

  String? get imageUrl => _imageUrl;
  String? _imageUrl;

  String? _age;
  String? get age => _age;

  String? _gender;
  String? get gender => _gender;

  DateTime? _sleepTimer;
  DateTime? get selectedTime => _sleepTimer;

  String? _hos;
  String? get hos => _hos;

bool get isSignedInWithFacebook => _provider == "FACEBOOK";
bool get isSignedInWithTwitter => _provider == "TWITTER";

  SignInProvider() {
    checkSignInUser();
  }

  Future checkSignInUser() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("signed_in") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  set name(String? newName) {
    _name = newName;
    notifyListeners();
  }

  setSleepTimer(DateTime? newSleepTimer) {
    _sleepTimer = newSleepTimer;
    notifyListeners();
  }

  Future<void> updatePuzzleGameData(
      String formattedTime, String movementsText, DateTime playDate) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final puzzleGameData = {
          "formattedTime": formattedTime,
          "movementsText": movementsText,
          "playDate": playDate,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection(
                'puzzle_game_data') // Subcollection for puzzle game data
            .add(puzzleGameData);

        notifyListeners();
      } catch (e) {
        // Handle errors if any
      }
    }
  }

  // Function to update user's quiz game information as subcollections under their document
  Future<void> updateQuizGameInfo(
      int score, int maxScore, DateTime completionTime) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Reference the user's document
        final userDocRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Create a new subcollection under the user's document with a unique auto-generated ID
        final gamePlayDocRef = userDocRef.collection('quiz_scores').doc();

        // Set the fields for the quiz game information
        await gamePlayDocRef.set({
          "quizCompletionTime": completionTime,
          "quizMaxScore": maxScore,
          "quizScore": score,
        });

        // You can perform any additional actions or notify listeners if needed
      } catch (e) {
        // Handle errors if any
      }
    }
  }

  Future<void> updateProfilePicture(String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    // Update the profile picture URL in Firestore (replace 'users' with your user collection path)
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'image_url': imageUrl});

    // Update the profile picture URL in the provider
    _imageUrl = imageUrl;
    notifyListeners();
  }

  Future<void> updateName(String newName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(newName);
        name =
            newName; // Use the setter to update the name in the SignInProvider state
        await saveDataToFirestore(); // Save the updated data to Firestore
      } catch (e) {
        // Handle errors if any
      }
    }
  }

  // Function to update the age in Firestore
  Future<void> updateAge(String newAge) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({"age": newAge});
        _age = newAge.toString();
        notifyListeners();
      } catch (e) {
        // Handle errors if any
      }
    }
  }

  // Function to update the age in Firestore
  Future<void> updateHos(String newHos) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({"hos": newHos});
        _hos = newHos.toString();
        notifyListeners();
      } catch (e) {
        // Handle errors if any
      }
    }
  }

  // Define a method to save the selected sleep time to Firestore
  Future<void> saveFirestoreAddedTime(DateTime selectedTime) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'SleepTime': selectedTime});
    } catch (e) {
      print("Error saving Firestore added time: $e");
      // Handle the error as needed
    }
  }

  // Function to update the gender in Firestore
  Future<void> updateGender(String newGender) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({"gender": newGender});
        _gender = newGender;
        notifyListeners();
      } catch (e) {
        // Handle errors if any
      }
    }
  }

// Function to update the email in Firestore
  Future<void> updateEmail(String newEmail) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updateEmail(newEmail);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({"email": newEmail});
        _email = newEmail;
        notifyListeners();
      } catch (e) {
        // Handle errors if any
      }
    }
  }

  Future<void> signInWithGoogle() async {
    // Reset error code before proceeding
    _errorCode = '';

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential? userCredential =
            await firebaseAuth.signInWithCredential(credential);

        if (userCredential != null) {
          final User userDetails = userCredential.user!;

          // Save user details
          _name = userDetails.displayName;
          _email = userDetails.email;
          _imageUrl = userDetails.photoURL;
          _provider = "GOOGLE";
          _uid = userDetails.uid;
          _hasError = false;
          notifyListeners();
        } else {
          // Handle null userCredential (error case)
          _hasError = true;
          _errorCode = "Failed to sign in with Google";
          notifyListeners();
        }
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;

          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

Future signInWithTwitter() async {
  final twitterLogin = TwitterLogin(
    apiKey: 'lCAdGiuEuxADT1RLj1wNQ6AkM',
    apiSecretKey: 'OR5CBMnwgh04q7aPTpeug9zvjVCcEtGGphFZg69NHFh6RHunZL',
    redirectURI: 'socialauth://',
  );

  final authResult = await twitterLogin.login();

  if (authResult.status == TwitterLoginStatus.loggedIn) {
    final credential = TwitterAuthProvider.credential(
      accessToken: authResult.authToken!,
      secret: authResult.authTokenSecret!,
    );
    final UserCredential? userCredential =
        await firebaseAuth.signInWithCredential(credential);

    if (userCredential != null) {
      final User? userDetails = userCredential.user;
      if (userDetails != null) {
        // Save all the data
        _name = userDetails.displayName;
        _email = userDetails.email ?? firebaseAuth.currentUser?.email;
        _imageUrl = userDetails.photoURL;
        _uid = userDetails.uid;
        _provider = "TWITTER";
        _hasError = false;

        notifyListeners();

        final user = authResult.user;
        final username = user!.screenName;
        await _storeUsernameInPreferences(username); // Store username

      } else {
        // Handle null userDetails (error case)
        _hasError = true;
        notifyListeners();
      }
    } else {
      // Handle null userCredential (error case)
      _hasError = true;
      notifyListeners();
    }
  } else if (authResult.status == TwitterLoginStatus.cancelledByUser) {
    _hasError = true;
    notifyListeners();
  } else if (authResult.status == TwitterLoginStatus.error) {
    _hasError = true;
    notifyListeners();
  } else {
    _hasError = true;
    notifyListeners();
  }
}

Future<void> _storeUsernameInPreferences(String username) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('twitterUsername', username); // Save the username
}



// Function to sign in with Facebook
  Future<void> signInWithFacebook() async {
    // Reset error code before proceeding
    _errorCode = '';

    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;
      final graphResponse = await http.get(Uri.parse(
          'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${accessToken.token}'));

      final profile = jsonDecode(graphResponse.body);

      try {
        // Create Facebook auth credential
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.token);

        // Sign in to Firebase using the Facebook auth credential
        final UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);

        // Save user details
        final User userDetails = authResult.user!;
        _name = userDetails.displayName;
        _email = userDetails.email;
        _imageUrl = userDetails.photoURL;
        _provider = "FACEBOOK";
        _uid = userDetails.uid;
        _hasError = false;
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else if (result.status == LoginStatus.cancelled) {
      _errorCode = "Login was canceled by the user";
      _hasError = true;
      notifyListeners();
    } else {
      _errorCode = "An error occurred during Facebook login";
      _hasError = true;
      notifyListeners();
    }
  }

  // ENTRY FOR CLOUDFIRESTORE
  Future<void> getUserDataFromFirestore(uid) async {
    final DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      _uid = data['uid'];
      _name = data['name'];
      _email = data['email'];
      _hos = data['hos'];
      _age = data['age'];
      _gender = data['gender'];
      _imageUrl = data['image_url'];
      _provider = data['provider'];

      // Check if the 'sleep_timer' field exists and is not null
      if (data.containsKey('SleepTime') && data['SleepTime'] != null) {
        _sleepTimer = (data['SleepTime'] as Timestamp).toDate();
      } else {
        _sleepTimer = null;
      }

      // ... (other fields if available)
    } else {
      // Handle the case when the document doesn't exist
      // You might want to initialize the fields to default values here
      _uid = null;
      _name = null;
      _email = null;
      _age = null;
      _hos = null;
      _gender = null;
      _imageUrl = null;
      _provider = null;
      _sleepTimer = null;
      // ... (initialize other fields if available)
    }
  }

  Future<void> saveDataToFirestore([DateTime? selectedTime]) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = {
        "name": name,
        "uid": uid,
        "age": age,
        "hos": hos,
        "gender": gender,
        "image_url": imageUrl,
        "email": email,
        "provider": provider,
        // Add the 'selectedTime' to the userData map only if it's not null
        if (selectedTime != null) "SleepTime": selectedTime.toUtc(),
      };
      // Save the user data to Firestore
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData, SetOptions(merge: true));
      } catch (e) {
        // Handle errors if any
      }
    }
  }

  Future<void> saveDataToSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    if (_name != null) await s.setString('name', _name!);
    if (_email != null) await s.setString('email', _email!);
    if (_uid != null) await s.setString('uid', _uid!);
    if (_provider != null) await s.setString('provider', _provider!);

    // Check if _imageUrl is not null before setting it
    if (_imageUrl != null) await s.setString('image_url', _imageUrl!);

    notifyListeners();
  }

  Future getDataFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userAge = prefs.getInt('userAge');
    final int? userHos = prefs.getInt('userHos');
    final String? userGender = prefs.getString('userGender');
    final String? sleepTime = prefs.getString('selectedSleepTime');

    final SharedPreferences s = await SharedPreferences.getInstance();
    if (userAge != null) {
      _age = userAge.toString();
    }
    if (userHos != null) {
      _hos = userHos.toString();
    }
    if (userGender != null) {
      _gender = userGender;
    }
    if (sleepTime != null) {
      _sleepTimer = DateFormat.jm().parse(sleepTime);
    }
    _name = s.getString('name');
    _email = s.getString('email');
    _imageUrl = s.getString('image_url');
    _uid = s.getString('uid');
    _provider = s.getString('provider');

    _age = s.getString('age');
    _gender = s.getString('gender');
    _sleepTimer = s.getString('SleepTime') as DateTime?;
    notifyListeners();
  }

  // checkUser exists or not in cloudfirestore
  Future<bool> checkUserExists() async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (snap.exists) {
      print("EXISTING USER");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  // signout
  Future userSignOut() async {
    await firebaseAuth.signOut;
    await googleSignIn.signOut();
    //await facebookAuth.logOut();

    _isSignedIn = false;
    notifyListeners();
    // clear all storage information
    clearStoredData();
  }

  Future clearStoredData() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.clear();
  }

  selectProfilePictureFromGallery() {}
}
