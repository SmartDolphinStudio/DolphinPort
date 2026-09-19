// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

/// Application-level constants: brand information, author details, demo data
/// and the login curve.
library;

/// Brand name for regular display.
const String kBrandName = 'DolphinPort';

/// Full brand title for the splash screen and headers, in capitals.
const String kBrandTitle = 'DOLPHINPORT';

/// Brand tagline.
const String kBrandTagline = 'Smart finance, in your pocket';

/// Author and maintainer.
const String kAuthor = 'Astraeus';

/// Studio name.
const String kStudio = 'SmartDolphin Studio';

/// Contact email, used wherever contact details are shown.
const String kContactEmail = 'smartdolphinstudio@il.com';

/// Starting balance for the demo account; fixed because there is no back end.
const double kDemoBalance = 100000000;

/// Normalised key points for the login curve (x / width, y / height).
///
/// The points come from a hand-drawn curve and are smoothed with a
/// Catmull-Rom spline. The ends are extrapolated along the tangent to the
/// screen edges so no horizontal straight segment appears.
const List<List<double>> kLoginCurvePoints = [
  [0.0228, 0.2933],
  [0.1910, 0.3378],
  [0.3922, 0.3751],
  [0.6213, 0.3578],
  [0.8474, 0.2499],
  [0.9919, 0.1588],
];
