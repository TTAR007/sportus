import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_text_styles.dart';
import '../../core/constants/sport_types.dart';
import '../../core/utils/validators.dart';
import '../../providers/activity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/shimmer_card.dart';
import 'widgets/activity_form_fields.dart';

/// Shared screen for creating and editing activities.
///
/// When [activityId] is null the screen is in **create** mode.
/// When [activityId] is non-null the screen pre-fills fields for **edit** mode.
class ActivityFormScreen extends ConsumerStatefulWidget {
  const ActivityFormScreen({this.activityId, super.key});

  final String? activityId;

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _maxParticipantsCtrl;

  SportType _selectedSport = SportType.football;
  DateTime? _selectedDateTime;
  String? _dateTimeError;

  bool get _isEdit => widget.activityId != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _maxParticipantsCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    super.dispose();
  }

  void _prefill(dynamic activity) {
    _titleCtrl.text = activity.title as String;
    _locationCtrl.text = activity.location as String;
    _descriptionCtrl.text = (activity.description as String?) ?? '';
    _maxParticipantsCtrl.text =
        (activity.maxParticipants as int).toString();
    _selectedSport = SportType.values.firstWhere(
      (s) => s.name == (activity.sportType as String),
      orElse: () => SportType.other,
    );
    _selectedDateTime = activity.dateTime as DateTime;
  }

  Future<void> _submit() async {
    final dateError = Validators.validateFutureDate(_selectedDateTime);
    setState(() => _dateTimeError = dateError);

    if (!_formKey.currentState!.validate() || dateError != null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final notifier = ref.read(activityFormProvider.notifier);

    if (_isEdit) {
      final result = await notifier.updateActivity(
        widget.activityId!,
        title: _titleCtrl.text.trim(),
        sportType: _selectedSport.name,
        dateTime: _selectedDateTime!,
        location: _locationCtrl.text.trim(),
        maxParticipants: int.parse(_maxParticipantsCtrl.text.trim()),
        description: _descriptionCtrl.text.trim().isEmpty
            ? null
            : _descriptionCtrl.text.trim(),
      );

      result.fold(
        (err) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(err.message)),
            );
          }
        },
        (_) {
          if (mounted) {
            ref.invalidate(activityDetailProvider(widget.activityId!));
            context.pop();
          }
        },
      );
    } else {
      final result = await notifier.createActivity(
        title: _titleCtrl.text.trim(),
        sportType: _selectedSport.name,
        dateTime: _selectedDateTime!,
        location: _locationCtrl.text.trim(),
        maxParticipants: int.parse(_maxParticipantsCtrl.text.trim()),
        description: _descriptionCtrl.text.trim().isEmpty
            ? null
            : _descriptionCtrl.text.trim(),
        hostId: user.uid,
        hostName: user.displayName ?? 'Anonymous',
      );

      result.fold(
        (err) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(err.message)),
            );
          }
        },
        (_) {
          if (mounted) context.go('/');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formState = ref.watch(activityFormProvider);

    if (_isEdit) {
      final detailAsync =
          ref.watch(activityDetailProvider(widget.activityId!));
      return detailAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit Activity')),
          body: const Padding(
            padding: EdgeInsets.all(16),
            child: ShimmerCard(count: 3),
          ),
        ),
        error: (_, _) => Scaffold(
          appBar: AppBar(title: const Text('Edit Activity')),
          body: Center(
            child: Text(
              'Could not load activity.',
              style: AppTextStyles.bodyLarge.copyWith(color: cs.onSurface),
            ),
          ),
        ),
        data: (activity) {
          if (_titleCtrl.text.isEmpty) _prefill(activity);
          return _buildScaffold(formState);
        },
      );
    }

    return _buildScaffold(formState);
  }

  Widget _buildScaffold(ActivityFormState formState) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isEdit) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          tooltip: 'Back',
        ),
        title: Text(
          _isEdit ? 'Edit Activity' : 'New Activity',
          style: AppTextStyles.headingMedium.copyWith(color: cs.onSurface),
        ),
        backgroundColor: cs.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ActivityFormFields(
        formKey: _formKey,
        titleCtrl: _titleCtrl,
        locationCtrl: _locationCtrl,
        descriptionCtrl: _descriptionCtrl,
        maxParticipantsCtrl: _maxParticipantsCtrl,
        selectedSport: _selectedSport,
        onSportChanged: (sport) =>
            setState(() => _selectedSport = sport),
        selectedDateTime: _selectedDateTime,
        dateTimeError: _dateTimeError,
        onDateTimeChanged: (dt) => setState(() {
          _selectedDateTime = dt;
          _dateTimeError = null;
        }),
        formState: formState,
        isEdit: _isEdit,
        onSubmit: _submit,
      ),
    );
  }
}
