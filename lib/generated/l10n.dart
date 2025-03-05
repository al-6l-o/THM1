// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Tele Health Monitoring`
  String get app_title {
    return Intl.message(
      'Tele Health Monitoring',
      name: 'app_title',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Dark Mode`
  String get dark_mode {
    return Intl.message('Dark Mode', name: 'dark_mode', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `About App`
  String get about_app {
    return Intl.message('About App', name: 'about_app', desc: '', args: []);
  }

  /// `Rate the App`
  String get rate_app {
    return Intl.message('Rate the App', name: 'rate_app', desc: '', args: []);
  }

  /// `Select Language`
  String get select_language {
    return Intl.message(
      'Select Language',
      name: 'select_language',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Arabic`
  String get arabic {
    return Intl.message('Arabic', name: 'arabic', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `App Settings`
  String get app_settings {
    return Intl.message(
      'App Settings',
      name: 'app_settings',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message('Version', name: 'version', desc: '', args: []);
  }

  /// `Developed By`
  String get developedBy {
    return Intl.message(
      'Developed By',
      name: 'developedBy',
      desc: '',
      args: [],
    );
  }

  /// ` Close`
  String get close {
    return Intl.message(' Close', name: 'close', desc: '', args: []);
  }

  /// ` Average Rating`
  String get average_rating {
    return Intl.message(
      ' Average Rating',
      name: 'average_rating',
      desc: '',
      args: [],
    );
  }

  /// `added successfully`
  String get added_successfully {
    return Intl.message(
      'added successfully',
      name: 'added_successfully',
      desc: '',
      args: [],
    );
  }

  /// ` Bed deleted successfully!`
  String get deleted_successfully {
    return Intl.message(
      ' Bed deleted successfully!',
      name: 'deleted_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delet this bed?`
  String get confirm_deleted_bed {
    return Intl.message(
      'Are you sure you want to delet this bed?',
      name: 'confirm_deleted_bed',
      desc: '',
      args: [],
    );
  }

  /// `Delet`
  String get delet {
    return Intl.message('Delet', name: 'delet', desc: '', args: []);
  }

  /// `Maximum number of beds reached!`
  String get maximum_beds_reached {
    return Intl.message(
      'Maximum number of beds reached!',
      name: 'maximum_beds_reached',
      desc: '',
      args: [],
    );
  }

  /// `Add patient`
  String get add_patient {
    return Intl.message('Add patient', name: 'add_patient', desc: '', args: []);
  }

  /// `Bed Number`
  String get bed_number {
    return Intl.message('Bed Number', name: 'bed_number', desc: '', args: []);
  }

  /// `Please enter the bed number`
  String get please_bed_number {
    return Intl.message(
      'Please enter the bed number',
      name: 'please_bed_number',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Please enter a name`
  String get please_name {
    return Intl.message(
      'Please enter a name',
      name: 'please_name',
      desc: '',
      args: [],
    );
  }

  /// `Age`
  String get age {
    return Intl.message('Age', name: 'age', desc: '', args: []);
  }

  /// `Please enter age`
  String get please_age {
    return Intl.message(
      'Please enter age',
      name: 'please_age',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message('Gender', name: 'gender', desc: '', args: []);
  }

  /// `Male`
  String get male {
    return Intl.message('Male', name: 'male', desc: '', args: []);
  }

  /// `Female`
  String get female {
    return Intl.message('Female', name: 'female', desc: '', args: []);
  }

  /// `Phone Number`
  String get phone_number {
    return Intl.message(
      'Phone Number',
      name: 'phone_number',
      desc: '',
      args: [],
    );
  }

  /// `+967`
  String get pre {
    return Intl.message('+967', name: 'pre', desc: '', args: []);
  }

  /// `Please enter phone number`
  String get please_phone {
    return Intl.message(
      'Please enter phone number',
      name: 'please_phone',
      desc: '',
      args: [],
    );
  }

  /// `Phone number must be 9 digits`
  String get phone_9 {
    return Intl.message(
      'Phone number must be 9 digits',
      name: 'phone_9',
      desc: '',
      args: [],
    );
  }

  /// `Bed number already exists!`
  String get bed_exists {
    return Intl.message(
      'Bed number already exists!',
      name: 'bed_exists',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `There are no beds added yet!`
  String get no_beds_yet {
    return Intl.message(
      'There are no beds added yet!',
      name: 'no_beds_yet',
      desc: '',
      args: [],
    );
  }

  /// `Bed`
  String get bed {
    return Intl.message('Bed', name: 'bed', desc: '', args: []);
  }

  /// `Exit App`
  String get exit_app {
    return Intl.message('Exit App', name: 'exit_app', desc: '', args: []);
  }

  /// `Are you sure you want to exit?`
  String get confirm_exit {
    return Intl.message(
      'Are you sure you want to exit?',
      name: 'confirm_exit',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Updated successfully!`
  String get updated_successfully {
    return Intl.message(
      'Updated successfully!',
      name: 'updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Update failed`
  String get update_failed {
    return Intl.message(
      'Update failed',
      name: 'update_failed',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Another Number`
  String get enter_another_number {
    return Intl.message(
      'Please Enter Another Number',
      name: 'enter_another_number',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message('Ok', name: 'ok', desc: '', args: []);
  }

  /// `Patient Informatins`
  String get patient_informatins {
    return Intl.message(
      'Patient Informatins',
      name: 'patient_informatins',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Vital Signs`
  String get vital_signs {
    return Intl.message('Vital Signs', name: 'vital_signs', desc: '', args: []);
  }

  /// `Patient Settings`
  String get patient_settings {
    return Intl.message(
      'Patient Settings',
      name: 'patient_settings',
      desc: '',
      args: [],
    );
  }

  /// `Patient ID`
  String get patient_id {
    return Intl.message('Patient ID', name: 'patient_id', desc: '', args: []);
  }

  /// `Please enter patient ID`
  String get please_id {
    return Intl.message(
      'Please enter patient ID',
      name: 'please_id',
      desc: '',
      args: [],
    );
  }

  /// `Doctor Name`
  String get doctor_name {
    return Intl.message('Doctor Name', name: 'doctor_name', desc: '', args: []);
  }

  /// `Please enter doctor name`
  String get please_doctor_name {
    return Intl.message(
      'Please enter doctor name',
      name: 'please_doctor_name',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
