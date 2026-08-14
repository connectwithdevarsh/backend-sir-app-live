/// QualificationItem represents an academic degree qualification.
class QualificationItem {
  final String degree;
  final String institution;
  final String year;
  final String? specialization;

  const QualificationItem({
    required this.degree,
    required this.institution,
    required this.year,
    this.specialization,
  });
}

/// ExperienceItem represents teaching or professional experience.
class ExperienceItem {
  final String role;
  final String institution;
  final String duration;
  final String? description;

  const ExperienceItem({
    required this.role,
    required this.institution,
    required this.duration,
    this.description,
  });
}

/// MembershipItem represents professional memberships.
class MembershipItem {
  final String organization;
  final String detail;

  const MembershipItem({
    required this.organization,
    required this.detail,
  });
}

/// FacultyModel contains exact accurate information for Dr. Dippal P. Israni.
class FacultyModel {
  final String name;
  final String designation;
  final String department;
  final String institution;
  final String qualification;
  final String dateOfJoining;
  final String bio;
  final String subject;
  final String subjectCode;
  final String program;
  final String semester;
  final List<String> areasOfInterest;
  final List<QualificationItem> qualifications;
  final List<ExperienceItem> experiences;
  final MembershipItem membership;

  const FacultyModel({
    required this.name,
    required this.designation,
    required this.department,
    required this.institution,
    required this.qualification,
    required this.dateOfJoining,
    required this.bio,
    this.subject = 'Artificial Intelligence with Prompt Engineering',
    this.subjectCode = 'DI05016011',
    this.program = 'Diploma Engineering',
    this.semester = '5th Semester',
    required this.areasOfInterest,
    required this.qualifications,
    required this.experiences,
    required this.membership,
  });

  static const FacultyModel currentFaculty = FacultyModel(
    name: 'Dr. Dippal P. Israni',
    designation: 'Lecturer',
    department: 'Information Technology',
    institution: 'R. C. Technical Institute, Ahmedabad',
    qualification: 'Ph.D. (Computer Engineering)',
    dateOfJoining: '10-Feb-2020',
    bio: 'Dr. Dippal P. Israni is a Lecturer in the Information Technology department at R. C. Technical Institute, Ahmedabad.',
    areasOfInterest: [
      'Machine Learning',
      'Computer Vision',
      'Deep Learning',
    ],
    qualifications: [
      QualificationItem(
        degree: 'Bachelors of Engineering (BE)',
        institution: 'Sardar Patel University',
        year: '2007 – 2011',
      ),
      QualificationItem(
        degree: 'Masters of Technology (M.Tech)',
        institution: 'Dharmsinh Desai University',
        year: '2011 – 2013',
      ),
      QualificationItem(
        degree: 'Ph.D. (Computer Engineering)',
        institution: 'Charusat University',
        year: '2015 – 2020',
      ),
    ],
    experiences: [
      ExperienceItem(
        role: 'Assistant Professor',
        institution: 'Chandubhai S. Patel Institute of Technology, Charusat University',
        duration: '2013 – 2020',
      ),
      ExperienceItem(
        role: 'Lecturer',
        institution: 'R. C. Technical Institute, Ahmedabad',
        duration: '2020 – Present',
      ),
    ],
    membership: MembershipItem(
      organization: 'ISTE Membership',
      detail: 'Member since 2024',
    ),
  );
}
