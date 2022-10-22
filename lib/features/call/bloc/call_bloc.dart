import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'call_event.dart';
part 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  CallBloc() : super(CallInitial()) {
    on<CallEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
