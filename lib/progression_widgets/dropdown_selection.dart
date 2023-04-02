import 'package:flutter/material.dart';
import 'package:workout_logger_app/muscle_group.dart';

class DropdownSelection extends StatefulWidget {
  final Function(MuscleGroup) muscleGroupChanged;
  const DropdownSelection({
    Key? key,
    required this.muscleGroupChanged,
    required this.selectedGroup,
  }) : super(key: key);

  final MuscleGroup selectedGroup;

  @override
  State<DropdownSelection> createState() => _DropdownSelectionState();
}

class _DropdownSelectionState extends State<DropdownSelection> {
  final FocusNode _dropdownFocusNode = FocusNode();

  void _requestFocus() {
    setState(() {
      FocusScope.of(context).requestFocus(_dropdownFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.1, 20, MediaQuery.of(context).size.width * 0.5, 0),
      child: DropdownButtonFormField<MuscleGroup>(
        focusNode: _dropdownFocusNode,
        value: widget.selectedGroup,
        icon: const Icon(Icons.arrow_downward),
        iconEnabledColor: _dropdownFocusNode.hasFocus ? Colors.deepPurple : Colors.grey,
        iconSize: 24,
        elevation: 16,
        onTap: _requestFocus,
        onChanged: (MuscleGroup? newGroup) {
          if (newGroup != null) {
            widget.muscleGroupChanged(newGroup);
          }
        },
        // Show muscle groups except none as dropdown items
        items: MuscleGroup.values
            .where((group) => group != MuscleGroup.none)
            .map<DropdownMenuItem<MuscleGroup>>((MuscleGroup group) {
          return DropdownMenuItem<MuscleGroup>(
            value: group,
            child: Text(group.name.capitalize()),
          );
        }).toList(),
      ),
    );
  }
}
