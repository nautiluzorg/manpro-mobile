class ActionOption {
  final String parentCode;
  final String code;
  final String label;

  const ActionOption({
    required this.parentCode,
    required this.code,
    required this.label,
  });
}

class ActionRecord {
  final String parentCode;
  final String code;
  final String label;
  DateTime? startTime;
  DateTime? finishTime;

  ActionRecord({
    required this.parentCode,
    required this.code,
    required this.label,
    this.startTime,
    this.finishTime,
  });

  String get status {
    if (finishTime != null) return 'SELESAI';
    if (startTime != null) return 'PROSES';
    return 'MENUNGGU';
  }
}

class ActionGroup {
  final String code;
  final String label;
  final List<String> actions;

  const ActionGroup({
    required this.code,
    required this.label,
    required this.actions,
  });
}

const actionGroups = <ActionGroup>[
  ActionGroup(
    code: '1',
    label: 'WASHING MOLD DUE TO SCHEDULE',
    actions: [
      'BONGKAR PASANG MOLD',
      'WAITING TEMPERATURE',
      'TESTING MATERIAL CONSUMPTION',
      'WAITING APPROVAL MIM',
    ],
  ),
  ActionGroup(
    code: '2',
    label: 'CHANGE MOLD BASE ON WEEKLY SCHEDULE',
    actions: [
      'BONGKAR PASANG MOLD',
      'WAITING TEMPERATURE',
      'TESTING MATERIAL CONSUMPTION',
      'WAITING APPROVAL MIM',
      'WAITING MATERIAL',
      'MACHINE PROBLEM DURING TESTING',
      'QUALITY PROBLEM DURING TESTING',
    ],
  ),
  ActionGroup(
    code: '3',
    label: 'DRY ICE OR POLISHING',
    actions: [
      'CLEANING WITH DRY ICE POLISHING',
      'WAITING TEMPERATURE',
      'TESTING MATERIAL CONSUMPTION',
      'WAITING APPROVAL MIM',
    ],
  ),
  ActionGroup(
    code: '4',
    label: 'CHANGE MOLD CAUSE OTHER REASON',
    actions: [
      'BONGKAR PASANG MOLD',
      'WAITING TEMPERATURE',
      'TESTING MATERIAL CONSUMPTION',
      'WAITING APPROVAL MIM',
      'MACHINE PROBLEM DURING TESTING',
      'QUALITY PROBLEM DURING TESTING',
    ],
  ),
  ActionGroup(
    code: '5',
    label: 'WASHING MOLD DUE TO QUALITY PROBLEM',
    actions: [
      'BONGKAR PASANG MOLD',
      'WAITING TEMPERATURE',
      'TESTING MATERIAL CONSUMPTION',
      'WAITING APPROVAL MIM',
    ],
  ),
];

ActionGroup? actionGroupFor(String parentLabel) {
  for (final group in actionGroups) {
    if (group.label == parentLabel) return group;
  }
  return null;
}

List<ActionOption> actionsForGroup(String parentLabel) {
  final group = actionGroupFor(parentLabel);
  if (group == null) return const [];

  return [
    for (var index = 0; index < group.actions.length; index++)
      ActionOption(
        parentCode: group.code,
        code: '${group.code}.${index + 1}',
        label: group.actions[index],
      ),
  ];
}
