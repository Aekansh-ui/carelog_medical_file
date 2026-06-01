// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MembersTable extends Members with TableInfo<$MembersTable, Member> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationshipMeta = const VerificationMeta(
    'relationship',
  );
  @override
  late final GeneratedColumn<String> relationship = GeneratedColumn<String>(
    'relationship',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('OTHER'),
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<String> dateOfBirth = GeneratedColumn<String>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#1A6B8A'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    relationship,
    dateOfBirth,
    gender,
    color,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(
    Insertable<Member> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('relationship')) {
      context.handle(
        _relationshipMeta,
        relationship.isAcceptableOrUnknown(
          data['relationship']!,
          _relationshipMeta,
        ),
      );
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Member map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Member(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      relationship: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship'],
      )!,
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_of_birth'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class Member extends DataClass implements Insertable<Member> {
  final String id;
  final String name;
  final String relationship;
  final String? dateOfBirth;
  final String? gender;
  final String color;
  final String createdAt;
  final String updatedAt;
  const Member({
    required this.id,
    required this.name,
    required this.relationship,
    this.dateOfBirth,
    this.gender,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['relationship'] = Variable<String>(relationship);
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<String>(dateOfBirth);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    map['color'] = Variable<String>(color);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      name: Value(name),
      relationship: Value(relationship),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      color: Value(color),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Member.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Member(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      relationship: serializer.fromJson<String>(json['relationship']),
      dateOfBirth: serializer.fromJson<String?>(json['dateOfBirth']),
      gender: serializer.fromJson<String?>(json['gender']),
      color: serializer.fromJson<String>(json['color']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'relationship': serializer.toJson<String>(relationship),
      'dateOfBirth': serializer.toJson<String?>(dateOfBirth),
      'gender': serializer.toJson<String?>(gender),
      'color': serializer.toJson<String>(color),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Member copyWith({
    String? id,
    String? name,
    String? relationship,
    Value<String?> dateOfBirth = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    String? color,
    String? createdAt,
    String? updatedAt,
  }) => Member(
    id: id ?? this.id,
    name: name ?? this.name,
    relationship: relationship ?? this.relationship,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    gender: gender.present ? gender.value : this.gender,
    color: color ?? this.color,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Member copyWithCompanion(MembersCompanion data) {
    return Member(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      relationship: data.relationship.present
          ? data.relationship.value
          : this.relationship,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      gender: data.gender.present ? data.gender.value : this.gender,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Member(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('relationship: $relationship, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    relationship,
    dateOfBirth,
    gender,
    color,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Member &&
          other.id == this.id &&
          other.name == this.name &&
          other.relationship == this.relationship &&
          other.dateOfBirth == this.dateOfBirth &&
          other.gender == this.gender &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MembersCompanion extends UpdateCompanion<Member> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> relationship;
  final Value<String?> dateOfBirth;
  final Value<String?> gender;
  final Value<String> color;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.relationship = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.gender = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    required String id,
    required String name,
    this.relationship = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.gender = const Value.absent(),
    this.color = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Member> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? relationship,
    Expression<String>? dateOfBirth,
    Expression<String>? gender,
    Expression<String>? color,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (relationship != null) 'relationship': relationship,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? relationship,
    Value<String?>? dateOfBirth,
    Value<String?>? gender,
    Value<String>? color,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return MembersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (relationship.present) {
      map['relationship'] = Variable<String>(relationship.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<String>(dateOfBirth.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('relationship: $relationship, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitsTable extends Visits with TableInfo<$VisitsTable, Visit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyPartIdMeta = const VerificationMeta(
    'bodyPartId',
  );
  @override
  late final GeneratedColumn<String> bodyPartId = GeneratedColumn<String>(
    'body_part_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _specialityIdMeta = const VerificationMeta(
    'specialityId',
  );
  @override
  late final GeneratedColumn<String> specialityId = GeneratedColumn<String>(
    'speciality_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customSpecialityMeta = const VerificationMeta(
    'customSpeciality',
  );
  @override
  late final GeneratedColumn<String> customSpeciality = GeneratedColumn<String>(
    'custom_speciality',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visitDateMeta = const VerificationMeta(
    'visitDate',
  );
  @override
  late final GeneratedColumn<String> visitDate = GeneratedColumn<String>(
    'visit_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _followUpDateMeta = const VerificationMeta(
    'followUpDate',
  );
  @override
  late final GeneratedColumn<String> followUpDate = GeneratedColumn<String>(
    'follow_up_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doctorNameMeta = const VerificationMeta(
    'doctorName',
  );
  @override
  late final GeneratedColumn<String> doctorName = GeneratedColumn<String>(
    'doctor_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicNameMeta = const VerificationMeta(
    'clinicName',
  );
  @override
  late final GeneratedColumn<String> clinicName = GeneratedColumn<String>(
    'clinic_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicPhoneMeta = const VerificationMeta(
    'clinicPhone',
  );
  @override
  late final GeneratedColumn<String> clinicPhone = GeneratedColumn<String>(
    'clinic_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doctorFeesMeta = const VerificationMeta(
    'doctorFees',
  );
  @override
  late final GeneratedColumn<double> doctorFees = GeneratedColumn<double>(
    'doctor_fees',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INR'),
  );
  static const VerificationMeta _symptomsMeta = const VerificationMeta(
    'symptoms',
  );
  @override
  late final GeneratedColumn<String> symptoms = GeneratedColumn<String>(
    'symptoms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diagnosisMeta = const VerificationMeta(
    'diagnosis',
  );
  @override
  late final GeneratedColumn<String> diagnosis = GeneratedColumn<String>(
    'diagnosis',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES members (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bodyPartId,
    specialityId,
    customSpeciality,
    visitDate,
    followUpDate,
    doctorName,
    clinicName,
    clinicPhone,
    doctorFees,
    currency,
    symptoms,
    diagnosis,
    notes,
    memberId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Visit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('body_part_id')) {
      context.handle(
        _bodyPartIdMeta,
        bodyPartId.isAcceptableOrUnknown(
          data['body_part_id']!,
          _bodyPartIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bodyPartIdMeta);
    }
    if (data.containsKey('speciality_id')) {
      context.handle(
        _specialityIdMeta,
        specialityId.isAcceptableOrUnknown(
          data['speciality_id']!,
          _specialityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_specialityIdMeta);
    }
    if (data.containsKey('custom_speciality')) {
      context.handle(
        _customSpecialityMeta,
        customSpeciality.isAcceptableOrUnknown(
          data['custom_speciality']!,
          _customSpecialityMeta,
        ),
      );
    }
    if (data.containsKey('visit_date')) {
      context.handle(
        _visitDateMeta,
        visitDate.isAcceptableOrUnknown(data['visit_date']!, _visitDateMeta),
      );
    } else if (isInserting) {
      context.missing(_visitDateMeta);
    }
    if (data.containsKey('follow_up_date')) {
      context.handle(
        _followUpDateMeta,
        followUpDate.isAcceptableOrUnknown(
          data['follow_up_date']!,
          _followUpDateMeta,
        ),
      );
    }
    if (data.containsKey('doctor_name')) {
      context.handle(
        _doctorNameMeta,
        doctorName.isAcceptableOrUnknown(data['doctor_name']!, _doctorNameMeta),
      );
    }
    if (data.containsKey('clinic_name')) {
      context.handle(
        _clinicNameMeta,
        clinicName.isAcceptableOrUnknown(data['clinic_name']!, _clinicNameMeta),
      );
    }
    if (data.containsKey('clinic_phone')) {
      context.handle(
        _clinicPhoneMeta,
        clinicPhone.isAcceptableOrUnknown(
          data['clinic_phone']!,
          _clinicPhoneMeta,
        ),
      );
    }
    if (data.containsKey('doctor_fees')) {
      context.handle(
        _doctorFeesMeta,
        doctorFees.isAcceptableOrUnknown(data['doctor_fees']!, _doctorFeesMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('symptoms')) {
      context.handle(
        _symptomsMeta,
        symptoms.isAcceptableOrUnknown(data['symptoms']!, _symptomsMeta),
      );
    }
    if (data.containsKey('diagnosis')) {
      context.handle(
        _diagnosisMeta,
        diagnosis.isAcceptableOrUnknown(data['diagnosis']!, _diagnosisMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Visit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Visit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bodyPartId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_part_id'],
      )!,
      specialityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}speciality_id'],
      )!,
      customSpeciality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_speciality'],
      ),
      visitDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_date'],
      )!,
      followUpDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}follow_up_date'],
      ),
      doctorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doctor_name'],
      ),
      clinicName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_name'],
      ),
      clinicPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_phone'],
      ),
      doctorFees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}doctor_fees'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      symptoms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms'],
      ),
      diagnosis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diagnosis'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VisitsTable createAlias(String alias) {
    return $VisitsTable(attachedDatabase, alias);
  }
}

class Visit extends DataClass implements Insertable<Visit> {
  final String id;
  final String bodyPartId;
  final String specialityId;
  final String? customSpeciality;
  final String visitDate;
  final String? followUpDate;
  final String? doctorName;
  final String? clinicName;
  final String? clinicPhone;
  final double? doctorFees;
  final String currency;
  final String? symptoms;
  final String? diagnosis;
  final String? notes;
  final String? memberId;
  final String createdAt;
  final String updatedAt;
  const Visit({
    required this.id,
    required this.bodyPartId,
    required this.specialityId,
    this.customSpeciality,
    required this.visitDate,
    this.followUpDate,
    this.doctorName,
    this.clinicName,
    this.clinicPhone,
    this.doctorFees,
    required this.currency,
    this.symptoms,
    this.diagnosis,
    this.notes,
    this.memberId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['body_part_id'] = Variable<String>(bodyPartId);
    map['speciality_id'] = Variable<String>(specialityId);
    if (!nullToAbsent || customSpeciality != null) {
      map['custom_speciality'] = Variable<String>(customSpeciality);
    }
    map['visit_date'] = Variable<String>(visitDate);
    if (!nullToAbsent || followUpDate != null) {
      map['follow_up_date'] = Variable<String>(followUpDate);
    }
    if (!nullToAbsent || doctorName != null) {
      map['doctor_name'] = Variable<String>(doctorName);
    }
    if (!nullToAbsent || clinicName != null) {
      map['clinic_name'] = Variable<String>(clinicName);
    }
    if (!nullToAbsent || clinicPhone != null) {
      map['clinic_phone'] = Variable<String>(clinicPhone);
    }
    if (!nullToAbsent || doctorFees != null) {
      map['doctor_fees'] = Variable<double>(doctorFees);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || symptoms != null) {
      map['symptoms'] = Variable<String>(symptoms);
    }
    if (!nullToAbsent || diagnosis != null) {
      map['diagnosis'] = Variable<String>(diagnosis);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<String>(memberId);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  VisitsCompanion toCompanion(bool nullToAbsent) {
    return VisitsCompanion(
      id: Value(id),
      bodyPartId: Value(bodyPartId),
      specialityId: Value(specialityId),
      customSpeciality: customSpeciality == null && nullToAbsent
          ? const Value.absent()
          : Value(customSpeciality),
      visitDate: Value(visitDate),
      followUpDate: followUpDate == null && nullToAbsent
          ? const Value.absent()
          : Value(followUpDate),
      doctorName: doctorName == null && nullToAbsent
          ? const Value.absent()
          : Value(doctorName),
      clinicName: clinicName == null && nullToAbsent
          ? const Value.absent()
          : Value(clinicName),
      clinicPhone: clinicPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(clinicPhone),
      doctorFees: doctorFees == null && nullToAbsent
          ? const Value.absent()
          : Value(doctorFees),
      currency: Value(currency),
      symptoms: symptoms == null && nullToAbsent
          ? const Value.absent()
          : Value(symptoms),
      diagnosis: diagnosis == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosis),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Visit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Visit(
      id: serializer.fromJson<String>(json['id']),
      bodyPartId: serializer.fromJson<String>(json['bodyPartId']),
      specialityId: serializer.fromJson<String>(json['specialityId']),
      customSpeciality: serializer.fromJson<String?>(json['customSpeciality']),
      visitDate: serializer.fromJson<String>(json['visitDate']),
      followUpDate: serializer.fromJson<String?>(json['followUpDate']),
      doctorName: serializer.fromJson<String?>(json['doctorName']),
      clinicName: serializer.fromJson<String?>(json['clinicName']),
      clinicPhone: serializer.fromJson<String?>(json['clinicPhone']),
      doctorFees: serializer.fromJson<double?>(json['doctorFees']),
      currency: serializer.fromJson<String>(json['currency']),
      symptoms: serializer.fromJson<String?>(json['symptoms']),
      diagnosis: serializer.fromJson<String?>(json['diagnosis']),
      notes: serializer.fromJson<String?>(json['notes']),
      memberId: serializer.fromJson<String?>(json['memberId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bodyPartId': serializer.toJson<String>(bodyPartId),
      'specialityId': serializer.toJson<String>(specialityId),
      'customSpeciality': serializer.toJson<String?>(customSpeciality),
      'visitDate': serializer.toJson<String>(visitDate),
      'followUpDate': serializer.toJson<String?>(followUpDate),
      'doctorName': serializer.toJson<String?>(doctorName),
      'clinicName': serializer.toJson<String?>(clinicName),
      'clinicPhone': serializer.toJson<String?>(clinicPhone),
      'doctorFees': serializer.toJson<double?>(doctorFees),
      'currency': serializer.toJson<String>(currency),
      'symptoms': serializer.toJson<String?>(symptoms),
      'diagnosis': serializer.toJson<String?>(diagnosis),
      'notes': serializer.toJson<String?>(notes),
      'memberId': serializer.toJson<String?>(memberId),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Visit copyWith({
    String? id,
    String? bodyPartId,
    String? specialityId,
    Value<String?> customSpeciality = const Value.absent(),
    String? visitDate,
    Value<String?> followUpDate = const Value.absent(),
    Value<String?> doctorName = const Value.absent(),
    Value<String?> clinicName = const Value.absent(),
    Value<String?> clinicPhone = const Value.absent(),
    Value<double?> doctorFees = const Value.absent(),
    String? currency,
    Value<String?> symptoms = const Value.absent(),
    Value<String?> diagnosis = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> memberId = const Value.absent(),
    String? createdAt,
    String? updatedAt,
  }) => Visit(
    id: id ?? this.id,
    bodyPartId: bodyPartId ?? this.bodyPartId,
    specialityId: specialityId ?? this.specialityId,
    customSpeciality: customSpeciality.present
        ? customSpeciality.value
        : this.customSpeciality,
    visitDate: visitDate ?? this.visitDate,
    followUpDate: followUpDate.present ? followUpDate.value : this.followUpDate,
    doctorName: doctorName.present ? doctorName.value : this.doctorName,
    clinicName: clinicName.present ? clinicName.value : this.clinicName,
    clinicPhone: clinicPhone.present ? clinicPhone.value : this.clinicPhone,
    doctorFees: doctorFees.present ? doctorFees.value : this.doctorFees,
    currency: currency ?? this.currency,
    symptoms: symptoms.present ? symptoms.value : this.symptoms,
    diagnosis: diagnosis.present ? diagnosis.value : this.diagnosis,
    notes: notes.present ? notes.value : this.notes,
    memberId: memberId.present ? memberId.value : this.memberId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Visit copyWithCompanion(VisitsCompanion data) {
    return Visit(
      id: data.id.present ? data.id.value : this.id,
      bodyPartId: data.bodyPartId.present
          ? data.bodyPartId.value
          : this.bodyPartId,
      specialityId: data.specialityId.present
          ? data.specialityId.value
          : this.specialityId,
      customSpeciality: data.customSpeciality.present
          ? data.customSpeciality.value
          : this.customSpeciality,
      visitDate: data.visitDate.present ? data.visitDate.value : this.visitDate,
      followUpDate: data.followUpDate.present
          ? data.followUpDate.value
          : this.followUpDate,
      doctorName: data.doctorName.present
          ? data.doctorName.value
          : this.doctorName,
      clinicName: data.clinicName.present
          ? data.clinicName.value
          : this.clinicName,
      clinicPhone: data.clinicPhone.present
          ? data.clinicPhone.value
          : this.clinicPhone,
      doctorFees: data.doctorFees.present
          ? data.doctorFees.value
          : this.doctorFees,
      currency: data.currency.present ? data.currency.value : this.currency,
      symptoms: data.symptoms.present ? data.symptoms.value : this.symptoms,
      diagnosis: data.diagnosis.present ? data.diagnosis.value : this.diagnosis,
      notes: data.notes.present ? data.notes.value : this.notes,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Visit(')
          ..write('id: $id, ')
          ..write('bodyPartId: $bodyPartId, ')
          ..write('specialityId: $specialityId, ')
          ..write('customSpeciality: $customSpeciality, ')
          ..write('visitDate: $visitDate, ')
          ..write('followUpDate: $followUpDate, ')
          ..write('doctorName: $doctorName, ')
          ..write('clinicName: $clinicName, ')
          ..write('clinicPhone: $clinicPhone, ')
          ..write('doctorFees: $doctorFees, ')
          ..write('currency: $currency, ')
          ..write('symptoms: $symptoms, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('notes: $notes, ')
          ..write('memberId: $memberId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bodyPartId,
    specialityId,
    customSpeciality,
    visitDate,
    followUpDate,
    doctorName,
    clinicName,
    clinicPhone,
    doctorFees,
    currency,
    symptoms,
    diagnosis,
    notes,
    memberId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Visit &&
          other.id == this.id &&
          other.bodyPartId == this.bodyPartId &&
          other.specialityId == this.specialityId &&
          other.customSpeciality == this.customSpeciality &&
          other.visitDate == this.visitDate &&
          other.followUpDate == this.followUpDate &&
          other.doctorName == this.doctorName &&
          other.clinicName == this.clinicName &&
          other.clinicPhone == this.clinicPhone &&
          other.doctorFees == this.doctorFees &&
          other.currency == this.currency &&
          other.symptoms == this.symptoms &&
          other.diagnosis == this.diagnosis &&
          other.notes == this.notes &&
          other.memberId == this.memberId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VisitsCompanion extends UpdateCompanion<Visit> {
  final Value<String> id;
  final Value<String> bodyPartId;
  final Value<String> specialityId;
  final Value<String?> customSpeciality;
  final Value<String> visitDate;
  final Value<String?> followUpDate;
  final Value<String?> doctorName;
  final Value<String?> clinicName;
  final Value<String?> clinicPhone;
  final Value<double?> doctorFees;
  final Value<String> currency;
  final Value<String?> symptoms;
  final Value<String?> diagnosis;
  final Value<String?> notes;
  final Value<String?> memberId;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const VisitsCompanion({
    this.id = const Value.absent(),
    this.bodyPartId = const Value.absent(),
    this.specialityId = const Value.absent(),
    this.customSpeciality = const Value.absent(),
    this.visitDate = const Value.absent(),
    this.followUpDate = const Value.absent(),
    this.doctorName = const Value.absent(),
    this.clinicName = const Value.absent(),
    this.clinicPhone = const Value.absent(),
    this.doctorFees = const Value.absent(),
    this.currency = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.diagnosis = const Value.absent(),
    this.notes = const Value.absent(),
    this.memberId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitsCompanion.insert({
    required String id,
    required String bodyPartId,
    required String specialityId,
    this.customSpeciality = const Value.absent(),
    required String visitDate,
    this.followUpDate = const Value.absent(),
    this.doctorName = const Value.absent(),
    this.clinicName = const Value.absent(),
    this.clinicPhone = const Value.absent(),
    this.doctorFees = const Value.absent(),
    this.currency = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.diagnosis = const Value.absent(),
    this.notes = const Value.absent(),
    this.memberId = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bodyPartId = Value(bodyPartId),
       specialityId = Value(specialityId),
       visitDate = Value(visitDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Visit> custom({
    Expression<String>? id,
    Expression<String>? bodyPartId,
    Expression<String>? specialityId,
    Expression<String>? customSpeciality,
    Expression<String>? visitDate,
    Expression<String>? followUpDate,
    Expression<String>? doctorName,
    Expression<String>? clinicName,
    Expression<String>? clinicPhone,
    Expression<double>? doctorFees,
    Expression<String>? currency,
    Expression<String>? symptoms,
    Expression<String>? diagnosis,
    Expression<String>? notes,
    Expression<String>? memberId,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bodyPartId != null) 'body_part_id': bodyPartId,
      if (specialityId != null) 'speciality_id': specialityId,
      if (customSpeciality != null) 'custom_speciality': customSpeciality,
      if (visitDate != null) 'visit_date': visitDate,
      if (followUpDate != null) 'follow_up_date': followUpDate,
      if (doctorName != null) 'doctor_name': doctorName,
      if (clinicName != null) 'clinic_name': clinicName,
      if (clinicPhone != null) 'clinic_phone': clinicPhone,
      if (doctorFees != null) 'doctor_fees': doctorFees,
      if (currency != null) 'currency': currency,
      if (symptoms != null) 'symptoms': symptoms,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (notes != null) 'notes': notes,
      if (memberId != null) 'member_id': memberId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitsCompanion copyWith({
    Value<String>? id,
    Value<String>? bodyPartId,
    Value<String>? specialityId,
    Value<String?>? customSpeciality,
    Value<String>? visitDate,
    Value<String?>? followUpDate,
    Value<String?>? doctorName,
    Value<String?>? clinicName,
    Value<String?>? clinicPhone,
    Value<double?>? doctorFees,
    Value<String>? currency,
    Value<String?>? symptoms,
    Value<String?>? diagnosis,
    Value<String?>? notes,
    Value<String?>? memberId,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return VisitsCompanion(
      id: id ?? this.id,
      bodyPartId: bodyPartId ?? this.bodyPartId,
      specialityId: specialityId ?? this.specialityId,
      customSpeciality: customSpeciality ?? this.customSpeciality,
      visitDate: visitDate ?? this.visitDate,
      followUpDate: followUpDate ?? this.followUpDate,
      doctorName: doctorName ?? this.doctorName,
      clinicName: clinicName ?? this.clinicName,
      clinicPhone: clinicPhone ?? this.clinicPhone,
      doctorFees: doctorFees ?? this.doctorFees,
      currency: currency ?? this.currency,
      symptoms: symptoms ?? this.symptoms,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      memberId: memberId ?? this.memberId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bodyPartId.present) {
      map['body_part_id'] = Variable<String>(bodyPartId.value);
    }
    if (specialityId.present) {
      map['speciality_id'] = Variable<String>(specialityId.value);
    }
    if (customSpeciality.present) {
      map['custom_speciality'] = Variable<String>(customSpeciality.value);
    }
    if (visitDate.present) {
      map['visit_date'] = Variable<String>(visitDate.value);
    }
    if (followUpDate.present) {
      map['follow_up_date'] = Variable<String>(followUpDate.value);
    }
    if (doctorName.present) {
      map['doctor_name'] = Variable<String>(doctorName.value);
    }
    if (clinicName.present) {
      map['clinic_name'] = Variable<String>(clinicName.value);
    }
    if (clinicPhone.present) {
      map['clinic_phone'] = Variable<String>(clinicPhone.value);
    }
    if (doctorFees.present) {
      map['doctor_fees'] = Variable<double>(doctorFees.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (symptoms.present) {
      map['symptoms'] = Variable<String>(symptoms.value);
    }
    if (diagnosis.present) {
      map['diagnosis'] = Variable<String>(diagnosis.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCompanion(')
          ..write('id: $id, ')
          ..write('bodyPartId: $bodyPartId, ')
          ..write('specialityId: $specialityId, ')
          ..write('customSpeciality: $customSpeciality, ')
          ..write('visitDate: $visitDate, ')
          ..write('followUpDate: $followUpDate, ')
          ..write('doctorName: $doctorName, ')
          ..write('clinicName: $clinicName, ')
          ..write('clinicPhone: $clinicPhone, ')
          ..write('doctorFees: $doctorFees, ')
          ..write('currency: $currency, ')
          ..write('symptoms: $symptoms, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('notes: $notes, ')
          ..write('memberId: $memberId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES visits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    visitId,
    type,
    filePath,
    fileName,
    mimeType,
    sizeBytes,
    thumbnailPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final String id;
  final String visitId;
  final String type;
  final String filePath;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String? thumbnailPath;
  final String createdAt;
  const Attachment({
    required this.id,
    required this.visitId,
    required this.type,
    required this.filePath,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.thumbnailPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['visit_id'] = Variable<String>(visitId);
    map['type'] = Variable<String>(type);
    map['file_path'] = Variable<String>(filePath);
    map['file_name'] = Variable<String>(fileName);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      visitId: Value(visitId),
      type: Value(type),
      filePath: Value(filePath),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      createdAt: Value(createdAt),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<String>(json['id']),
      visitId: serializer.fromJson<String>(json['visitId']),
      type: serializer.fromJson<String>(json['type']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'visitId': serializer.toJson<String>(visitId),
      'type': serializer.toJson<String>(type),
      'filePath': serializer.toJson<String>(filePath),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Attachment copyWith({
    String? id,
    String? visitId,
    String? type,
    String? filePath,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    Value<String?> thumbnailPath = const Value.absent(),
    String? createdAt,
  }) => Attachment(
    id: id ?? this.id,
    visitId: visitId ?? this.visitId,
    type: type ?? this.type,
    filePath: filePath ?? this.filePath,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    createdAt: createdAt ?? this.createdAt,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      type: data.type.present ? data.type.value : this.type,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('type: $type, ')
          ..write('filePath: $filePath, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    visitId,
    type,
    filePath,
    fileName,
    mimeType,
    sizeBytes,
    thumbnailPath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.visitId == this.visitId &&
          other.type == this.type &&
          other.filePath == this.filePath &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.thumbnailPath == this.thumbnailPath &&
          other.createdAt == this.createdAt);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<String> id;
  final Value<String> visitId;
  final Value<String> type;
  final Value<String> filePath;
  final Value<String> fileName;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<String?> thumbnailPath;
  final Value<String> createdAt;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.visitId = const Value.absent(),
    this.type = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String visitId,
    required String type,
    required String filePath,
    required String fileName,
    required String mimeType,
    required int sizeBytes,
    this.thumbnailPath = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       visitId = Value(visitId),
       type = Value(type),
       filePath = Value(filePath),
       fileName = Value(fileName),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes),
       createdAt = Value(createdAt);
  static Insertable<Attachment> custom({
    Expression<String>? id,
    Expression<String>? visitId,
    Expression<String>? type,
    Expression<String>? filePath,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<String>? thumbnailPath,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (visitId != null) 'visit_id': visitId,
      if (type != null) 'type': type,
      if (filePath != null) 'file_path': filePath,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? visitId,
    Value<String>? type,
    Value<String>? filePath,
    Value<String>? fileName,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<String?>? thumbnailPath,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('type: $type, ')
          ..write('filePath: $filePath, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES visits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _followUpDateMeta = const VerificationMeta(
    'followUpDate',
  );
  @override
  late final GeneratedColumn<String> followUpDate = GeneratedColumn<String>(
    'follow_up_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificationIdD1Meta = const VerificationMeta(
    'notificationIdD1',
  );
  @override
  late final GeneratedColumn<String> notificationIdD1 = GeneratedColumn<String>(
    'notification_id_d1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notificationIdD0Meta = const VerificationMeta(
    'notificationIdD0',
  );
  @override
  late final GeneratedColumn<String> notificationIdD0 = GeneratedColumn<String>(
    'notification_id_d0',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _rescheduledAtMeta = const VerificationMeta(
    'rescheduledAt',
  );
  @override
  late final GeneratedColumn<String> rescheduledAt = GeneratedColumn<String>(
    'rescheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    visitId,
    followUpDate,
    notificationIdD1,
    notificationIdD0,
    isActive,
    rescheduledAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('follow_up_date')) {
      context.handle(
        _followUpDateMeta,
        followUpDate.isAcceptableOrUnknown(
          data['follow_up_date']!,
          _followUpDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_followUpDateMeta);
    }
    if (data.containsKey('notification_id_d1')) {
      context.handle(
        _notificationIdD1Meta,
        notificationIdD1.isAcceptableOrUnknown(
          data['notification_id_d1']!,
          _notificationIdD1Meta,
        ),
      );
    }
    if (data.containsKey('notification_id_d0')) {
      context.handle(
        _notificationIdD0Meta,
        notificationIdD0.isAcceptableOrUnknown(
          data['notification_id_d0']!,
          _notificationIdD0Meta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('rescheduled_at')) {
      context.handle(
        _rescheduledAtMeta,
        rescheduledAt.isAcceptableOrUnknown(
          data['rescheduled_at']!,
          _rescheduledAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      followUpDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}follow_up_date'],
      )!,
      notificationIdD1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_id_d1'],
      ),
      notificationIdD0: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_id_d0'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_active'],
      )!,
      rescheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rescheduled_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String id;
  final String visitId;
  final String followUpDate;
  final String? notificationIdD1;
  final String? notificationIdD0;
  final int isActive;
  final String? rescheduledAt;
  final String createdAt;
  const Reminder({
    required this.id,
    required this.visitId,
    required this.followUpDate,
    this.notificationIdD1,
    this.notificationIdD0,
    required this.isActive,
    this.rescheduledAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['visit_id'] = Variable<String>(visitId);
    map['follow_up_date'] = Variable<String>(followUpDate);
    if (!nullToAbsent || notificationIdD1 != null) {
      map['notification_id_d1'] = Variable<String>(notificationIdD1);
    }
    if (!nullToAbsent || notificationIdD0 != null) {
      map['notification_id_d0'] = Variable<String>(notificationIdD0);
    }
    map['is_active'] = Variable<int>(isActive);
    if (!nullToAbsent || rescheduledAt != null) {
      map['rescheduled_at'] = Variable<String>(rescheduledAt);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      visitId: Value(visitId),
      followUpDate: Value(followUpDate),
      notificationIdD1: notificationIdD1 == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationIdD1),
      notificationIdD0: notificationIdD0 == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationIdD0),
      isActive: Value(isActive),
      rescheduledAt: rescheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(rescheduledAt),
      createdAt: Value(createdAt),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<String>(json['id']),
      visitId: serializer.fromJson<String>(json['visitId']),
      followUpDate: serializer.fromJson<String>(json['followUpDate']),
      notificationIdD1: serializer.fromJson<String?>(json['notificationIdD1']),
      notificationIdD0: serializer.fromJson<String?>(json['notificationIdD0']),
      isActive: serializer.fromJson<int>(json['isActive']),
      rescheduledAt: serializer.fromJson<String?>(json['rescheduledAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'visitId': serializer.toJson<String>(visitId),
      'followUpDate': serializer.toJson<String>(followUpDate),
      'notificationIdD1': serializer.toJson<String?>(notificationIdD1),
      'notificationIdD0': serializer.toJson<String?>(notificationIdD0),
      'isActive': serializer.toJson<int>(isActive),
      'rescheduledAt': serializer.toJson<String?>(rescheduledAt),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Reminder copyWith({
    String? id,
    String? visitId,
    String? followUpDate,
    Value<String?> notificationIdD1 = const Value.absent(),
    Value<String?> notificationIdD0 = const Value.absent(),
    int? isActive,
    Value<String?> rescheduledAt = const Value.absent(),
    String? createdAt,
  }) => Reminder(
    id: id ?? this.id,
    visitId: visitId ?? this.visitId,
    followUpDate: followUpDate ?? this.followUpDate,
    notificationIdD1: notificationIdD1.present
        ? notificationIdD1.value
        : this.notificationIdD1,
    notificationIdD0: notificationIdD0.present
        ? notificationIdD0.value
        : this.notificationIdD0,
    isActive: isActive ?? this.isActive,
    rescheduledAt: rescheduledAt.present
        ? rescheduledAt.value
        : this.rescheduledAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      followUpDate: data.followUpDate.present
          ? data.followUpDate.value
          : this.followUpDate,
      notificationIdD1: data.notificationIdD1.present
          ? data.notificationIdD1.value
          : this.notificationIdD1,
      notificationIdD0: data.notificationIdD0.present
          ? data.notificationIdD0.value
          : this.notificationIdD0,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      rescheduledAt: data.rescheduledAt.present
          ? data.rescheduledAt.value
          : this.rescheduledAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('followUpDate: $followUpDate, ')
          ..write('notificationIdD1: $notificationIdD1, ')
          ..write('notificationIdD0: $notificationIdD0, ')
          ..write('isActive: $isActive, ')
          ..write('rescheduledAt: $rescheduledAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    visitId,
    followUpDate,
    notificationIdD1,
    notificationIdD0,
    isActive,
    rescheduledAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.visitId == this.visitId &&
          other.followUpDate == this.followUpDate &&
          other.notificationIdD1 == this.notificationIdD1 &&
          other.notificationIdD0 == this.notificationIdD0 &&
          other.isActive == this.isActive &&
          other.rescheduledAt == this.rescheduledAt &&
          other.createdAt == this.createdAt);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> id;
  final Value<String> visitId;
  final Value<String> followUpDate;
  final Value<String?> notificationIdD1;
  final Value<String?> notificationIdD0;
  final Value<int> isActive;
  final Value<String?> rescheduledAt;
  final Value<String> createdAt;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.visitId = const Value.absent(),
    this.followUpDate = const Value.absent(),
    this.notificationIdD1 = const Value.absent(),
    this.notificationIdD0 = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rescheduledAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String visitId,
    required String followUpDate,
    this.notificationIdD1 = const Value.absent(),
    this.notificationIdD0 = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rescheduledAt = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       visitId = Value(visitId),
       followUpDate = Value(followUpDate),
       createdAt = Value(createdAt);
  static Insertable<Reminder> custom({
    Expression<String>? id,
    Expression<String>? visitId,
    Expression<String>? followUpDate,
    Expression<String>? notificationIdD1,
    Expression<String>? notificationIdD0,
    Expression<int>? isActive,
    Expression<String>? rescheduledAt,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (visitId != null) 'visit_id': visitId,
      if (followUpDate != null) 'follow_up_date': followUpDate,
      if (notificationIdD1 != null) 'notification_id_d1': notificationIdD1,
      if (notificationIdD0 != null) 'notification_id_d0': notificationIdD0,
      if (isActive != null) 'is_active': isActive,
      if (rescheduledAt != null) 'rescheduled_at': rescheduledAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? visitId,
    Value<String>? followUpDate,
    Value<String?>? notificationIdD1,
    Value<String?>? notificationIdD0,
    Value<int>? isActive,
    Value<String?>? rescheduledAt,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      followUpDate: followUpDate ?? this.followUpDate,
      notificationIdD1: notificationIdD1 ?? this.notificationIdD1,
      notificationIdD0: notificationIdD0 ?? this.notificationIdD0,
      isActive: isActive ?? this.isActive,
      rescheduledAt: rescheduledAt ?? this.rescheduledAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (followUpDate.present) {
      map['follow_up_date'] = Variable<String>(followUpDate.value);
    }
    if (notificationIdD1.present) {
      map['notification_id_d1'] = Variable<String>(notificationIdD1.value);
    }
    if (notificationIdD0.present) {
      map['notification_id_d0'] = Variable<String>(notificationIdD0.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (rescheduledAt.present) {
      map['rescheduled_at'] = Variable<String>(rescheduledAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('followUpDate: $followUpDate, ')
          ..write('notificationIdD1: $notificationIdD1, ')
          ..write('notificationIdD0: $notificationIdD0, ')
          ..write('isActive: $isActive, ')
          ..write('rescheduledAt: $rescheduledAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitDraftsTable extends VisitDrafts
    with TableInfo<$VisitDraftsTable, VisitDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formDataMeta = const VerificationMeta(
    'formData',
  );
  @override
  late final GeneratedColumn<String> formData = GeneratedColumn<String>(
    'form_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, formData, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visit_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('form_data')) {
      context.handle(
        _formDataMeta,
        formData.isAcceptableOrUnknown(data['form_data']!, _formDataMeta),
      );
    } else if (isInserting) {
      context.missing(_formDataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VisitDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitDraft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      formData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form_data'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VisitDraftsTable createAlias(String alias) {
    return $VisitDraftsTable(attachedDatabase, alias);
  }
}

class VisitDraft extends DataClass implements Insertable<VisitDraft> {
  final String id;
  final String formData;
  final String createdAt;
  final String updatedAt;
  const VisitDraft({
    required this.id,
    required this.formData,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['form_data'] = Variable<String>(formData);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  VisitDraftsCompanion toCompanion(bool nullToAbsent) {
    return VisitDraftsCompanion(
      id: Value(id),
      formData: Value(formData),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VisitDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitDraft(
      id: serializer.fromJson<String>(json['id']),
      formData: serializer.fromJson<String>(json['formData']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'formData': serializer.toJson<String>(formData),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  VisitDraft copyWith({
    String? id,
    String? formData,
    String? createdAt,
    String? updatedAt,
  }) => VisitDraft(
    id: id ?? this.id,
    formData: formData ?? this.formData,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  VisitDraft copyWithCompanion(VisitDraftsCompanion data) {
    return VisitDraft(
      id: data.id.present ? data.id.value : this.id,
      formData: data.formData.present ? data.formData.value : this.formData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitDraft(')
          ..write('id: $id, ')
          ..write('formData: $formData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, formData, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitDraft &&
          other.id == this.id &&
          other.formData == this.formData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VisitDraftsCompanion extends UpdateCompanion<VisitDraft> {
  final Value<String> id;
  final Value<String> formData;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const VisitDraftsCompanion({
    this.id = const Value.absent(),
    this.formData = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitDraftsCompanion.insert({
    required String id,
    required String formData,
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       formData = Value(formData),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<VisitDraft> custom({
    Expression<String>? id,
    Expression<String>? formData,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (formData != null) 'form_data': formData,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitDraftsCompanion copyWith({
    Value<String>? id,
    Value<String>? formData,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return VisitDraftsCompanion(
      id: id ?? this.id,
      formData: formData ?? this.formData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (formData.present) {
      map['form_data'] = Variable<String>(formData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitDraftsCompanion(')
          ..write('id: $id, ')
          ..write('formData: $formData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InsurancePoliciesTable extends InsurancePolicies
    with TableInfo<$InsurancePoliciesTable, InsurancePolicy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InsurancePoliciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES members (id)',
    ),
  );
  static const VerificationMeta _insurerNameMeta = const VerificationMeta(
    'insurerName',
  );
  @override
  late final GeneratedColumn<String> insurerName = GeneratedColumn<String>(
    'insurer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planTypeMeta = const VerificationMeta(
    'planType',
  );
  @override
  late final GeneratedColumn<String> planType = GeneratedColumn<String>(
    'plan_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PERSONAL'),
  );
  static const VerificationMeta _policyNumberMeta = const VerificationMeta(
    'policyNumber',
  );
  @override
  late final GeneratedColumn<String> policyNumber = GeneratedColumn<String>(
    'policy_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _policyHolderMeta = const VerificationMeta(
    'policyHolder',
  );
  @override
  late final GeneratedColumn<String> policyHolder = GeneratedColumn<String>(
    'policy_holder',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sumInsuredMeta = const VerificationMeta(
    'sumInsured',
  );
  @override
  late final GeneratedColumn<double> sumInsured = GeneratedColumn<double>(
    'sum_insured',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _premiumMeta = const VerificationMeta(
    'premium',
  );
  @override
  late final GeneratedColumn<double> premium = GeneratedColumn<double>(
    'premium',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INR'),
  );
  static const VerificationMeta _validFromMeta = const VerificationMeta(
    'validFrom',
  );
  @override
  late final GeneratedColumn<String> validFrom = GeneratedColumn<String>(
    'valid_from',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _validUntilMeta = const VerificationMeta(
    'validUntil',
  );
  @override
  late final GeneratedColumn<String> validUntil = GeneratedColumn<String>(
    'valid_until',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _helplinePhoneMeta = const VerificationMeta(
    'helplinePhone',
  );
  @override
  late final GeneratedColumn<String> helplinePhone = GeneratedColumn<String>(
    'helpline_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _agentNameMeta = const VerificationMeta(
    'agentName',
  );
  @override
  late final GeneratedColumn<String> agentName = GeneratedColumn<String>(
    'agent_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    memberId,
    insurerName,
    planType,
    policyNumber,
    policyHolder,
    sumInsured,
    premium,
    currency,
    validFrom,
    validUntil,
    helplinePhone,
    agentName,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insurance_policies';
  @override
  VerificationContext validateIntegrity(
    Insertable<InsurancePolicy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('insurer_name')) {
      context.handle(
        _insurerNameMeta,
        insurerName.isAcceptableOrUnknown(
          data['insurer_name']!,
          _insurerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_insurerNameMeta);
    }
    if (data.containsKey('plan_type')) {
      context.handle(
        _planTypeMeta,
        planType.isAcceptableOrUnknown(data['plan_type']!, _planTypeMeta),
      );
    }
    if (data.containsKey('policy_number')) {
      context.handle(
        _policyNumberMeta,
        policyNumber.isAcceptableOrUnknown(
          data['policy_number']!,
          _policyNumberMeta,
        ),
      );
    }
    if (data.containsKey('policy_holder')) {
      context.handle(
        _policyHolderMeta,
        policyHolder.isAcceptableOrUnknown(
          data['policy_holder']!,
          _policyHolderMeta,
        ),
      );
    }
    if (data.containsKey('sum_insured')) {
      context.handle(
        _sumInsuredMeta,
        sumInsured.isAcceptableOrUnknown(data['sum_insured']!, _sumInsuredMeta),
      );
    }
    if (data.containsKey('premium')) {
      context.handle(
        _premiumMeta,
        premium.isAcceptableOrUnknown(data['premium']!, _premiumMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('valid_from')) {
      context.handle(
        _validFromMeta,
        validFrom.isAcceptableOrUnknown(data['valid_from']!, _validFromMeta),
      );
    }
    if (data.containsKey('valid_until')) {
      context.handle(
        _validUntilMeta,
        validUntil.isAcceptableOrUnknown(data['valid_until']!, _validUntilMeta),
      );
    }
    if (data.containsKey('helpline_phone')) {
      context.handle(
        _helplinePhoneMeta,
        helplinePhone.isAcceptableOrUnknown(
          data['helpline_phone']!,
          _helplinePhoneMeta,
        ),
      );
    }
    if (data.containsKey('agent_name')) {
      context.handle(
        _agentNameMeta,
        agentName.isAcceptableOrUnknown(data['agent_name']!, _agentNameMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InsurancePolicy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InsurancePolicy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      insurerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insurer_name'],
      )!,
      planType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_type'],
      )!,
      policyNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}policy_number'],
      ),
      policyHolder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}policy_holder'],
      ),
      sumInsured: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sum_insured'],
      ),
      premium: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}premium'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      validFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valid_from'],
      ),
      validUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valid_until'],
      ),
      helplinePhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}helpline_phone'],
      ),
      agentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_name'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $InsurancePoliciesTable createAlias(String alias) {
    return $InsurancePoliciesTable(attachedDatabase, alias);
  }
}

class InsurancePolicy extends DataClass implements Insertable<InsurancePolicy> {
  final String id;
  final String memberId;
  final String insurerName;
  final String planType;
  final String? policyNumber;
  final String? policyHolder;
  final double? sumInsured;
  final double? premium;
  final String currency;
  final String? validFrom;
  final String? validUntil;
  final String? helplinePhone;
  final String? agentName;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  const InsurancePolicy({
    required this.id,
    required this.memberId,
    required this.insurerName,
    required this.planType,
    this.policyNumber,
    this.policyHolder,
    this.sumInsured,
    this.premium,
    required this.currency,
    this.validFrom,
    this.validUntil,
    this.helplinePhone,
    this.agentName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['member_id'] = Variable<String>(memberId);
    map['insurer_name'] = Variable<String>(insurerName);
    map['plan_type'] = Variable<String>(planType);
    if (!nullToAbsent || policyNumber != null) {
      map['policy_number'] = Variable<String>(policyNumber);
    }
    if (!nullToAbsent || policyHolder != null) {
      map['policy_holder'] = Variable<String>(policyHolder);
    }
    if (!nullToAbsent || sumInsured != null) {
      map['sum_insured'] = Variable<double>(sumInsured);
    }
    if (!nullToAbsent || premium != null) {
      map['premium'] = Variable<double>(premium);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || validFrom != null) {
      map['valid_from'] = Variable<String>(validFrom);
    }
    if (!nullToAbsent || validUntil != null) {
      map['valid_until'] = Variable<String>(validUntil);
    }
    if (!nullToAbsent || helplinePhone != null) {
      map['helpline_phone'] = Variable<String>(helplinePhone);
    }
    if (!nullToAbsent || agentName != null) {
      map['agent_name'] = Variable<String>(agentName);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  InsurancePoliciesCompanion toCompanion(bool nullToAbsent) {
    return InsurancePoliciesCompanion(
      id: Value(id),
      memberId: Value(memberId),
      insurerName: Value(insurerName),
      planType: Value(planType),
      policyNumber: policyNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(policyNumber),
      policyHolder: policyHolder == null && nullToAbsent
          ? const Value.absent()
          : Value(policyHolder),
      sumInsured: sumInsured == null && nullToAbsent
          ? const Value.absent()
          : Value(sumInsured),
      premium: premium == null && nullToAbsent
          ? const Value.absent()
          : Value(premium),
      currency: Value(currency),
      validFrom: validFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(validFrom),
      validUntil: validUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(validUntil),
      helplinePhone: helplinePhone == null && nullToAbsent
          ? const Value.absent()
          : Value(helplinePhone),
      agentName: agentName == null && nullToAbsent
          ? const Value.absent()
          : Value(agentName),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory InsurancePolicy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InsurancePolicy(
      id: serializer.fromJson<String>(json['id']),
      memberId: serializer.fromJson<String>(json['memberId']),
      insurerName: serializer.fromJson<String>(json['insurerName']),
      planType: serializer.fromJson<String>(json['planType']),
      policyNumber: serializer.fromJson<String?>(json['policyNumber']),
      policyHolder: serializer.fromJson<String?>(json['policyHolder']),
      sumInsured: serializer.fromJson<double?>(json['sumInsured']),
      premium: serializer.fromJson<double?>(json['premium']),
      currency: serializer.fromJson<String>(json['currency']),
      validFrom: serializer.fromJson<String?>(json['validFrom']),
      validUntil: serializer.fromJson<String?>(json['validUntil']),
      helplinePhone: serializer.fromJson<String?>(json['helplinePhone']),
      agentName: serializer.fromJson<String?>(json['agentName']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memberId': serializer.toJson<String>(memberId),
      'insurerName': serializer.toJson<String>(insurerName),
      'planType': serializer.toJson<String>(planType),
      'policyNumber': serializer.toJson<String?>(policyNumber),
      'policyHolder': serializer.toJson<String?>(policyHolder),
      'sumInsured': serializer.toJson<double?>(sumInsured),
      'premium': serializer.toJson<double?>(premium),
      'currency': serializer.toJson<String>(currency),
      'validFrom': serializer.toJson<String?>(validFrom),
      'validUntil': serializer.toJson<String?>(validUntil),
      'helplinePhone': serializer.toJson<String?>(helplinePhone),
      'agentName': serializer.toJson<String?>(agentName),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  InsurancePolicy copyWith({
    String? id,
    String? memberId,
    String? insurerName,
    String? planType,
    Value<String?> policyNumber = const Value.absent(),
    Value<String?> policyHolder = const Value.absent(),
    Value<double?> sumInsured = const Value.absent(),
    Value<double?> premium = const Value.absent(),
    String? currency,
    Value<String?> validFrom = const Value.absent(),
    Value<String?> validUntil = const Value.absent(),
    Value<String?> helplinePhone = const Value.absent(),
    Value<String?> agentName = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? createdAt,
    String? updatedAt,
  }) => InsurancePolicy(
    id: id ?? this.id,
    memberId: memberId ?? this.memberId,
    insurerName: insurerName ?? this.insurerName,
    planType: planType ?? this.planType,
    policyNumber: policyNumber.present ? policyNumber.value : this.policyNumber,
    policyHolder: policyHolder.present ? policyHolder.value : this.policyHolder,
    sumInsured: sumInsured.present ? sumInsured.value : this.sumInsured,
    premium: premium.present ? premium.value : this.premium,
    currency: currency ?? this.currency,
    validFrom: validFrom.present ? validFrom.value : this.validFrom,
    validUntil: validUntil.present ? validUntil.value : this.validUntil,
    helplinePhone: helplinePhone.present
        ? helplinePhone.value
        : this.helplinePhone,
    agentName: agentName.present ? agentName.value : this.agentName,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  InsurancePolicy copyWithCompanion(InsurancePoliciesCompanion data) {
    return InsurancePolicy(
      id: data.id.present ? data.id.value : this.id,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      insurerName: data.insurerName.present
          ? data.insurerName.value
          : this.insurerName,
      planType: data.planType.present ? data.planType.value : this.planType,
      policyNumber: data.policyNumber.present
          ? data.policyNumber.value
          : this.policyNumber,
      policyHolder: data.policyHolder.present
          ? data.policyHolder.value
          : this.policyHolder,
      sumInsured: data.sumInsured.present
          ? data.sumInsured.value
          : this.sumInsured,
      premium: data.premium.present ? data.premium.value : this.premium,
      currency: data.currency.present ? data.currency.value : this.currency,
      validFrom: data.validFrom.present ? data.validFrom.value : this.validFrom,
      validUntil: data.validUntil.present
          ? data.validUntil.value
          : this.validUntil,
      helplinePhone: data.helplinePhone.present
          ? data.helplinePhone.value
          : this.helplinePhone,
      agentName: data.agentName.present ? data.agentName.value : this.agentName,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InsurancePolicy(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('insurerName: $insurerName, ')
          ..write('planType: $planType, ')
          ..write('policyNumber: $policyNumber, ')
          ..write('policyHolder: $policyHolder, ')
          ..write('sumInsured: $sumInsured, ')
          ..write('premium: $premium, ')
          ..write('currency: $currency, ')
          ..write('validFrom: $validFrom, ')
          ..write('validUntil: $validUntil, ')
          ..write('helplinePhone: $helplinePhone, ')
          ..write('agentName: $agentName, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    memberId,
    insurerName,
    planType,
    policyNumber,
    policyHolder,
    sumInsured,
    premium,
    currency,
    validFrom,
    validUntil,
    helplinePhone,
    agentName,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InsurancePolicy &&
          other.id == this.id &&
          other.memberId == this.memberId &&
          other.insurerName == this.insurerName &&
          other.planType == this.planType &&
          other.policyNumber == this.policyNumber &&
          other.policyHolder == this.policyHolder &&
          other.sumInsured == this.sumInsured &&
          other.premium == this.premium &&
          other.currency == this.currency &&
          other.validFrom == this.validFrom &&
          other.validUntil == this.validUntil &&
          other.helplinePhone == this.helplinePhone &&
          other.agentName == this.agentName &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InsurancePoliciesCompanion extends UpdateCompanion<InsurancePolicy> {
  final Value<String> id;
  final Value<String> memberId;
  final Value<String> insurerName;
  final Value<String> planType;
  final Value<String?> policyNumber;
  final Value<String?> policyHolder;
  final Value<double?> sumInsured;
  final Value<double?> premium;
  final Value<String> currency;
  final Value<String?> validFrom;
  final Value<String?> validUntil;
  final Value<String?> helplinePhone;
  final Value<String?> agentName;
  final Value<String?> notes;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const InsurancePoliciesCompanion({
    this.id = const Value.absent(),
    this.memberId = const Value.absent(),
    this.insurerName = const Value.absent(),
    this.planType = const Value.absent(),
    this.policyNumber = const Value.absent(),
    this.policyHolder = const Value.absent(),
    this.sumInsured = const Value.absent(),
    this.premium = const Value.absent(),
    this.currency = const Value.absent(),
    this.validFrom = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.helplinePhone = const Value.absent(),
    this.agentName = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InsurancePoliciesCompanion.insert({
    required String id,
    required String memberId,
    required String insurerName,
    this.planType = const Value.absent(),
    this.policyNumber = const Value.absent(),
    this.policyHolder = const Value.absent(),
    this.sumInsured = const Value.absent(),
    this.premium = const Value.absent(),
    this.currency = const Value.absent(),
    this.validFrom = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.helplinePhone = const Value.absent(),
    this.agentName = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memberId = Value(memberId),
       insurerName = Value(insurerName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<InsurancePolicy> custom({
    Expression<String>? id,
    Expression<String>? memberId,
    Expression<String>? insurerName,
    Expression<String>? planType,
    Expression<String>? policyNumber,
    Expression<String>? policyHolder,
    Expression<double>? sumInsured,
    Expression<double>? premium,
    Expression<String>? currency,
    Expression<String>? validFrom,
    Expression<String>? validUntil,
    Expression<String>? helplinePhone,
    Expression<String>? agentName,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memberId != null) 'member_id': memberId,
      if (insurerName != null) 'insurer_name': insurerName,
      if (planType != null) 'plan_type': planType,
      if (policyNumber != null) 'policy_number': policyNumber,
      if (policyHolder != null) 'policy_holder': policyHolder,
      if (sumInsured != null) 'sum_insured': sumInsured,
      if (premium != null) 'premium': premium,
      if (currency != null) 'currency': currency,
      if (validFrom != null) 'valid_from': validFrom,
      if (validUntil != null) 'valid_until': validUntil,
      if (helplinePhone != null) 'helpline_phone': helplinePhone,
      if (agentName != null) 'agent_name': agentName,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InsurancePoliciesCompanion copyWith({
    Value<String>? id,
    Value<String>? memberId,
    Value<String>? insurerName,
    Value<String>? planType,
    Value<String?>? policyNumber,
    Value<String?>? policyHolder,
    Value<double?>? sumInsured,
    Value<double?>? premium,
    Value<String>? currency,
    Value<String?>? validFrom,
    Value<String?>? validUntil,
    Value<String?>? helplinePhone,
    Value<String?>? agentName,
    Value<String?>? notes,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return InsurancePoliciesCompanion(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      insurerName: insurerName ?? this.insurerName,
      planType: planType ?? this.planType,
      policyNumber: policyNumber ?? this.policyNumber,
      policyHolder: policyHolder ?? this.policyHolder,
      sumInsured: sumInsured ?? this.sumInsured,
      premium: premium ?? this.premium,
      currency: currency ?? this.currency,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      helplinePhone: helplinePhone ?? this.helplinePhone,
      agentName: agentName ?? this.agentName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (insurerName.present) {
      map['insurer_name'] = Variable<String>(insurerName.value);
    }
    if (planType.present) {
      map['plan_type'] = Variable<String>(planType.value);
    }
    if (policyNumber.present) {
      map['policy_number'] = Variable<String>(policyNumber.value);
    }
    if (policyHolder.present) {
      map['policy_holder'] = Variable<String>(policyHolder.value);
    }
    if (sumInsured.present) {
      map['sum_insured'] = Variable<double>(sumInsured.value);
    }
    if (premium.present) {
      map['premium'] = Variable<double>(premium.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (validFrom.present) {
      map['valid_from'] = Variable<String>(validFrom.value);
    }
    if (validUntil.present) {
      map['valid_until'] = Variable<String>(validUntil.value);
    }
    if (helplinePhone.present) {
      map['helpline_phone'] = Variable<String>(helplinePhone.value);
    }
    if (agentName.present) {
      map['agent_name'] = Variable<String>(agentName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InsurancePoliciesCompanion(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('insurerName: $insurerName, ')
          ..write('planType: $planType, ')
          ..write('policyNumber: $policyNumber, ')
          ..write('policyHolder: $policyHolder, ')
          ..write('sumInsured: $sumInsured, ')
          ..write('premium: $premium, ')
          ..write('currency: $currency, ')
          ..write('validFrom: $validFrom, ')
          ..write('validUntil: $validUntil, ')
          ..write('helplinePhone: $helplinePhone, ')
          ..write('agentName: $agentName, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InsuranceDocumentsTable extends InsuranceDocuments
    with TableInfo<$InsuranceDocumentsTable, InsuranceDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InsuranceDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _policyIdMeta = const VerificationMeta(
    'policyId',
  );
  @override
  late final GeneratedColumn<String> policyId = GeneratedColumn<String>(
    'policy_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES insurance_policies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    policyId,
    filePath,
    fileName,
    mimeType,
    sizeBytes,
    thumbnailPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insurance_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<InsuranceDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('policy_id')) {
      context.handle(
        _policyIdMeta,
        policyId.isAcceptableOrUnknown(data['policy_id']!, _policyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_policyIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InsuranceDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InsuranceDocument(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      policyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}policy_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InsuranceDocumentsTable createAlias(String alias) {
    return $InsuranceDocumentsTable(attachedDatabase, alias);
  }
}

class InsuranceDocument extends DataClass
    implements Insertable<InsuranceDocument> {
  final String id;
  final String policyId;
  final String filePath;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String? thumbnailPath;
  final String createdAt;
  const InsuranceDocument({
    required this.id,
    required this.policyId,
    required this.filePath,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.thumbnailPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['policy_id'] = Variable<String>(policyId);
    map['file_path'] = Variable<String>(filePath);
    map['file_name'] = Variable<String>(fileName);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  InsuranceDocumentsCompanion toCompanion(bool nullToAbsent) {
    return InsuranceDocumentsCompanion(
      id: Value(id),
      policyId: Value(policyId),
      filePath: Value(filePath),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      createdAt: Value(createdAt),
    );
  }

  factory InsuranceDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InsuranceDocument(
      id: serializer.fromJson<String>(json['id']),
      policyId: serializer.fromJson<String>(json['policyId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'policyId': serializer.toJson<String>(policyId),
      'filePath': serializer.toJson<String>(filePath),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  InsuranceDocument copyWith({
    String? id,
    String? policyId,
    String? filePath,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    Value<String?> thumbnailPath = const Value.absent(),
    String? createdAt,
  }) => InsuranceDocument(
    id: id ?? this.id,
    policyId: policyId ?? this.policyId,
    filePath: filePath ?? this.filePath,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    createdAt: createdAt ?? this.createdAt,
  );
  InsuranceDocument copyWithCompanion(InsuranceDocumentsCompanion data) {
    return InsuranceDocument(
      id: data.id.present ? data.id.value : this.id,
      policyId: data.policyId.present ? data.policyId.value : this.policyId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InsuranceDocument(')
          ..write('id: $id, ')
          ..write('policyId: $policyId, ')
          ..write('filePath: $filePath, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    policyId,
    filePath,
    fileName,
    mimeType,
    sizeBytes,
    thumbnailPath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InsuranceDocument &&
          other.id == this.id &&
          other.policyId == this.policyId &&
          other.filePath == this.filePath &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.thumbnailPath == this.thumbnailPath &&
          other.createdAt == this.createdAt);
}

class InsuranceDocumentsCompanion extends UpdateCompanion<InsuranceDocument> {
  final Value<String> id;
  final Value<String> policyId;
  final Value<String> filePath;
  final Value<String> fileName;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<String?> thumbnailPath;
  final Value<String> createdAt;
  final Value<int> rowid;
  const InsuranceDocumentsCompanion({
    this.id = const Value.absent(),
    this.policyId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InsuranceDocumentsCompanion.insert({
    required String id,
    required String policyId,
    required String filePath,
    required String fileName,
    required String mimeType,
    required int sizeBytes,
    this.thumbnailPath = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       policyId = Value(policyId),
       filePath = Value(filePath),
       fileName = Value(fileName),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes),
       createdAt = Value(createdAt);
  static Insertable<InsuranceDocument> custom({
    Expression<String>? id,
    Expression<String>? policyId,
    Expression<String>? filePath,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<String>? thumbnailPath,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (policyId != null) 'policy_id': policyId,
      if (filePath != null) 'file_path': filePath,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InsuranceDocumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? policyId,
    Value<String>? filePath,
    Value<String>? fileName,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<String?>? thumbnailPath,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return InsuranceDocumentsCompanion(
      id: id ?? this.id,
      policyId: policyId ?? this.policyId,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (policyId.present) {
      map['policy_id'] = Variable<String>(policyId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InsuranceDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('policyId: $policyId, ')
          ..write('filePath: $filePath, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MembersTable members = $MembersTable(this);
  late final $VisitsTable visits = $VisitsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $VisitDraftsTable visitDrafts = $VisitDraftsTable(this);
  late final $InsurancePoliciesTable insurancePolicies =
      $InsurancePoliciesTable(this);
  late final $InsuranceDocumentsTable insuranceDocuments =
      $InsuranceDocumentsTable(this);
  late final VisitsDao visitsDao = VisitsDao(this as AppDatabase);
  late final AttachmentsDao attachmentsDao = AttachmentsDao(
    this as AppDatabase,
  );
  late final RemindersDao remindersDao = RemindersDao(this as AppDatabase);
  late final MembersDao membersDao = MembersDao(this as AppDatabase);
  late final InsuranceDao insuranceDao = InsuranceDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    members,
    visits,
    attachments,
    reminders,
    visitDrafts,
    insurancePolicies,
    insuranceDocuments,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'visits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attachments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'visits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'insurance_policies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('insurance_documents', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MembersTableCreateCompanionBuilder =
    MembersCompanion Function({
      required String id,
      required String name,
      Value<String> relationship,
      Value<String?> dateOfBirth,
      Value<String?> gender,
      Value<String> color,
      required String createdAt,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$MembersTableUpdateCompanionBuilder =
    MembersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> relationship,
      Value<String?> dateOfBirth,
      Value<String?> gender,
      Value<String> color,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<int> rowid,
    });

final class $$MembersTableReferences
    extends BaseReferences<_$AppDatabase, $MembersTable, Member> {
  $$MembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VisitsTable, List<Visit>> _visitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.visits,
    aliasName: $_aliasNameGenerator(db.members.id, db.visits.memberId),
  );

  $$VisitsTableProcessedTableManager get visitsRefs {
    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.memberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_visitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InsurancePoliciesTable, List<InsurancePolicy>>
  _insurancePoliciesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.insurancePolicies,
        aliasName: $_aliasNameGenerator(
          db.members.id,
          db.insurancePolicies.memberId,
        ),
      );

  $$InsurancePoliciesTableProcessedTableManager get insurancePoliciesRefs {
    final manager = $$InsurancePoliciesTableTableManager(
      $_db,
      $_db.insurancePolicies,
    ).filter((f) => f.memberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _insurancePoliciesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MembersTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> visitsRefs(
    Expression<bool> Function($$VisitsTableFilterComposer f) f,
  ) {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableFilterComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> insurancePoliciesRefs(
    Expression<bool> Function($$InsurancePoliciesTableFilterComposer f) f,
  ) {
    final $$InsurancePoliciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.insurancePolicies,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InsurancePoliciesTableFilterComposer(
            $db: $db,
            $table: $db.insurancePolicies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> visitsRefs<T extends Object>(
    Expression<T> Function($$VisitsTableAnnotationComposer a) f,
  ) {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> insurancePoliciesRefs<T extends Object>(
    Expression<T> Function($$InsurancePoliciesTableAnnotationComposer a) f,
  ) {
    final $$InsurancePoliciesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.insurancePolicies,
          getReferencedColumn: (t) => t.memberId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InsurancePoliciesTableAnnotationComposer(
                $db: $db,
                $table: $db.insurancePolicies,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembersTable,
          Member,
          $$MembersTableFilterComposer,
          $$MembersTableOrderingComposer,
          $$MembersTableAnnotationComposer,
          $$MembersTableCreateCompanionBuilder,
          $$MembersTableUpdateCompanionBuilder,
          (Member, $$MembersTableReferences),
          Member,
          PrefetchHooks Function({bool visitsRefs, bool insurancePoliciesRefs})
        > {
  $$MembersTableTableManager(_$AppDatabase db, $MembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> relationship = const Value.absent(),
                Value<String?> dateOfBirth = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion(
                id: id,
                name: name,
                relationship: relationship,
                dateOfBirth: dateOfBirth,
                gender: gender,
                color: color,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> relationship = const Value.absent(),
                Value<String?> dateOfBirth = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String> color = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion.insert(
                id: id,
                name: name,
                relationship: relationship,
                dateOfBirth: dateOfBirth,
                gender: gender,
                color: color,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({visitsRefs = false, insurancePoliciesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (visitsRefs) db.visits,
                    if (insurancePoliciesRefs) db.insurancePolicies,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (visitsRefs)
                        await $_getPrefetchedData<Member, $MembersTable, Visit>(
                          currentTable: table,
                          referencedTable: $$MembersTableReferences
                              ._visitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MembersTableReferences(
                                db,
                                table,
                                p0,
                              ).visitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.memberId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (insurancePoliciesRefs)
                        await $_getPrefetchedData<
                          Member,
                          $MembersTable,
                          InsurancePolicy
                        >(
                          currentTable: table,
                          referencedTable: $$MembersTableReferences
                              ._insurancePoliciesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MembersTableReferences(
                                db,
                                table,
                                p0,
                              ).insurancePoliciesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.memberId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembersTable,
      Member,
      $$MembersTableFilterComposer,
      $$MembersTableOrderingComposer,
      $$MembersTableAnnotationComposer,
      $$MembersTableCreateCompanionBuilder,
      $$MembersTableUpdateCompanionBuilder,
      (Member, $$MembersTableReferences),
      Member,
      PrefetchHooks Function({bool visitsRefs, bool insurancePoliciesRefs})
    >;
typedef $$VisitsTableCreateCompanionBuilder =
    VisitsCompanion Function({
      required String id,
      required String bodyPartId,
      required String specialityId,
      Value<String?> customSpeciality,
      required String visitDate,
      Value<String?> followUpDate,
      Value<String?> doctorName,
      Value<String?> clinicName,
      Value<String?> clinicPhone,
      Value<double?> doctorFees,
      Value<String> currency,
      Value<String?> symptoms,
      Value<String?> diagnosis,
      Value<String?> notes,
      Value<String?> memberId,
      required String createdAt,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$VisitsTableUpdateCompanionBuilder =
    VisitsCompanion Function({
      Value<String> id,
      Value<String> bodyPartId,
      Value<String> specialityId,
      Value<String?> customSpeciality,
      Value<String> visitDate,
      Value<String?> followUpDate,
      Value<String?> doctorName,
      Value<String?> clinicName,
      Value<String?> clinicPhone,
      Value<double?> doctorFees,
      Value<String> currency,
      Value<String?> symptoms,
      Value<String?> diagnosis,
      Value<String?> notes,
      Value<String?> memberId,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<int> rowid,
    });

final class $$VisitsTableReferences
    extends BaseReferences<_$AppDatabase, $VisitsTable, Visit> {
  $$VisitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MembersTable _memberIdTable(_$AppDatabase db) => db.members
      .createAlias($_aliasNameGenerator(db.visits.memberId, db.members.id));

  $$MembersTableProcessedTableManager? get memberId {
    final $_column = $_itemColumn<String>('member_id');
    if ($_column == null) return null;
    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttachmentsTable, List<Attachment>>
  _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: $_aliasNameGenerator(db.visits.id, db.attachments.visitId),
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.visitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: $_aliasNameGenerator(db.visits.id, db.reminders.visitId),
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.visitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VisitsTableFilterComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyPartId => $composableBuilder(
    column: $table.bodyPartId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialityId => $composableBuilder(
    column: $table.specialityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customSpeciality => $composableBuilder(
    column: $table.customSpeciality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitDate => $composableBuilder(
    column: $table.visitDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doctorName => $composableBuilder(
    column: $table.doctorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicName => $composableBuilder(
    column: $table.clinicName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicPhone => $composableBuilder(
    column: $table.clinicPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get doctorFees => $composableBuilder(
    column: $table.doctorFees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diagnosis => $composableBuilder(
    column: $table.diagnosis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MembersTableFilterComposer get memberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyPartId => $composableBuilder(
    column: $table.bodyPartId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialityId => $composableBuilder(
    column: $table.specialityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customSpeciality => $composableBuilder(
    column: $table.customSpeciality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitDate => $composableBuilder(
    column: $table.visitDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doctorName => $composableBuilder(
    column: $table.doctorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicName => $composableBuilder(
    column: $table.clinicName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicPhone => $composableBuilder(
    column: $table.clinicPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get doctorFees => $composableBuilder(
    column: $table.doctorFees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagnosis => $composableBuilder(
    column: $table.diagnosis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MembersTableOrderingComposer get memberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableOrderingComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bodyPartId => $composableBuilder(
    column: $table.bodyPartId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specialityId => $composableBuilder(
    column: $table.specialityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customSpeciality => $composableBuilder(
    column: $table.customSpeciality,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visitDate =>
      $composableBuilder(column: $table.visitDate, builder: (column) => column);

  GeneratedColumn<String> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doctorName => $composableBuilder(
    column: $table.doctorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicName => $composableBuilder(
    column: $table.clinicName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicPhone => $composableBuilder(
    column: $table.clinicPhone,
    builder: (column) => column,
  );

  GeneratedColumn<double> get doctorFees => $composableBuilder(
    column: $table.doctorFees,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get symptoms =>
      $composableBuilder(column: $table.symptoms, builder: (column) => column);

  GeneratedColumn<String> get diagnosis =>
      $composableBuilder(column: $table.diagnosis, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MembersTableAnnotationComposer get memberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitsTable,
          Visit,
          $$VisitsTableFilterComposer,
          $$VisitsTableOrderingComposer,
          $$VisitsTableAnnotationComposer,
          $$VisitsTableCreateCompanionBuilder,
          $$VisitsTableUpdateCompanionBuilder,
          (Visit, $$VisitsTableReferences),
          Visit,
          PrefetchHooks Function({
            bool memberId,
            bool attachmentsRefs,
            bool remindersRefs,
          })
        > {
  $$VisitsTableTableManager(_$AppDatabase db, $VisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bodyPartId = const Value.absent(),
                Value<String> specialityId = const Value.absent(),
                Value<String?> customSpeciality = const Value.absent(),
                Value<String> visitDate = const Value.absent(),
                Value<String?> followUpDate = const Value.absent(),
                Value<String?> doctorName = const Value.absent(),
                Value<String?> clinicName = const Value.absent(),
                Value<String?> clinicPhone = const Value.absent(),
                Value<double?> doctorFees = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> symptoms = const Value.absent(),
                Value<String?> diagnosis = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion(
                id: id,
                bodyPartId: bodyPartId,
                specialityId: specialityId,
                customSpeciality: customSpeciality,
                visitDate: visitDate,
                followUpDate: followUpDate,
                doctorName: doctorName,
                clinicName: clinicName,
                clinicPhone: clinicPhone,
                doctorFees: doctorFees,
                currency: currency,
                symptoms: symptoms,
                diagnosis: diagnosis,
                notes: notes,
                memberId: memberId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bodyPartId,
                required String specialityId,
                Value<String?> customSpeciality = const Value.absent(),
                required String visitDate,
                Value<String?> followUpDate = const Value.absent(),
                Value<String?> doctorName = const Value.absent(),
                Value<String?> clinicName = const Value.absent(),
                Value<String?> clinicPhone = const Value.absent(),
                Value<double?> doctorFees = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> symptoms = const Value.absent(),
                Value<String?> diagnosis = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion.insert(
                id: id,
                bodyPartId: bodyPartId,
                specialityId: specialityId,
                customSpeciality: customSpeciality,
                visitDate: visitDate,
                followUpDate: followUpDate,
                doctorName: doctorName,
                clinicName: clinicName,
                clinicPhone: clinicPhone,
                doctorFees: doctorFees,
                currency: currency,
                symptoms: symptoms,
                diagnosis: diagnosis,
                notes: notes,
                memberId: memberId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$VisitsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                memberId = false,
                attachmentsRefs = false,
                remindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attachmentsRefs) db.attachments,
                    if (remindersRefs) db.reminders,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (memberId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.memberId,
                                    referencedTable: $$VisitsTableReferences
                                        ._memberIdTable(db),
                                    referencedColumn: $$VisitsTableReferences
                                        ._memberIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attachmentsRefs)
                        await $_getPrefetchedData<
                          Visit,
                          $VisitsTable,
                          Attachment
                        >(
                          currentTable: table,
                          referencedTable: $$VisitsTableReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VisitsTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.visitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedData<
                          Visit,
                          $VisitsTable,
                          Reminder
                        >(
                          currentTable: table,
                          referencedTable: $$VisitsTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VisitsTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.visitId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitsTable,
      Visit,
      $$VisitsTableFilterComposer,
      $$VisitsTableOrderingComposer,
      $$VisitsTableAnnotationComposer,
      $$VisitsTableCreateCompanionBuilder,
      $$VisitsTableUpdateCompanionBuilder,
      (Visit, $$VisitsTableReferences),
      Visit,
      PrefetchHooks Function({
        bool memberId,
        bool attachmentsRefs,
        bool remindersRefs,
      })
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String visitId,
      required String type,
      required String filePath,
      required String fileName,
      required String mimeType,
      required int sizeBytes,
      Value<String?> thumbnailPath,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> visitId,
      Value<String> type,
      Value<String> filePath,
      Value<String> fileName,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<String?> thumbnailPath,
      Value<String> createdAt,
      Value<int> rowid,
    });

final class $$AttachmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VisitsTable _visitIdTable(_$AppDatabase db) => db.visits.createAlias(
    $_aliasNameGenerator(db.attachments.visitId, db.visits.id),
  );

  $$VisitsTableProcessedTableManager get visitId {
    final $_column = $_itemColumn<String>('visit_id')!;

    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_visitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VisitsTableFilterComposer get visitId {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableFilterComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VisitsTableOrderingComposer get visitId {
    final $$VisitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableOrderingComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$VisitsTableAnnotationComposer get visitId {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (Attachment, $$AttachmentsTableReferences),
          Attachment,
          PrefetchHooks Function({bool visitId})
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> visitId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                visitId: visitId,
                type: type,
                filePath: filePath,
                fileName: fileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                thumbnailPath: thumbnailPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String visitId,
                required String type,
                required String filePath,
                required String fileName,
                required String mimeType,
                required int sizeBytes,
                Value<String?> thumbnailPath = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                visitId: visitId,
                type: type,
                filePath: filePath,
                fileName: fileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                thumbnailPath: thumbnailPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({visitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (visitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.visitId,
                                referencedTable: $$AttachmentsTableReferences
                                    ._visitIdTable(db),
                                referencedColumn: $$AttachmentsTableReferences
                                    ._visitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (Attachment, $$AttachmentsTableReferences),
      Attachment,
      PrefetchHooks Function({bool visitId})
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      required String id,
      required String visitId,
      required String followUpDate,
      Value<String?> notificationIdD1,
      Value<String?> notificationIdD0,
      Value<int> isActive,
      Value<String?> rescheduledAt,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<String> id,
      Value<String> visitId,
      Value<String> followUpDate,
      Value<String?> notificationIdD1,
      Value<String?> notificationIdD0,
      Value<int> isActive,
      Value<String?> rescheduledAt,
      Value<String> createdAt,
      Value<int> rowid,
    });

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, Reminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VisitsTable _visitIdTable(_$AppDatabase db) => db.visits.createAlias(
    $_aliasNameGenerator(db.reminders.visitId, db.visits.id),
  );

  $$VisitsTableProcessedTableManager get visitId {
    final $_column = $_itemColumn<String>('visit_id')!;

    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_visitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationIdD1 => $composableBuilder(
    column: $table.notificationIdD1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationIdD0 => $composableBuilder(
    column: $table.notificationIdD0,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rescheduledAt => $composableBuilder(
    column: $table.rescheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VisitsTableFilterComposer get visitId {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableFilterComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationIdD1 => $composableBuilder(
    column: $table.notificationIdD1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationIdD0 => $composableBuilder(
    column: $table.notificationIdD0,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rescheduledAt => $composableBuilder(
    column: $table.rescheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VisitsTableOrderingComposer get visitId {
    final $$VisitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableOrderingComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notificationIdD1 => $composableBuilder(
    column: $table.notificationIdD1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notificationIdD0 => $composableBuilder(
    column: $table.notificationIdD0,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get rescheduledAt => $composableBuilder(
    column: $table.rescheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$VisitsTableAnnotationComposer get visitId {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, $$RemindersTableReferences),
          Reminder,
          PrefetchHooks Function({bool visitId})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> visitId = const Value.absent(),
                Value<String> followUpDate = const Value.absent(),
                Value<String?> notificationIdD1 = const Value.absent(),
                Value<String?> notificationIdD0 = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<String?> rescheduledAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                visitId: visitId,
                followUpDate: followUpDate,
                notificationIdD1: notificationIdD1,
                notificationIdD0: notificationIdD0,
                isActive: isActive,
                rescheduledAt: rescheduledAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String visitId,
                required String followUpDate,
                Value<String?> notificationIdD1 = const Value.absent(),
                Value<String?> notificationIdD0 = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<String?> rescheduledAt = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                visitId: visitId,
                followUpDate: followUpDate,
                notificationIdD1: notificationIdD1,
                notificationIdD0: notificationIdD0,
                isActive: isActive,
                rescheduledAt: rescheduledAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({visitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (visitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.visitId,
                                referencedTable: $$RemindersTableReferences
                                    ._visitIdTable(db),
                                referencedColumn: $$RemindersTableReferences
                                    ._visitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, $$RemindersTableReferences),
      Reminder,
      PrefetchHooks Function({bool visitId})
    >;
typedef $$VisitDraftsTableCreateCompanionBuilder =
    VisitDraftsCompanion Function({
      required String id,
      required String formData,
      required String createdAt,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$VisitDraftsTableUpdateCompanionBuilder =
    VisitDraftsCompanion Function({
      Value<String> id,
      Value<String> formData,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$VisitDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $VisitDraftsTable> {
  $$VisitDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formData => $composableBuilder(
    column: $table.formData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitDraftsTable> {
  $$VisitDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formData => $composableBuilder(
    column: $table.formData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitDraftsTable> {
  $$VisitDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get formData =>
      $composableBuilder(column: $table.formData, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$VisitDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitDraftsTable,
          VisitDraft,
          $$VisitDraftsTableFilterComposer,
          $$VisitDraftsTableOrderingComposer,
          $$VisitDraftsTableAnnotationComposer,
          $$VisitDraftsTableCreateCompanionBuilder,
          $$VisitDraftsTableUpdateCompanionBuilder,
          (
            VisitDraft,
            BaseReferences<_$AppDatabase, $VisitDraftsTable, VisitDraft>,
          ),
          VisitDraft,
          PrefetchHooks Function()
        > {
  $$VisitDraftsTableTableManager(_$AppDatabase db, $VisitDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> formData = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitDraftsCompanion(
                id: id,
                formData: formData,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String formData,
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => VisitDraftsCompanion.insert(
                id: id,
                formData: formData,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitDraftsTable,
      VisitDraft,
      $$VisitDraftsTableFilterComposer,
      $$VisitDraftsTableOrderingComposer,
      $$VisitDraftsTableAnnotationComposer,
      $$VisitDraftsTableCreateCompanionBuilder,
      $$VisitDraftsTableUpdateCompanionBuilder,
      (
        VisitDraft,
        BaseReferences<_$AppDatabase, $VisitDraftsTable, VisitDraft>,
      ),
      VisitDraft,
      PrefetchHooks Function()
    >;
typedef $$InsurancePoliciesTableCreateCompanionBuilder =
    InsurancePoliciesCompanion Function({
      required String id,
      required String memberId,
      required String insurerName,
      Value<String> planType,
      Value<String?> policyNumber,
      Value<String?> policyHolder,
      Value<double?> sumInsured,
      Value<double?> premium,
      Value<String> currency,
      Value<String?> validFrom,
      Value<String?> validUntil,
      Value<String?> helplinePhone,
      Value<String?> agentName,
      Value<String?> notes,
      required String createdAt,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$InsurancePoliciesTableUpdateCompanionBuilder =
    InsurancePoliciesCompanion Function({
      Value<String> id,
      Value<String> memberId,
      Value<String> insurerName,
      Value<String> planType,
      Value<String?> policyNumber,
      Value<String?> policyHolder,
      Value<double?> sumInsured,
      Value<double?> premium,
      Value<String> currency,
      Value<String?> validFrom,
      Value<String?> validUntil,
      Value<String?> helplinePhone,
      Value<String?> agentName,
      Value<String?> notes,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<int> rowid,
    });

final class $$InsurancePoliciesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InsurancePoliciesTable,
          InsurancePolicy
        > {
  $$InsurancePoliciesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MembersTable _memberIdTable(_$AppDatabase db) =>
      db.members.createAlias(
        $_aliasNameGenerator(db.insurancePolicies.memberId, db.members.id),
      );

  $$MembersTableProcessedTableManager get memberId {
    final $_column = $_itemColumn<String>('member_id')!;

    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InsuranceDocumentsTable, List<InsuranceDocument>>
  _insuranceDocumentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.insuranceDocuments,
        aliasName: $_aliasNameGenerator(
          db.insurancePolicies.id,
          db.insuranceDocuments.policyId,
        ),
      );

  $$InsuranceDocumentsTableProcessedTableManager get insuranceDocumentsRefs {
    final manager = $$InsuranceDocumentsTableTableManager(
      $_db,
      $_db.insuranceDocuments,
    ).filter((f) => f.policyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _insuranceDocumentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InsurancePoliciesTableFilterComposer
    extends Composer<_$AppDatabase, $InsurancePoliciesTable> {
  $$InsurancePoliciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insurerName => $composableBuilder(
    column: $table.insurerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planType => $composableBuilder(
    column: $table.planType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get policyNumber => $composableBuilder(
    column: $table.policyNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get policyHolder => $composableBuilder(
    column: $table.policyHolder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sumInsured => $composableBuilder(
    column: $table.sumInsured,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get premium => $composableBuilder(
    column: $table.premium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validFrom => $composableBuilder(
    column: $table.validFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get helplinePhone => $composableBuilder(
    column: $table.helplinePhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentName => $composableBuilder(
    column: $table.agentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MembersTableFilterComposer get memberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> insuranceDocumentsRefs(
    Expression<bool> Function($$InsuranceDocumentsTableFilterComposer f) f,
  ) {
    final $$InsuranceDocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.insuranceDocuments,
      getReferencedColumn: (t) => t.policyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InsuranceDocumentsTableFilterComposer(
            $db: $db,
            $table: $db.insuranceDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InsurancePoliciesTableOrderingComposer
    extends Composer<_$AppDatabase, $InsurancePoliciesTable> {
  $$InsurancePoliciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insurerName => $composableBuilder(
    column: $table.insurerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planType => $composableBuilder(
    column: $table.planType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get policyNumber => $composableBuilder(
    column: $table.policyNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get policyHolder => $composableBuilder(
    column: $table.policyHolder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sumInsured => $composableBuilder(
    column: $table.sumInsured,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get premium => $composableBuilder(
    column: $table.premium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validFrom => $composableBuilder(
    column: $table.validFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get helplinePhone => $composableBuilder(
    column: $table.helplinePhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentName => $composableBuilder(
    column: $table.agentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MembersTableOrderingComposer get memberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableOrderingComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InsurancePoliciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InsurancePoliciesTable> {
  $$InsurancePoliciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get insurerName => $composableBuilder(
    column: $table.insurerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planType =>
      $composableBuilder(column: $table.planType, builder: (column) => column);

  GeneratedColumn<String> get policyNumber => $composableBuilder(
    column: $table.policyNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get policyHolder => $composableBuilder(
    column: $table.policyHolder,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sumInsured => $composableBuilder(
    column: $table.sumInsured,
    builder: (column) => column,
  );

  GeneratedColumn<double> get premium =>
      $composableBuilder(column: $table.premium, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get validFrom =>
      $composableBuilder(column: $table.validFrom, builder: (column) => column);

  GeneratedColumn<String> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get helplinePhone => $composableBuilder(
    column: $table.helplinePhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get agentName =>
      $composableBuilder(column: $table.agentName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MembersTableAnnotationComposer get memberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> insuranceDocumentsRefs<T extends Object>(
    Expression<T> Function($$InsuranceDocumentsTableAnnotationComposer a) f,
  ) {
    final $$InsuranceDocumentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.insuranceDocuments,
          getReferencedColumn: (t) => t.policyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InsuranceDocumentsTableAnnotationComposer(
                $db: $db,
                $table: $db.insuranceDocuments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$InsurancePoliciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InsurancePoliciesTable,
          InsurancePolicy,
          $$InsurancePoliciesTableFilterComposer,
          $$InsurancePoliciesTableOrderingComposer,
          $$InsurancePoliciesTableAnnotationComposer,
          $$InsurancePoliciesTableCreateCompanionBuilder,
          $$InsurancePoliciesTableUpdateCompanionBuilder,
          (InsurancePolicy, $$InsurancePoliciesTableReferences),
          InsurancePolicy,
          PrefetchHooks Function({bool memberId, bool insuranceDocumentsRefs})
        > {
  $$InsurancePoliciesTableTableManager(
    _$AppDatabase db,
    $InsurancePoliciesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InsurancePoliciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InsurancePoliciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InsurancePoliciesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<String> insurerName = const Value.absent(),
                Value<String> planType = const Value.absent(),
                Value<String?> policyNumber = const Value.absent(),
                Value<String?> policyHolder = const Value.absent(),
                Value<double?> sumInsured = const Value.absent(),
                Value<double?> premium = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> validFrom = const Value.absent(),
                Value<String?> validUntil = const Value.absent(),
                Value<String?> helplinePhone = const Value.absent(),
                Value<String?> agentName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InsurancePoliciesCompanion(
                id: id,
                memberId: memberId,
                insurerName: insurerName,
                planType: planType,
                policyNumber: policyNumber,
                policyHolder: policyHolder,
                sumInsured: sumInsured,
                premium: premium,
                currency: currency,
                validFrom: validFrom,
                validUntil: validUntil,
                helplinePhone: helplinePhone,
                agentName: agentName,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String memberId,
                required String insurerName,
                Value<String> planType = const Value.absent(),
                Value<String?> policyNumber = const Value.absent(),
                Value<String?> policyHolder = const Value.absent(),
                Value<double?> sumInsured = const Value.absent(),
                Value<double?> premium = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> validFrom = const Value.absent(),
                Value<String?> validUntil = const Value.absent(),
                Value<String?> helplinePhone = const Value.absent(),
                Value<String?> agentName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => InsurancePoliciesCompanion.insert(
                id: id,
                memberId: memberId,
                insurerName: insurerName,
                planType: planType,
                policyNumber: policyNumber,
                policyHolder: policyHolder,
                sumInsured: sumInsured,
                premium: premium,
                currency: currency,
                validFrom: validFrom,
                validUntil: validUntil,
                helplinePhone: helplinePhone,
                agentName: agentName,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InsurancePoliciesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({memberId = false, insuranceDocumentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (insuranceDocumentsRefs) db.insuranceDocuments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (memberId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.memberId,
                                    referencedTable:
                                        $$InsurancePoliciesTableReferences
                                            ._memberIdTable(db),
                                    referencedColumn:
                                        $$InsurancePoliciesTableReferences
                                            ._memberIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (insuranceDocumentsRefs)
                        await $_getPrefetchedData<
                          InsurancePolicy,
                          $InsurancePoliciesTable,
                          InsuranceDocument
                        >(
                          currentTable: table,
                          referencedTable: $$InsurancePoliciesTableReferences
                              ._insuranceDocumentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InsurancePoliciesTableReferences(
                                db,
                                table,
                                p0,
                              ).insuranceDocumentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.policyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InsurancePoliciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InsurancePoliciesTable,
      InsurancePolicy,
      $$InsurancePoliciesTableFilterComposer,
      $$InsurancePoliciesTableOrderingComposer,
      $$InsurancePoliciesTableAnnotationComposer,
      $$InsurancePoliciesTableCreateCompanionBuilder,
      $$InsurancePoliciesTableUpdateCompanionBuilder,
      (InsurancePolicy, $$InsurancePoliciesTableReferences),
      InsurancePolicy,
      PrefetchHooks Function({bool memberId, bool insuranceDocumentsRefs})
    >;
typedef $$InsuranceDocumentsTableCreateCompanionBuilder =
    InsuranceDocumentsCompanion Function({
      required String id,
      required String policyId,
      required String filePath,
      required String fileName,
      required String mimeType,
      required int sizeBytes,
      Value<String?> thumbnailPath,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$InsuranceDocumentsTableUpdateCompanionBuilder =
    InsuranceDocumentsCompanion Function({
      Value<String> id,
      Value<String> policyId,
      Value<String> filePath,
      Value<String> fileName,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<String?> thumbnailPath,
      Value<String> createdAt,
      Value<int> rowid,
    });

final class $$InsuranceDocumentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InsuranceDocumentsTable,
          InsuranceDocument
        > {
  $$InsuranceDocumentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InsurancePoliciesTable _policyIdTable(_$AppDatabase db) =>
      db.insurancePolicies.createAlias(
        $_aliasNameGenerator(
          db.insuranceDocuments.policyId,
          db.insurancePolicies.id,
        ),
      );

  $$InsurancePoliciesTableProcessedTableManager get policyId {
    final $_column = $_itemColumn<String>('policy_id')!;

    final manager = $$InsurancePoliciesTableTableManager(
      $_db,
      $_db.insurancePolicies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_policyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InsuranceDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $InsuranceDocumentsTable> {
  $$InsuranceDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$InsurancePoliciesTableFilterComposer get policyId {
    final $$InsurancePoliciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.policyId,
      referencedTable: $db.insurancePolicies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InsurancePoliciesTableFilterComposer(
            $db: $db,
            $table: $db.insurancePolicies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InsuranceDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InsuranceDocumentsTable> {
  $$InsuranceDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$InsurancePoliciesTableOrderingComposer get policyId {
    final $$InsurancePoliciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.policyId,
      referencedTable: $db.insurancePolicies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InsurancePoliciesTableOrderingComposer(
            $db: $db,
            $table: $db.insurancePolicies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InsuranceDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InsuranceDocumentsTable> {
  $$InsuranceDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$InsurancePoliciesTableAnnotationComposer get policyId {
    final $$InsurancePoliciesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.policyId,
          referencedTable: $db.insurancePolicies,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InsurancePoliciesTableAnnotationComposer(
                $db: $db,
                $table: $db.insurancePolicies,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$InsuranceDocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InsuranceDocumentsTable,
          InsuranceDocument,
          $$InsuranceDocumentsTableFilterComposer,
          $$InsuranceDocumentsTableOrderingComposer,
          $$InsuranceDocumentsTableAnnotationComposer,
          $$InsuranceDocumentsTableCreateCompanionBuilder,
          $$InsuranceDocumentsTableUpdateCompanionBuilder,
          (InsuranceDocument, $$InsuranceDocumentsTableReferences),
          InsuranceDocument,
          PrefetchHooks Function({bool policyId})
        > {
  $$InsuranceDocumentsTableTableManager(
    _$AppDatabase db,
    $InsuranceDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InsuranceDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InsuranceDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InsuranceDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> policyId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InsuranceDocumentsCompanion(
                id: id,
                policyId: policyId,
                filePath: filePath,
                fileName: fileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                thumbnailPath: thumbnailPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String policyId,
                required String filePath,
                required String fileName,
                required String mimeType,
                required int sizeBytes,
                Value<String?> thumbnailPath = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => InsuranceDocumentsCompanion.insert(
                id: id,
                policyId: policyId,
                filePath: filePath,
                fileName: fileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                thumbnailPath: thumbnailPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InsuranceDocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({policyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (policyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.policyId,
                                referencedTable:
                                    $$InsuranceDocumentsTableReferences
                                        ._policyIdTable(db),
                                referencedColumn:
                                    $$InsuranceDocumentsTableReferences
                                        ._policyIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InsuranceDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InsuranceDocumentsTable,
      InsuranceDocument,
      $$InsuranceDocumentsTableFilterComposer,
      $$InsuranceDocumentsTableOrderingComposer,
      $$InsuranceDocumentsTableAnnotationComposer,
      $$InsuranceDocumentsTableCreateCompanionBuilder,
      $$InsuranceDocumentsTableUpdateCompanionBuilder,
      (InsuranceDocument, $$InsuranceDocumentsTableReferences),
      InsuranceDocument,
      PrefetchHooks Function({bool policyId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$VisitsTableTableManager get visits =>
      $$VisitsTableTableManager(_db, _db.visits);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$VisitDraftsTableTableManager get visitDrafts =>
      $$VisitDraftsTableTableManager(_db, _db.visitDrafts);
  $$InsurancePoliciesTableTableManager get insurancePolicies =>
      $$InsurancePoliciesTableTableManager(_db, _db.insurancePolicies);
  $$InsuranceDocumentsTableTableManager get insuranceDocuments =>
      $$InsuranceDocumentsTableTableManager(_db, _db.insuranceDocuments);
}
