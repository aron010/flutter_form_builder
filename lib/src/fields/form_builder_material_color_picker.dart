import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FormBuilderMaterialColorPicker extends StatefulWidget {
  final String attribute;
  final List<FormFieldValidator> validators;
  final Color initialValue;
  final bool readOnly;
  final InputDecoration decoration;
  final ValueTransformer<Color> valueTransformer;

  final ValueChanged<Color> onColorChanged;
  final bool enableLabel;
  final FormFieldSetter onSaved;

  FormBuilderMaterialColorPicker({
    Key key,
    @required this.attribute,
    @required this.onColorChanged,
    @required this.initialValue,
    // @required this.pickerColor,
    this.validators = const [],
    this.readOnly = false,
    this.decoration = const InputDecoration(),
    this.enableLabel = false,
    this.valueTransformer,
    this.onSaved,
  });

  @override
  _FormBuilderMaterialColorPickerState createState() =>
      _FormBuilderMaterialColorPickerState();
}

class _FormBuilderMaterialColorPickerState
    extends State<FormBuilderMaterialColorPicker> {
  bool _readOnly = false;
  final GlobalKey<FormFieldState> _fieldKey = GlobalKey<FormFieldState>();
  FormBuilderState _formState;
  dynamic _initialValue;

  @override
  void initState() {
    _formState = FormBuilder.of(context);
    _formState?.registerFieldKey(widget.attribute, _fieldKey);
    _initialValue = widget.initialValue ??
        (_formState.initialValue.containsKey(widget.attribute)
            ? _formState.initialValue[widget.attribute]
            : null);
    super.initState();
  }

  @override
  void dispose() {
    _formState?.unregisterFieldKey(widget.attribute);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _readOnly = (_formState?.readOnly == true) ? true : widget.readOnly;

    return FormField<Color>(
      key: _fieldKey,
      enabled: !_readOnly,
      initialValue: _initialValue,
      validator: (val) {
        for (int i = 0; i < widget.validators.length; i++) {
          if (widget.validators[i](val) != null)
            return widget.validators[i](val);
        }
        return null;
      },
      onSaved: (val) {
        var transformed;
        if (widget.valueTransformer != null) {
          transformed = widget.valueTransformer(val);
          _formState?.setAttributeValue(widget.attribute, transformed);
        } else {
          _formState?.setAttributeValue(widget.attribute, val);
        }
        if (widget.onSaved != null) {
          widget.onSaved(transformed ?? val);
        }
      },
      builder: (FormFieldState<Color> field) {
        return InkWell(
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              child: AlertDialog(
                content: SingleChildScrollView(
                  child: MaterialPicker(
                    onColorChanged: widget.onColorChanged,
                    pickerColor: widget.initialValue,
                    enableLabel: widget.enableLabel,
                  ),
                ),
              ),
            );
          },
          child: InputDecorator(
            decoration: widget.decoration.copyWith(
              errorText: field.errorText,
            ),
            child: Text(
              field.value?.value.toString() ?? "",
              style: TextStyle(
                color: field.value ?? Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
