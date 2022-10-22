import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickblox_sdk/models/qb_user.dart';

import '../bloc/select_user_bloc.dart';
import '../widgets/widgets.dart';

class SelectUserPage extends StatelessWidget {
  const SelectUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<SelectUserBloc, bool>(
      (_) => _.state.isLoading,
    );

    final users = context.select<SelectUserBloc, List<QBUser?>>(
      (_) => _.state.users,
    );

    return BlocListener<SelectUserBloc, SelectUserState>(
      listenWhen: (prev, cur) => prev.callState != cur.callState,
      listener: (context, state) {
        if (state.callState == CallState.makingCall) {
          showDialog(
            context: context,
            builder: (context) => MakeCallDialog(session: state.callSession),
          ).then((value) {
            context
                .read<SelectUserBloc>()
                .add(const SelectUserUpdateCallState(CallState.none));
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Select a user to call')),
        body: SafeArea(
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 32),
                  itemCount: users.length,
                  itemBuilder: (context, index) => Card(
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(users[index]?.fullName ?? 'Username'),
                            leading: const Icon(Icons.person),
                          ),
                        ),
                        IconButton(
                          onPressed: () => context
                              .read<SelectUserBloc>()
                              .add(SelectUserCallUser(users[index])),
                          icon: const Icon(Icons.call),
                        )
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
