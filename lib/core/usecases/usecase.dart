import 'package:equatable/equatable.dart';

abstract class UseCase<ResultType, Params> {
  Future<dynamic> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
