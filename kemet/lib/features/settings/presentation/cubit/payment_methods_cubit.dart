import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kemet/features/settings/domain/models/payment_card.dart';

class PaymentMethodsState extends Equatable {
  final List<PaymentCard> cards;
  final bool isSaving;

  const PaymentMethodsState({required this.cards, this.isSaving = false});

  PaymentMethodsState copyWith({List<PaymentCard>? cards, bool? isSaving}) {
    return PaymentMethodsState(
      cards: cards ?? this.cards,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object> get props => [cards, isSaving];
}

class PaymentMethodsCubit extends Cubit<PaymentMethodsState> {
  static const String _cardsKey = 'settings_payment_cards';
  final SharedPreferences sharedPreferences;

  PaymentMethodsCubit({required this.sharedPreferences})
      : super(PaymentMethodsState(cards: _loadInitialCards(sharedPreferences)));

  static List<PaymentCard> _loadInitialCards(SharedPreferences prefs) {
    final raw = prefs.getString(_cardsKey);
    if (raw == null || raw.isEmpty) {
      return const [
        PaymentCard(
          id: 'card_1',
          brand: 'Visa',
          last4: '4242',
          holderName: 'Kemet Traveler',
          expiry: '12/28',
          isDefault: true,
        ),
        PaymentCard(
          id: 'card_2',
          brand: 'Mastercard',
          last4: '8888',
          holderName: 'Kemet Explorer',
          expiry: '10/27',
          isDefault: false,
        ),
      ];
    }

    final decoded = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(PaymentCard.fromMap)
        .toList();
    return decoded;
  }

  Future<void> _persist(List<PaymentCard> cards) async {
    await sharedPreferences.setString(
      _cardsKey,
      jsonEncode(cards.map((card) => card.toMap()).toList()),
    );
  }

  Future<void> addCard({
    required String brand,
    required String last4,
    required String holderName,
    required String expiry,
  }) async {
    emit(state.copyWith(isSaving: true));
    final updated = [
      ...state.cards.map((card) => card.copyWith(isDefault: false)),
      PaymentCard(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        brand: brand,
        last4: last4,
        holderName: holderName,
        expiry: expiry,
        isDefault: state.cards.isEmpty,
      ),
    ];
    emit(state.copyWith(cards: updated, isSaving: false));
    await _persist(updated);
  }

  Future<void> setDefault(String id) async {
    final updated = state.cards
        .map((card) => card.copyWith(isDefault: card.id == id))
        .toList();
    emit(state.copyWith(cards: updated));
    await _persist(updated);
  }

  Future<void> deleteCard(String id) async {
    final updated = state.cards.where((card) => card.id != id).toList();
    if (updated.isNotEmpty && updated.every((card) => !card.isDefault)) {
      updated[0] = updated[0].copyWith(isDefault: true);
    }
    emit(state.copyWith(cards: updated));
    await _persist(updated);
  }
}

