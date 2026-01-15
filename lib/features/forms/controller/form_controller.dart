import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/form_model.dart';
import '../models/form_field_model.dart';
import '../repository/form_repository.dart';
import '../../submissions/repository/submission_repository.dart';
import '../../submissions/models/submission_model.dart';

final formListProvider = FutureProvider<List<FormModel>>((ref) async {
  final repository = ref.watch(formRepositoryProvider);
  return repository.getAllForms();
});

final formControllerProvider = Provider((ref) => FormController(ref));

class FormController {
  final Ref _ref;
  FormController(this._ref);

  Future<void> createForm(FormModel form) async {
    await _ref.read(formRepositoryProvider).saveForm(form);
    _ref.invalidate(formListProvider);
  }

  Future<void> seedDebugForms() async {
    final forms = [
      FormModel(
        id: '1', 
        title: 'Pest Scouter', 
        description: 'Record pest activity in the field', 
        fields: [
          FormFieldModel(id: 'pest_type', label: 'Pest Type', type: FieldType.text, required: true),
          FormFieldModel(id: 'count', label: 'Count', type: FieldType.number),
          FormFieldModel(id: 'location', label: 'Location', type: FieldType.text),
        ]
      ),
      FormModel(
        id: '2', 
        title: 'Crop Health Inspector', 
        description: 'General crop health assessment', 
        fields: [
          FormFieldModel(id: 'crop_height', label: 'Crop Height (cm)', type: FieldType.number),
          FormFieldModel(id: 'leaf_color', label: 'Leaf Color', type: FieldType.dropdown, options: ['Green', 'Yellow', 'Brown']),
          FormFieldModel(id: 'photo', label: 'Photo', type: FieldType.photo),
        ]
      ),
    ];

    for (var form in forms) {
      await createForm(form);
    }
  }

  Future<void> seedGovernmentForms() async {
    final forms = [
      FormModel(
        id: 'gov_building_inspection',
        title: 'Building Inspection Form',
        description: 'Official building safety and compliance inspection',
        fields: [
          FormFieldModel(id: 'inspector_name', label: 'Inspector Name', type: FieldType.text, required: true),
          FormFieldModel(id: 'inspection_date', label: 'Inspection Date', type: FieldType.date, required: true),
          FormFieldModel(id: 'building_address', label: 'Building Address', type: FieldType.text, required: true),
          FormFieldModel(id: 'building_type', label: 'Building Type', type: FieldType.dropdown, 
            options: ['Residential', 'Commercial', 'Industrial', 'Public'], required: true),
          FormFieldModel(id: 'floors', label: 'Number of Floors', type: FieldType.number, required: true),
          FormFieldModel(id: 'structure_condition', label: 'Structural Condition', type: FieldType.dropdown,
            options: ['Excellent', 'Good', 'Fair', 'Poor', 'Critical'], required: true),
          FormFieldModel(id: 'electrical_safety', label: 'Electrical Safety', type: FieldType.dropdown,
            options: ['Compliant', 'Non-Compliant', 'Requires Repair'], required: true),
          FormFieldModel(id: 'fire_safety', label: 'Fire Safety Equipment', type: FieldType.dropdown,
            options: ['Present and Functional', 'Present but Non-Functional', 'Absent'], required: true),
          FormFieldModel(id: 'location', label: 'GPS Location', type: FieldType.location, required: true),
          FormFieldModel(id: 'building_photo', label: 'Building Photo', type: FieldType.photo),
          FormFieldModel(id: 'notes', label: 'Additional Notes', type: FieldType.text),
        ],
      ),
      FormModel(
        id: 'gov_environmental_compliance',
        title: 'Environmental Compliance Report',
        description: 'Environmental assessment and compliance documentation',
        fields: [
          FormFieldModel(id: 'officer_name', label: 'Officer Name', type: FieldType.text, required: true),
          FormFieldModel(id: 'assessment_date', label: 'Assessment Date', type: FieldType.date, required: true),
          FormFieldModel(id: 'site_name', label: 'Site Name', type: FieldType.text, required: true),
          FormFieldModel(id: 'activity_type', label: 'Activity Type', type: FieldType.dropdown,
            options: ['Manufacturing', 'Mining', 'Agriculture', 'Construction', 'Waste Management'], required: true),
          FormFieldModel(id: 'air_quality', label: 'Air Quality Status', type: FieldType.dropdown,
            options: ['Good', 'Moderate', 'Poor', 'Hazardous'], required: true),
          FormFieldModel(id: 'water_quality', label: 'Water Quality Status', type: FieldType.dropdown,
            options: ['Safe', 'Moderate', 'Contaminated'], required: true),
          FormFieldModel(id: 'waste_management', label: 'Waste Management', type: FieldType.dropdown,
            options: ['Compliant', 'Partially Compliant', 'Non-Compliant'], required: true),
          FormFieldModel(id: 'noise_level', label: 'Noise Level (dB)', type: FieldType.number),
          FormFieldModel(id: 'location', label: 'GPS Location', type: FieldType.location, required: true),
          FormFieldModel(id: 'site_photo', label: 'Site Photo', type: FieldType.photo),
          FormFieldModel(id: 'violations', label: 'Violations Noted', type: FieldType.text),
        ],
      ),
      FormModel(
        id: 'gov_land_survey',
        title: 'Land Survey Form',
        description: 'Official land measurement and boundary documentation',
        fields: [
          FormFieldModel(id: 'surveyor_name', label: 'Surveyor Name', type: FieldType.text, required: true),
          FormFieldModel(id: 'survey_date', label: 'Survey Date', type: FieldType.date, required: true),
          FormFieldModel(id: 'property_id', label: 'Property ID/Plot Number', type: FieldType.text, required: true),
          FormFieldModel(id: 'owner_name', label: 'Owner Name', type: FieldType.text, required: true),
          FormFieldModel(id: 'land_use', label: 'Land Use Type', type: FieldType.dropdown,
            options: ['Residential', 'Agricultural', 'Commercial', 'Industrial', 'Forest'], required: true),
          FormFieldModel(id: 'area_sqm', label: 'Total Area (sq meters)', type: FieldType.number, required: true),
          FormFieldModel(id: 'boundary_markers', label: 'Boundary Markers Status', type: FieldType.dropdown,
            options: ['Clear and Present', 'Partially Present', 'Absent'], required: true),
          FormFieldModel(id: 'north_boundary', label: 'North Boundary (meters)', type: FieldType.number),
          FormFieldModel(id: 'south_boundary', label: 'South Boundary (meters)', type: FieldType.number),
          FormFieldModel(id: 'east_boundary', label: 'East Boundary (meters)', type: FieldType.number),
          FormFieldModel(id: 'west_boundary', label: 'West Boundary (meters)', type: FieldType.number),
          FormFieldModel(id: 'location', label: 'GPS Location', type: FieldType.location, required: true),
          FormFieldModel(id: 'survey_photo', label: 'Survey Photo', type: FieldType.photo),
        ],
      ),
      FormModel(
        id: 'gov_public_health',
        title: 'Public Health Inspection',
        description: 'Health and safety inspection for public facilities',
        fields: [
          FormFieldModel(id: 'inspector_name', label: 'Health Inspector Name', type: FieldType.text, required: true),
          FormFieldModel(id: 'inspection_date', label: 'Inspection Date', type: FieldType.date, required: true),
          FormFieldModel(id: 'facility_name', label: 'Facility Name', type: FieldType.text, required: true),
          FormFieldModel(id: 'facility_type', label: 'Facility Type', type: FieldType.dropdown,
            options: ['Restaurant', 'Hospital', 'School', 'Hotel', 'Market', 'Food Processing'], required: true),
          FormFieldModel(id: 'hygiene_rating', label: 'Overall Hygiene Rating', type: FieldType.dropdown,
            options: ['Excellent', 'Good', 'Satisfactory', 'Poor', 'Critical'], required: true),
          FormFieldModel(id: 'food_safety', label: 'Food Safety Compliance', type: FieldType.dropdown,
            options: ['Fully Compliant', 'Minor Issues', 'Major Issues', 'Critical Violations']),
          FormFieldModel(id: 'sanitation', label: 'Sanitation Facilities', type: FieldType.dropdown,
            options: ['Adequate', 'Needs Improvement', 'Inadequate'], required: true),
          FormFieldModel(id: 'pest_control', label: 'Pest Control', type: FieldType.dropdown,
            options: ['No Evidence', 'Minor Evidence', 'Significant Infestation']),
          FormFieldModel(id: 'water_supply', label: 'Water Supply Quality', type: FieldType.dropdown,
            options: ['Safe', 'Needs Testing', 'Unsafe'], required: true),
          FormFieldModel(id: 'location', label: 'GPS Location', type: FieldType.location, required: true),
          FormFieldModel(id: 'facility_photo', label: 'Facility Photo', type: FieldType.photo),
          FormFieldModel(id: 'violations', label: 'Violations/Recommendations', type: FieldType.text),
        ],
      ),
      FormModel(
        id: 'gov_agricultural_census',
        title: 'Agricultural Census Form',
        description: 'Agricultural land and crop data collection',
        fields: [
          FormFieldModel(id: 'enumerator_name', label: 'Enumerator Name', type: FieldType.text, required: true),
          FormFieldModel(id: 'census_date', label: 'Census Date', type: FieldType.date, required: true),
          FormFieldModel(id: 'farmer_name', label: 'Farmer Name', type: FieldType.text, required: true),
          FormFieldModel(id: 'farm_id', label: 'Farm ID/Registration Number', type: FieldType.text, required: true),
          FormFieldModel(id: 'total_land', label: 'Total Land Area (hectares)', type: FieldType.number, required: true),
          FormFieldModel(id: 'cultivated_land', label: 'Cultivated Land (hectares)', type: FieldType.number, required: true),
          FormFieldModel(id: 'primary_crop', label: 'Primary Crop', type: FieldType.dropdown,
            options: ['Rice', 'Wheat', 'Corn', 'Cotton', 'Sugarcane', 'Vegetables', 'Fruits', 'Other'], required: true),
          FormFieldModel(id: 'irrigation_type', label: 'Irrigation Type', type: FieldType.dropdown,
            options: ['Rain-fed', 'Canal', 'Tube-well', 'Drip', 'Sprinkler'], required: true),
          FormFieldModel(id: 'livestock_count', label: 'Livestock Count', type: FieldType.number),
          FormFieldModel(id: 'farm_machinery', label: 'Farm Machinery Available', type: FieldType.dropdown,
            options: ['Tractor', 'Harvester', 'Manual Tools Only', 'Multiple Equipment']),
          FormFieldModel(id: 'labor_type', label: 'Labor Type', type: FieldType.dropdown,
            options: ['Family Labor', 'Hired Labor', 'Both']),
          FormFieldModel(id: 'location', label: 'GPS Location', type: FieldType.location, required: true),
          FormFieldModel(id: 'farm_photo', label: 'Farm Photo', type: FieldType.photo),
        ],
      ),
    ];

    for (var form in forms) {
      await createForm(form);
    }
  }

  Future<void> deleteForm(String formId) async {
    await _ref.read(formRepositoryProvider).deleteForm(formId);
    _ref.invalidate(formListProvider);
  }

  Future<void> submitForm(String formId, Map<String, dynamic> data, {SyncStatus status = SyncStatus.pending}) async {
    final user = FirebaseAuth.instance.currentUser;
    final submission = SubmissionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      formId: formId,
      userId: user?.uid,
      data: data,
      createdAt: DateTime.now(),
      syncStatus: status,
    );
    await _ref.read(submissionRepositoryProvider).createSubmission(submission);
  }
}
