import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickblox_sdk/models/qb_rtc_session.dart';
import 'package:quickblox_video/features/select_user/bloc/select_user_bloc.dart';

class MakeCallDialog extends StatelessWidget {
  const MakeCallDialog({
    Key? key,
    this.session,
  }) : super(key: key);

  final QBRTCSession? session;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Calling ${session?.opponentsIds ?? 'Ids'}',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          IconButton(
            onPressed: () {
              context.read<SelectUserBloc>().add(const SelectUserEndCall());
            },
            icon: Icon(
              Icons.call_end,
              color: Theme.of(context).errorColor,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
