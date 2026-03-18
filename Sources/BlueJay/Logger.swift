import OSLog

/// A shared logger for the BlueJay package.
public enum BlueJayLog {
  /// The standard logger for BlueJay UI components.
  public static let view = Logger(subsystem: "com.hyperelephant.bluejay", category: "view")
}
