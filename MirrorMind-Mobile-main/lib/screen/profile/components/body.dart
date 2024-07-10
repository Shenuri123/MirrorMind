import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/theme/theme.dart';
import '../../../provider/internet_provider.dart';
import '../../../provider/sign_in_provider.dart';
import '../../../util/next_screen.dart';
import '../../../util/snack_bar.dart';
import '../../login/login_screen.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart'; // Import the NotificationService
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Body extends StatefulWidget {
  final User? user;

  const Body({this.user});

  @override
  State<Body> createState() => _Bodystate();
}

class _Bodystate extends State<Body> {
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController twitterController =
      RoundedLoadingButtonController();

  // Initialize the NotificationService
  final NotificationService notificationService = NotificationService();

  Future<void> getData() async {
    final sp = context.read<SignInProvider>();
    await sp.getDataFromSharedPreferences();
  }

  DateTime? selectedTime;

  @override
  void initState() {
    super.initState();
    getData();
    _refreshData();
    notificationService.initializeNotification();
  }

  // Function to fetch the latest data from Firestore and update the state
  Future<void> _refreshData() async {
    final sp = context.read<SignInProvider>();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch the latest user data from Firestore
      await sp.getUserDataFromFirestore(user.uid);
    }
    // Set the state to trigger a rebuild with the latest data
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            buildProfilePicture('${sp.imageUrl}'),
            SizedBox(height: 10),
            buildUserName('${sp.name}'),
            SizedBox(height: 30),

            // User Information Section
            buildSectionTitle("Account Info"),
            buildProfileCard(context, FontAwesomeIcons.fileSignature, "Name"),
            buildProfileCard(context, FontAwesomeIcons.person, "Age"),
            buildProfileCard(context, Icons.contact_page_rounded, "Gender"),
            // buildProfileCard(context, Icons.phone, "Phone Number"),
            buildProfileCard(context, Icons.email, "Email"),

            SizedBox(height: 30),

            buildSectionTitle("Social Media"),
            buildProfileCard(context, FontAwesomeIcons.google, "Google"),
            buildProfileCard(context, FontAwesomeIcons.facebook, "Facebook"),
            buildProfileCard(context, FontAwesomeIcons.instagram, "Instagram"),
            buildProfileCard(context, FontAwesomeIcons.twitter, "Twitter"),

            SizedBox(height: 30),
            // Settings Section
            buildSectionTitle("Settings"),
            buildProfileCard(context, FontAwesomeIcons.clock, "Hours of sleep"),
            buildProfileCard(context, FontAwesomeIcons.bell, "Set Sleep Timer"),
            buildProfileCard(
                context, FontAwesomeIcons.rightToBracket, "SignOut"),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildProfilePicture(String? image_url) {
    return GestureDetector(
      onTap: () async {
        await _updateProfilePictureFromGallery();
      },
      child: CircleAvatar(
        radius: 70,
        backgroundImage: image_url != null && image_url.isNotEmpty
            ? NetworkImage(image_url)
            : null,
        child: (image_url == null || image_url.isEmpty)
            ? Icon(
                Icons.account_circle,
                size: 140,
                color: AppColors.colorPrimary,
              )
            : null,
      ),
    );
  }

  void _showSleepTimerDialog() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });

      // Save the selected time to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
          'selectedSleepTime', DateFormat.jm().format(selectedTime!));

      // Save the selected time to Firestore using the provider
      context.read<SignInProvider>().saveFirestoreAddedTime(selectedTime!);

      // Calculate the next occurrence of the selected sleep time
      final now = DateTime.now();
      final nextSleepTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      ).add(Duration(
          days: now.hour > pickedTime.hour ||
                  (now.hour == pickedTime.hour &&
                      now.minute >= pickedTime.minute)
              ? 1
              : 0));

      // Schedule the daily notification
      final notificationService = NotificationService();
      // final sleepTime = TimeOfDay(hour: pickedTime.hour, minute: pickedTime.minute);
      notificationService.showNotification(
        1, // Notification ID
        "Sleep Time Reminder",
        "It's time to sleep!",
        nextSleepTime, // Schedule the notification for the next occurrence of the selected sleep time
        // RepeatInterval.daily, // Set the repeat interval to daily
        // sleepTime, // Pass the sleep time to the notification service
      );

      // Display a suitable message when the user sets the sleep timer
      String formattedTime = DateFormat.jm().format(selectedTime!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sleep time set to $formattedTime"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _updateProfilePictureFromGallery() async {
    final sp = context.read<SignInProvider>();
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${sp.uid}.jpg');
      UploadTask uploadTask = ref.putFile(File(pickedImage.path));

      await uploadTask.then((res) async {
        String downloadURL = await res.ref.getDownloadURL();

        // Call the method to update the profile picture in the provider
        await sp.updateProfilePicture(downloadURL);
      });
    }
  }

  Widget buildUserName(String? displayName) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        displayName ?? "",
        style: TextStyle(
          fontSize: 24,
          color: AppColors.colorPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.colorPrimary,
          ),
        ),
      ),
    );
  }

  // Function to show a dialog for editing the name
  void _showEditNameDialog(BuildContext context) {
    final sp = context.read<SignInProvider>();

    // TextEditingController to get the user's input
    TextEditingController _nameController =
        TextEditingController(text: sp.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  // Update the name in Firestore
                  await sp.updateName(_nameController.text);
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

// Function to show a dialog for editing Age
  void _showEditAgeDialog(BuildContext context) {
    final sp = context.read<SignInProvider>();
    TextEditingController _ageController = TextEditingController(text: sp.age);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Age'),
          content: TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Age'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newAge = _ageController.text;
                await sp.updateAge(newAge);

                // Save the age to SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                prefs.setInt('userAge', int.parse(newAge));

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to show a dialog for editing HOS
  void _showEditHOSDialog(BuildContext context) {
    final sp = context.read<SignInProvider>();
    TextEditingController _hosController = TextEditingController(text: sp.hos);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Hours of sleep'),
          content: TextFormField(
            controller: _hosController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Hours of sleep'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newHos = _hosController.text;
                await sp.updateHos(newHos);

                // Save the age to SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                prefs.setInt('userHos', int.parse(newHos));

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to show a dialog for editing Gender
  void _showEditGenderDialog(BuildContext context) {
    final sp = context.read<SignInProvider>();
    TextEditingController _genderController =
        TextEditingController(text: sp.gender);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Gender'),
          content: DropdownButtonFormField<String>(
            value: _genderController.text.isNotEmpty
                ? _genderController.text
                : 'Male', // Set 'Male' as the default value
            items: ['Male', 'Female', 'Other'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              _genderController.text = newValue!;
            },
            decoration: InputDecoration(labelText: 'Gender'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await sp.updateGender(_genderController.text);

                // Save the gender to SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('userGender', _genderController.text);

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to show a dialog for editing Email
  void _showEditEmailDialog(BuildContext context) {
    final sp = context.read<SignInProvider>();
    TextEditingController _emailController =
        TextEditingController(text: sp.email);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Email'),
          content: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await sp.updateEmail(_emailController.text);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget buildProfileCard(BuildContext context, IconData icon, String title) {
    final sp = context.watch<SignInProvider>();
    bool isConnected = false;
    String subtitle = "";

    if (title == "Google" && sp.provider == "GOOGLE") {
      isConnected = true;
      subtitle = "Connected";
    } else if (title == "Facebook" && sp.provider == "FACEBOOK") {
      isConnected = true;
      subtitle = "Connected";
    } else if (title == "Twitter" && sp.provider == "TWITTER") {
      isConnected = true;
      subtitle = "Connected";
    } else if (title == "Instagram" && sp.provider == "INSTAGRAM") {
      isConnected = true;
      subtitle = "Connected";
    } else {
      if (title == "Name") {
        subtitle = "${sp.name}";
      } else if (title == "Age") {
        subtitle = _generateSubtitleForNull(sp.age, "Add your age");
      } else if (title == "Gender") {
        subtitle = _generateSubtitleForNull(sp.gender, "Add your gender");
      } else if (title == "Email") {
        subtitle = _generateSubtitleForNull(sp.email, "Add your Email");
      } else if (title == "Hours of sleep") {
        subtitle = _generateSubtitleForNull(sp.hos, "Add your Hours of sleep");
      }
      if (title == "Set Sleep Timer") {
        // Check if sleepTimer is not null and format it to display in subtitle
        if (sp.selectedTime != null) {
          final formattedSleepTime =
              DateFormat.Hm().format(sp.selectedTime!.toLocal());
          subtitle = formattedSleepTime;
        } else {
          subtitle = "Set Sleep Time";
        }
      }
    }

    // Check connection status for remaining social media platforms
    if (title == "Google" && sp.provider != "GOOGLE") {
      subtitle = "Not Connected";
    } else if (title == "Facebook" && sp.provider != "FACEBOOK") {
      subtitle = "Not Connected";
    } else if (title == "Twitter" && sp.provider != "TWITTER") {
      subtitle = "Not Connected";
    } else if (title == "Instagram" && sp.provider != "INSTAGRAM") {
      subtitle = "Not Connected";
    }

    return GestureDetector(
      onTap: () {
        if (title == "Name") {
          // Show the dialog to edit the name
          _showEditNameDialog(context);
        } else if (title == "Age") {
          // Show the dialog to edit the name
          _showEditAgeDialog(context);
        } else if (title == "Gender") {
          // Show the dialog to edit the name
          _showEditGenderDialog(context);
        } else if (title == "Email") {
          // Show the dialog to edit the name
          _showEditEmailDialog(context);
        } else if (title == "Google") {
          // Show the dialog to edit the name
          handleGoogleSignIn();
        } else if (title == "Facebook") {
          // Show the dialog to edit the name
          handleFacebookAuth();
        } else if (title == "Twitter") {
          // Show the dialog to edit the name
          handleTwitterAuth();
        } else if (title == "Twitter") {
          // Show the dialog to edit the name
          handleTwitterAuth();
        } else if (title == "Hours of sleep") {
          // Show the dialog to edit the name
          _showEditHOSDialog(context);
        } else if (title == "Set Sleep Timer") {
          // Show the dialog to edit the name
          _showSleepTimerDialog();
        } else if (title == "SignOut") {
          // Show the dialog to edit the name
          sp.userSignOut();
          nextScreenReplace(context, const LoginScreen());
        }
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Rounded corners
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: AppColors.colorPrimary,
            size: 32,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.colorPrimary,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isConnected
                  ? Colors.green
                  : AppColors.colorPrimary, // Use green color when connected
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.colorPrimaryLight,
          ),
        ),
      ),
    );
  }

  String _generateSubtitleForNull(dynamic fieldValue, String message) {
    if (fieldValue == null) {
      return message;
    } else if (fieldValue is String && fieldValue.isNotEmpty) {
      return fieldValue;
    } else if (fieldValue is DateTime) {
      return DateFormat.jm().format(fieldValue);
    } else {
      return message;
    }
  }

  Future handleTwitterAuth() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackbar(context, "Check your Internet connection", Colors.red);
      googleController.reset();
    } else {
      await sp.signInWithTwitter().then((value) {
        if (sp.hasError == true) {
          openSnackbar(context, sp.errorCode.toString(), Colors.red);
          twitterController.reset();
        } else {
          // checking whether user exists or not
          sp.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        twitterController.success();
                        // handleAfterSignIn();
                      })));
            } else {
              // user does not exist
              sp.saveDataToFirestore(selectedTime).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        twitterController.success();
                        //handleAfterSignIn();
                      })));
            }
          });
        }
      });
    }
  }

  // handling google sigin in
  Future handleGoogleSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackbar(context, "Check your Internet connection", Colors.red);
      googleController.reset();
    } else {
      await sp.signInWithGoogle().then((value) {
        if (sp.hasError == true) {
          openSnackbar(context, sp.errorCode.toString(), Colors.red);
          googleController.reset();
        } else {
          // checking whether user exists or not
          sp.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        googleController.success();
                        //handleAfterSignIn();
                      })));
            } else {
              // user does not exist
              sp.saveDataToFirestore(selectedTime).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        googleController.success();
                        // handleAfterSignIn();
                      })));
            }
          });
        }
      });
    }
  }

  // handling facebookauth
  // handling google sigin in
  Future handleFacebookAuth() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackbar(context, "Check your Internet connection", Colors.red);
      facebookController.reset();
    } else {
      await sp.signInWithFacebook().then((value) {
        if (sp.hasError == true) {
          openSnackbar(context, sp.errorCode.toString(), Colors.red);
          facebookController.reset();
        } else {
          // checking whether user exists or not
          sp.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        facebookController.success();
                        //handleAfterSignIn();
                      })));
            } else {
              // user does not exist
              sp.saveDataToFirestore(selectedTime).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        facebookController.success();
                        //handleAfterSignIn();
                      })));
            }
          });
        }
      });
    }
  }
}
