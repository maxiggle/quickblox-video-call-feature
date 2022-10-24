import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickblox_video/features/select_user/bloc/select_user_bloc.dart';

class ReceiveCallDialog extends StatelessWidget {
  const ReceiveCallDialog({
    Key? key,
    required this.initiatorId,
    required this.sessionId,
  }) : super(key: key);

  final int initiatorId;
  final String sessionId;

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
              'Accept call from $initiatorId',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  context
                      .read<SelectUserBloc>()
                      .add(SelectUserAcceptCall(sessionId));
                },
                icon: const Icon(Icons.call, color: Colors.green),
              ),
              const SizedBox(width: 32),
              IconButton(
                onPressed: () {
                  context
                      .read<SelectUserBloc>()
                      .add(SelectUserRejectCall(sessionId));
                },
                icon: Icon(
                  Icons.call_end,
                  color: Theme.of(context).errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
