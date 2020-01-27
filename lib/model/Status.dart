import 'package:flutter/foundation.dart';

enum Status {
  COMPLETED,
  READING,
  PLAN_TO_READ
}

Status statusFromString(String str) {
  return Status.values.firstWhere((status) => describeEnum(status) == str);
}

String statusToPrettyString(Status status) {
  switch (status) {
    case Status.COMPLETED: {
      return 'Completed';
    }
    case Status.READING: {
      return 'Reading';
    }
    case Status.PLAN_TO_READ: {
      return 'Plan to Read';
    }
    default: {
      return describeEnum(status);
    }
  }
}