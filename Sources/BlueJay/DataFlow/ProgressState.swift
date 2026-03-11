//
//  File.swift
//  
//
//  Created by David Taylor on 5/22/24.
//

import Foundation

/// Represents the state of an asynchronous operation.
///
/// This enum is useful for tracking the lifecycle of data fetching or
/// background tasks and updating the UI accordingly.
public enum ProgressState<Value, Error: Swift.Error> {
  /// The operation has started and is currently in progress.
  case started
  /// The operation has completed with either a success or a failure.
  case finished(Result<Value, Error>)
}
