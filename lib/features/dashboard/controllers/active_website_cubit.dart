import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class ActiveWebsiteState extends Equatable {
  final Map<String, dynamic>? website;
  final bool isLoading;

  const ActiveWebsiteState({this.website, this.isLoading = false});

  @override
  List<Object?> get props => [website, isLoading];

  ActiveWebsiteState copyWith({
    Map<String, dynamic>? website,
    bool? isLoading,
  }) {
    return ActiveWebsiteState(
      website: website ?? this.website,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  String? get websiteId => website?['id'];
  String? get websiteType => website?['website_type'] ?? 'landing_page';
  String? get subdomain => website?['subdomain'];
  String? get feedToken => website?['feed_token'];
  String? get customDomain => website?['custom_domain'];
  String? get domainStatus => website?['domain_status'] ?? 'pending';
  String? get domainVerificationToken => website?['domain_verification_token'];
}

class ActiveWebsiteCubit extends Cubit<ActiveWebsiteState> {
  ActiveWebsiteCubit() : super(const ActiveWebsiteState());

  void selectWebsite(Map<String, dynamic> website) {
    emit(state.copyWith(website: website, isLoading: false));
  }

  void updateActiveWebsiteType(String type) {
    if (state.website != null) {
      final updated = Map<String, dynamic>.from(state.website!);
      updated['website_type'] = type;
      emit(state.copyWith(website: updated));
    }
  }

  void clearSelection() {
    emit(const ActiveWebsiteState());
  }

  void setLoading(bool loading) {
    emit(state.copyWith(isLoading: loading));
  }
}
