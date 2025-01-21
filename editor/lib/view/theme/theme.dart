// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';

/// To generate
/// theme_source.jpg
/// Keyword: #FF7F31
/// Number: #00A9D1
/// String: #00B56E
class MaterialTheme {
  const MaterialTheme(this.textTheme);

  final TextTheme textTheme;

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4283194514),
      surfaceTint: Color(4283194514),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4292665855),
      onPrimaryContainer: Color(4278392651),
      secondary: Color(4284046962),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4292796921),
      onSecondaryContainer: Color(4279638828),
      tertiary: Color(4285813872),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294957046),
      onTertiaryContainer: Color(4281078314),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294637823),
      onSurface: Color(4279900961),
      onSurfaceVariant: Color(4282730063),
      outline: Color(4285953664),
      outlineVariant: Color(4291217104),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282614),
      inversePrimary: Color(4290102527),
      primaryFixed: Color(4292665855),
      onPrimaryFixed: Color(4278392651),
      primaryFixedDim: Color(4290102527),
      onPrimaryFixedVariant: Color(4281615481),
      secondaryFixed: Color(4292796921),
      onSecondaryFixed: Color(4279638828),
      secondaryFixedDim: Color(4290954717),
      onSecondaryFixedVariant: Color(4282467929),
      tertiaryFixed: Color(4294957046),
      onTertiaryFixed: Color(4281078314),
      tertiaryFixedDim: Color(4293114587),
      onTertiaryFixedVariant: Color(4284169559),
      surfaceDim: Color(4292532704),
      surfaceBright: Color(4294637823),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294243322),
      surfaceContainer: Color(4293848564),
      surfaceContainerHigh: Color(4293519343),
      surfaceContainerHighest: Color(4293124585),
    );
  }

  ThemeData light() {
    return theme(
      lightScheme(),
      EditorColors.light,
    );
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4281352308),
      surfaceTint: Color(4283194514),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4284707498),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4282204757),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4285494408),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4283906387),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4287392390),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      surface: Color(4294637823),
      onSurface: Color(4279900961),
      onSurfaceVariant: Color(4282466891),
      outline: Color(4284309095),
      outlineVariant: Color(4286151299),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282614),
      inversePrimary: Color(4290102527),
      primaryFixed: Color(4284707498),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4283062671),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4285494408),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4283915119),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4287392390),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4285682285),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292532704),
      surfaceBright: Color(4294637823),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294243322),
      surfaceContainer: Color(4293848564),
      surfaceContainerHigh: Color(4293519343),
      surfaceContainerHighest: Color(4293124585),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(
      lightMediumContrastScheme(),
      EditorColors.lightMediumContrast,
    );
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278918738),
      surfaceTint: Color(4283194514),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4281352308),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4280099123),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4282204757),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4281538865),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4283906387),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      surface: Color(4294637823),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4280427563),
      outline: Color(4282466891),
      outlineVariant: Color(4282466891),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282614),
      inversePrimary: Color(4293520383),
      primaryFixed: Color(4281352308),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4279773533),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4282204757),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4280757310),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4283906387),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4282327868),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292532704),
      surfaceBright: Color(4294637823),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294243322),
      surfaceContainer: Color(4293848564),
      surfaceContainerHigh: Color(4293519343),
      surfaceContainerHighest: Color(4293124585),
    );
  }

  ThemeData lightHighContrast() {
    return theme(
      lightHighContrastScheme(),
      EditorColors.lightHighContrast,
    );
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4290102527),
      surfaceTint: Color(4290102527),
      onPrimary: Color(4280036705),
      primaryContainer: Color(4281615481),
      onPrimaryContainer: Color(4292665855),
      secondary: Color(4290954717),
      onSecondary: Color(4281020482),
      secondaryContainer: Color(4282467929),
      onSecondaryContainer: Color(4292796921),
      tertiary: Color(4293114587),
      onTertiary: Color(4282591040),
      tertiaryContainer: Color(4284169559),
      onTertiaryContainer: Color(4294957046),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279374616),
      onSurface: Color(4293124585),
      onSurfaceVariant: Color(4291217104),
      outline: Color(4287598746),
      outlineVariant: Color(4282730063),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293124585),
      inversePrimary: Color(4283194514),
      primaryFixed: Color(4292665855),
      onPrimaryFixed: Color(4278392651),
      primaryFixedDim: Color(4290102527),
      onPrimaryFixedVariant: Color(4281615481),
      secondaryFixed: Color(4292796921),
      onSecondaryFixed: Color(4279638828),
      secondaryFixedDim: Color(4290954717),
      onSecondaryFixedVariant: Color(4282467929),
      tertiaryFixed: Color(4294957046),
      onTertiaryFixed: Color(4281078314),
      tertiaryFixedDim: Color(4293114587),
      onTertiaryFixedVariant: Color(4284169559),
      surfaceDim: Color(4279374616),
      surfaceBright: Color(4281874751),
      surfaceContainerLowest: Color(4279045651),
      surfaceContainerLow: Color(4279900961),
      surfaceContainer: Color(4280164133),
      surfaceContainerHigh: Color(4280887855),
      surfaceContainerHighest: Color(4281611322),
    );
  }

  ThemeData dark() {
    return theme(
      darkScheme(),
      EditorColors.dark,
    );
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4290497023),
      surfaceTint: Color(4290102527),
      onPrimary: Color(4278194498),
      primaryContainer: Color(4286549704),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4291218145),
      onSecondary: Color(4279309862),
      secondaryContainer: Color(4287402149),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4293378015),
      onTertiary: Color(4280683812),
      tertiaryContainer: Color(4289365411),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(4279374616),
      onSurface: Color(4294769407),
      onSurfaceVariant: Color(4291480276),
      outline: Color(4288848556),
      outlineVariant: Color(4286743180),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293124585),
      inversePrimary: Color(4281681274),
      primaryFixed: Color(4292665855),
      onPrimaryFixed: Color(4278193463),
      primaryFixedDim: Color(4290102527),
      onPrimaryFixedVariant: Color(4280496999),
      secondaryFixed: Color(4292796921),
      onSecondaryFixed: Color(4278915105),
      secondaryFixedDim: Color(4290954717),
      onSecondaryFixedVariant: Color(4281414984),
      tertiaryFixed: Color(4294957046),
      onTertiaryFixed: Color(4280289055),
      tertiaryFixedDim: Color(4293114587),
      onTertiaryFixedVariant: Color(4282985542),
      surfaceDim: Color(4279374616),
      surfaceBright: Color(4281874751),
      surfaceContainerLowest: Color(4279045651),
      surfaceContainerLow: Color(4279900961),
      surfaceContainer: Color(4280164133),
      surfaceContainerHigh: Color(4280887855),
      surfaceContainerHighest: Color(4281611322),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(
      darkMediumContrastScheme(),
      EditorColors.darkMediumContrast,
    );
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4294769407),
      surfaceTint: Color(4290102527),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4290497023),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294769407),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4291218145),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294965754),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4293378015),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      surface: Color(4279374616),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294769407),
      outline: Color(4291480276),
      outlineVariant: Color(4291480276),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293124585),
      inversePrimary: Color(4279576154),
      primaryFixed: Color(4293060351),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4290497023),
      onPrimaryFixedVariant: Color(4278194498),
      secondaryFixed: Color(4293060350),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4291218145),
      onSecondaryFixedVariant: Color(4279309862),
      tertiaryFixed: Color(4294958583),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4293378015),
      onTertiaryFixedVariant: Color(4280683812),
      surfaceDim: Color(4279374616),
      surfaceBright: Color(4281874751),
      surfaceContainerLowest: Color(4279045651),
      surfaceContainerLow: Color(4279900961),
      surfaceContainer: Color(4280164133),
      surfaceContainerHigh: Color(4280887855),
      surfaceContainerHighest: Color(4281611322),
    );
  }

  ThemeData darkHighContrast() {
    return theme(
      darkHighContrastScheme(),
      EditorColors.darkHighContrast,
    );
  }

  ThemeData theme(
    ColorScheme colorScheme,
    EditorColors editorColors,
  ) =>
      ThemeData(
          useMaterial3: true,
          brightness: colorScheme.brightness,
          colorScheme: colorScheme,
          textTheme: textTheme.apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          ),
          // ignore: deprecated_member_use
          scaffoldBackgroundColor: colorScheme.background,
          canvasColor: colorScheme.surface,
          extensions: [editorColors]);

  /// Keyword
  static const keyword = ExtendedColor(
    seed: Color(4294934321),
    value: Color(4294933856),
    light: ColorFamily(
      color: Color(4287646524),
      onColor: Color(4294967295),
      colorContainer: Color(4294957778),
      onColorContainer: Color(4281993730),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(4287646524),
      onColor: Color(4294967295),
      colorContainer: Color(4294957778),
      onColorContainer: Color(4281993730),
    ),
    lightHighContrast: ColorFamily(
      color: Color(4287646524),
      onColor: Color(4294967295),
      colorContainer: Color(4294957778),
      onColorContainer: Color(4281993730),
    ),
    dark: ColorFamily(
      color: Color(4294948004),
      onColor: Color(4283834130),
      colorContainer: Color(4285740070),
      onColorContainer: Color(4294957778),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(4294948004),
      onColor: Color(4283834130),
      colorContainer: Color(4285740070),
      onColorContainer: Color(4294957778),
    ),
    darkHighContrast: ColorFamily(
      color: Color(4294948004),
      onColor: Color(4283834130),
      colorContainer: Color(4285740070),
      onColorContainer: Color(4294957778),
    ),
  );

  /// Number
  static const number = ExtendedColor(
    seed: Color(4278233553),
    value: Color(4282033631),
    light: ColorFamily(
      color: Color(4280509576),
      onColor: Color(4294967295),
      colorContainer: Color(4291356415),
      onColorContainer: Color(4278197806),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(4280509576),
      onColor: Color(4294967295),
      colorContainer: Color(4291356415),
      onColorContainer: Color(4278197806),
    ),
    lightHighContrast: ColorFamily(
      color: Color(4280509576),
      onColor: Color(4294967295),
      colorContainer: Color(4291356415),
      onColorContainer: Color(4278197806),
    ),
    dark: ColorFamily(
      color: Color(4287876598),
      onColor: Color(4278203468),
      colorContainer: Color(4278209645),
      onColorContainer: Color(4291356415),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(4287876598),
      onColor: Color(4278203468),
      colorContainer: Color(4278209645),
      onColorContainer: Color(4291356415),
    ),
    darkHighContrast: ColorFamily(
      color: Color(4287876598),
      onColor: Color(4278203468),
      colorContainer: Color(4278209645),
      onColorContainer: Color(4291356415),
    ),
  );

  /// String
  static const string = ExtendedColor(
    seed: Color(4278236526),
    value: Color(4278236047),
    light: ColorFamily(
      color: Color(4279462741),
      onColor: Color(4294967295),
      colorContainer: Color(4288934615),
      onColorContainer: Color(4278198552),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(4279462741),
      onColor: Color(4294967295),
      colorContainer: Color(4288934615),
      onColorContainer: Color(4278198552),
    ),
    lightHighContrast: ColorFamily(
      color: Color(4279462741),
      onColor: Color(4294967295),
      colorContainer: Color(4288934615),
      onColorContainer: Color(4278198552),
    ),
    dark: ColorFamily(
      color: Color(4287157947),
      onColor: Color(4278204459),
      colorContainer: Color(4278210879),
      onColorContainer: Color(4288934615),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(4287157947),
      onColor: Color(4278204459),
      colorContainer: Color(4278210879),
      onColorContainer: Color(4288934615),
    ),
    darkHighContrast: ColorFamily(
      color: Color(4287157947),
      onColor: Color(4278204459),
      colorContainer: Color(4278210879),
      onColorContainer: Color(4288934615),
    ),
  );

  List<ExtendedColor> get extendedColors => [
        keyword,
        number,
        string,
      ];
}

class EditorColors extends ThemeExtension<EditorColors> {
  const EditorColors({
    required this.keyword,
    required this.number,
    required this.string,
  });

  final ColorFamily keyword;
  final ColorFamily number;
  final ColorFamily string;

  static final light = EditorColors(
    keyword: MaterialTheme.keyword.light,
    string: MaterialTheme.string.light,
    number: MaterialTheme.number.light,
  );
  static final lightHighContrast = EditorColors(
    keyword: MaterialTheme.keyword.lightHighContrast,
    string: MaterialTheme.string.lightHighContrast,
    number: MaterialTheme.number.lightHighContrast,
  );
  static final lightMediumContrast = EditorColors(
    keyword: MaterialTheme.keyword.lightMediumContrast,
    string: MaterialTheme.string.lightMediumContrast,
    number: MaterialTheme.number.lightMediumContrast,
  );
  static final dark = EditorColors(
    keyword: MaterialTheme.keyword.dark,
    string: MaterialTheme.string.dark,
    number: MaterialTheme.number.dark,
  );
  static final darkHighContrast = EditorColors(
    keyword: MaterialTheme.keyword.darkHighContrast,
    string: MaterialTheme.string.darkHighContrast,
    number: MaterialTheme.number.darkHighContrast,
  );
  static final darkMediumContrast = EditorColors(
    keyword: MaterialTheme.keyword.darkMediumContrast,
    string: MaterialTheme.string.darkMediumContrast,
    number: MaterialTheme.number.darkMediumContrast,
  );

  @override
  ThemeExtension<EditorColors> copyWith({
    ColorFamily? keyword,
    ColorFamily? number,
    ColorFamily? string,
  }) {
    return EditorColors(
      keyword: keyword ?? this.keyword,
      number: number ?? this.number,
      string: string ?? this.string,
    );
  }

  @override
  EditorColors lerp(
    EditorColors other,
    double t,
  ) {
    return EditorColors(
      keyword: keyword.lerp(other.keyword, t),
      number: number.lerp(other.number, t),
      string: string.lerp(other.string, t),
    );
  }
}

class ExtendedColor {
  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });

  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;

  ColorFamily lerp(ColorFamily other, double t) {
    return ColorFamily(
      color: Color.lerp(color, other.color, t)!,
      onColor: Color.lerp(onColor, other.onColor, t)!,
      colorContainer: Color.lerp(
        colorContainer,
        other.colorContainer,
        t,
      )!,
      onColorContainer: Color.lerp(
        onColorContainer,
        other.onColorContainer,
        t,
      )!,
    );
  }
}

extension ThemeExt on ThemeData {
  EditorColors get editorColors => extension<EditorColors>()!;
}
