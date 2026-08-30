/// A single member of the local expense group.
///
/// Kept intentionally lightweight — no phone numbers, no auth, no network
/// identity. Just a name, because that's all a transient ad-hoc group needs.
class Participant {
  final String id;
  final String name;

  const Participant({required this.id, required this.name});

  @override
  bool operator ==(Object other) => other is Participant && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
