/// Constants values for app customization

import 'package:flutter/material.dart';


class Strings {
  static const String Title = 'Unicon 20';
  static const String DrawTitle = 'Unicon';
}

class AppColors {
  static const green = 0xff006A34;
  static const blue = 0xff1D2B5A;
  static const light_blue = 0xff0B73B1;
  static const lighter_blue = 0xff05DCAD;
  static const dark_blue = 0xff192945;
}

/// WordPress base URL (fetched from env to ease development)
const wordpress_host = String.fromEnvironment('WP_HOST', defaultValue: 'https://unicon20.fr');

/// Base endpoint
const api_path = '/wp-json/wp/v2';

/// Calendars
const Map<String, Map<String, dynamic>> calendars = {
  'admin': {
    'url': 'https://calendar.google.com/calendar/ical/j39mlonvmepkdc4797nk88f7ok%40group.calendar.google.com/public/basic.ics',
    'color': Colors.grey
  },
  'freestyle': {
    'url': 'https://calendar.google.com/calendar/ical/4e19oc9m4f7jnfrt1c7hm3lekc%40group.calendar.google.com/public/basic.ics',
    'color': Color(0xff807EAE)
  },
  'muni': {
    'url': 'https://calendar.google.com/calendar/ical/o0n78b4n7ssq326obekeasbf8k%40group.calendar.google.com/public/basic.ics',
    'color': Color(0xffD3E6ED)
  },
  'road': {
    'url': 'https://calendar.google.com/calendar/ical/f53rlq1p3jcm4tf3jguaj1a5ss%40group.calendar.google.com/public/basic.ics',
    'color': Color(0xff639750)
  },
  'team': {
    'url': 'https://calendar.google.com/calendar/ical/sb5l8ble394dohk4kdfnnsarlg%40group.calendar.google.com/public/basic.ics',
    'color': Color(0xffEF7057)
  },
  'track': {
    'url': 'https://calendar.google.com/calendar/ical/4lbqed8as0a1c2gaes252amn8k%40group.calendar.google.com/public/basic.ics',
    'color': Color(0xff639750)
  },
  'urban': {
    'url': 'https://calendar.google.com/calendar/ical/55rrt700v8beo61h185cfptu5k%40group.calendar.google.com/public/basic.ics',
    'color': Color(0xffFFEC6E)
  },
  'workshop': {
    'url': 'https://calendar.google.com/calendar/ical/acg4v7l8j9i8li8mfg29i2758g%40group.calendar.google.com/public/basic.ics',
    'color': Color(0xffEF7057)
  }
};

/// URL to fetch last update date of each calendar
const calendar_check_url = 'https://unicon20-app-doc.lpo.host/app_calendars/';

/// Locales used in wordpress translation
/// first is locale, second country code
const supported_locales = [
  ['en', 'US'],
  ['fr', 'FR'],
  ['de', 'DE'],
  ['ja', 'JP'],
  ['ko', 'KR'],
  ['es', 'ES'],
  ['it', 'IT']
];

/// UTC offset of timezone where events take place
const calendar_utc_offset = {'hour': 1, 'minute': 0};

/// Show year for events after this year
const event_year = 2022;

/// Notifications channel for Android if post category doesn't match with those configured under
const default_notif_channel_slug = 'unicon20';
const default_notif_channel_name = 'UNICON20';

/// Categories and priority
/// Only top priority category will be shown for each articles
const categories_weight = {
  'important': 10,
  'information': 5
};

const important_category_name = 'important';
