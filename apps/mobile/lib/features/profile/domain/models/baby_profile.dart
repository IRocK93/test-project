class BabyProfile {
  final String name;
  final String age;
  final String weight;
  final String gender;
  final String bloodType;
  final String zodiac;

  BabyProfile({
    required this.name,
    required this.age,
    required this.weight,
    required this.gender,
    required this.bloodType,
    required this.zodiac,
  });

  factory BabyProfile.demo() {
    return BabyProfile(
      name: 'Oliver',
      age: '6 months',
      weight: '7.8',
      gender: 'Male',
      bloodType: 'O+',
      zodiac: 'Scorpio',
    );
  }
}
