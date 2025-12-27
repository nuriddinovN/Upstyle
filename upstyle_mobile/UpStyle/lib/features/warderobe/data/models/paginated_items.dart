import 'package:equatable/equatable.dart';
import '../../domain/entities/item.dart';

class PaginatedItems extends Equatable {
  final List<Item> items;
  final bool hasMore;
  final String? nextPageToken;
  final int totalCount;

  const PaginatedItems({
    required this.items,
    required this.hasMore,
    this.nextPageToken,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [items, hasMore, nextPageToken, totalCount];
}
