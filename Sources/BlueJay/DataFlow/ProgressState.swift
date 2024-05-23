//
//  File.swift
//  
//
//  Created by David Taylor on 5/22/24.
//

import Foundation

public enum ProgressState<Value, Error: Swift.Error> {
  case started
  case finished(Result<Value, Error>)
}
