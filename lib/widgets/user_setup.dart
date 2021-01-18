import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gm/common/format.dart';
import 'package:gm/data/database_objects.dart';
import 'package:gm/data/db.dart';
import 'package:gm/view/dashboard.dart';

class CurrentUserSelection extends StatelessWidget {
  // The state of the dashboard where everythinhg is stored
  final controller = Get.find<DashboardController>();

  // Strings used for the UI
  // TODO: Move somewhere else
  static const String selectUserTooltip = 'Selecione usuario';
  static const String selectTeamTooltip = 'Selecione equipo';
  static const String selectShiftTooltip = 'Selecione turno';
  static const String selectDateTooltip = 'Selecione fecha';

  // Dropdown menu items for each user
  final userDropdownList = Db.users.values
      .map((User e) => DropdownMenuItem<User>(
            child: Text(e.toString()),
            value: e,
          ))
      .toList();

  // Dropdown menu items for each team
  static const teamDropdownList = [
    DropdownMenuItem(
      child: Text('1'),
      value: 1,
    ),
    DropdownMenuItem(
      child: Text('2'),
      value: 2,
    ),
    DropdownMenuItem(
      child: Text('3'),
      value: 3,
    ),
    DropdownMenuItem(
      child: Text('4'),
      value: 4,
    ),
    DropdownMenuItem(
      child: Text('5'),
      value: 5,
    ),
  ];

  // Dropdown menu items for each shift
  static const shiftDropdownList = [
    DropdownMenuItem(
      child: Text('M'),
      value: 1,
    ),
    DropdownMenuItem(
      child: Text('T'),
      value: 2,
    ),
    DropdownMenuItem(
      child: Text('N'),
      value: 3,
    ),
  ];

  // Calls the provided datetime picker and changes the current date used for the report
  void setDate(BuildContext context) async {
    var selected = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 365)),
        lastDate: DateTime.now().add(Duration(days: 365)));

    if (selected != null) controller.currentDate.value = selected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Obx(
            () => Tooltip(
                message: controller.locked.value
                    ? 'Desbloquear campos'
                    : 'Bloquear campos',
                child: IconButton(
                    icon: controller.locked.value
                        ? Icon(Icons.lock)
                        : Icon(Icons.lock_open),
                    onPressed: () {
                      controller.locked.toggle();
                    })),
          ),
          Tooltip(
            message: selectUserTooltip,
            child: Obx(
              () => DropdownButton(
                onChanged: controller.locked.value
                    ? null
                    : (value) => controller.currentUser.value = value,
                value: controller.currentUser.value.key == null
                    ? null
                    : controller.currentUser.value,
                items: userDropdownList,
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Tooltip(
            message: selectTeamTooltip,
            child: Obx(() => DropdownButton(
                  onChanged: controller.locked.value
                      ? null
                      : (value) => controller.team.value = value,
                  value:
                      controller.team.value == 0 ? null : controller.team.value,
                  items: teamDropdownList,
                )),
          ),
          SizedBox(
            width: 8,
          ),
          Obx(() => FlatButton.icon(
              onPressed:
                  controller.locked.value ? null : () => setDate(context),
              icon: Icon(Icons.calendar_today),
              label:
                  Text('${DateFormatters.dmy(controller.currentDate.value)}'))),
          SizedBox(
            width: 8,
          ),
          Tooltip(
            message: selectShiftTooltip,
            child: Obx(() => DropdownButton(
                  onChanged: controller.locked.value
                      ? null
                      : (value) {
                          controller.shift.value = value;
                        },
                  value: controller.shift.value == 0
                      ? null
                      : controller.shift.value,
                  items: shiftDropdownList,
                )),
          ),
        ],
      ),
    );
  }
}
