import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rbike_mobile/models/bike.dart';
import 'package:rbike_mobile/models/reservation.dart';
import 'package:rbike_mobile/models/review.dart';
import 'package:rbike_mobile/models/comment.dart';
import 'package:rbike_mobile/providers/auth_provider.dart';
import 'package:rbike_mobile/providers/bike_favorite_provider.dart';
import 'package:rbike_mobile/providers/reservation_provider.dart';
import 'package:rbike_mobile/providers/review_provider.dart';
import 'package:rbike_mobile/providers/comment_provider.dart';
import 'package:rbike_mobile/providers/utils.dart';
import 'package:rbike_mobile/layouts/master_screen.dart';

class BikeDetailsScreen extends StatefulWidget {
  final Bike bike;

  const BikeDetailsScreen({Key? key, required this.bike}) : super(key: key);

  @override
  State<BikeDetailsScreen> createState() => _BikeDetailsScreenState();
}

class _BikeDetailsScreenState extends State<BikeDetailsScreen> {
  final ReservationProvider _reservationProvider = ReservationProvider();
  final BikeFavoriteProvider _bikeFavoriteProvider = BikeFavoriteProvider();
  final ReviewProvider _reviewProvider = ReviewProvider();
  final CommentProvider _commentProvider = CommentProvider();

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentsKey = GlobalKey();

  DateTime? _startDateTime;
  DateTime? _endDateTime;
  List<Reservation> _existingReservations = [];
  bool _isSubmitting = false;
  bool _isFavorite = false;
  bool _isLoadingFavorite = true;

  double _averageRating = 0.0;
  Review? _userReview;
  int _userRating = 0;
  List<Comment> _comments = [];
  bool _showComments = false;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoadingRating = true;
  bool _isLoadingComments = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDateTime = now.add(Duration(hours: 1));
    _endDateTime = now.add(Duration(hours: 2));
    _fetchReservationsForDate(_startDateTime!);
    _checkFavoriteStatus();
    _loadRatingData();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadRatingData() async {
    if (AuthProvider.userId == null) {
      setState(() {
        _isLoadingRating = false;
      });
      return;
    }

    try {
      final average = await _reviewProvider.getAverageRating(
        widget.bike.bikeId!,
      );
      final userReview = await _reviewProvider.getUserReview(
        widget.bike.bikeId!,
        AuthProvider.userId!,
      );

      if (mounted) {
        setState(() {
          _averageRating = average;
          _userReview = userReview;
          _userRating = userReview?.rating ?? 0;
          _isLoadingRating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRating = false;
        });
      }
    }
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _commentProvider.getCommentsForBike(
        widget.bike.bikeId!,
      );
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
        });
      }
    }
  }

  Future<void> _showResultDialog(
    String title,
    String content, {
    bool success = true,
  }) async {
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: success ? Colors.green[50] : Colors.red[50],
            title: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(color: success ? Colors.green : Colors.red),
                ),
              ],
            ),
            content: Text(content, style: TextStyle(color: Colors.black)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(color: success ? Colors.green : Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _submitRating(int rating) async {
    if (AuthProvider.userId == null) {
      await _showResultDialog(
        'Greška',
        'Molimo prijavite se da ocijenite bicikl',
        success: false,
      );
      return;
    }

    try {
      await _reviewProvider.addReview(
        widget.bike.bikeId!,
        AuthProvider.userId!,
        rating,
      );
      await _loadRatingData();
      await _showResultDialog(
        'Uspješno',
        'Uspješno ste ocijenili bicikl',
        success: true,
      );
    } catch (e) {
      await _showResultDialog(
        'Greška',
        'Greška: ${e.toString()}',
        success: false,
      );
    }
  }

  Future<void> _submitComment() async {
    if (AuthProvider.userId == null) {
      await _showResultDialog(
        'Greška',
        'Molimo prijavite se da dodate komentar',
        success: false,
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      await _showResultDialog(
        'Greška',
        'Molimo unesite komentar',
        success: false,
      );
      return;
    }

    try {
      await _commentProvider.addComment(
        widget.bike.bikeId!,
        AuthProvider.userId!,
        _commentController.text.trim(),
      );
      _commentController.clear();
      await _loadComments();
      await _showResultDialog(
        'Uspješno',
        'Komentar uspješno dodan',
        success: true,
      );
    } catch (e) {
      await _showResultDialog(
        'Greška',
        'Greška: ${e.toString()}',
        success: false,
      );
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (AuthProvider.userId == null) {
      setState(() {
        _isLoadingFavorite = false;
        _isFavorite = false;
      });
      return;
    }

    try {
      final isFavorite = await _bikeFavoriteProvider.isFavorite(
        widget.bike.bikeId!,
        AuthProvider.userId!,
      );
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
          _isLoadingFavorite = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
          _isFavorite = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (AuthProvider.userId == null) {
      await _showResultDialog(
        'Greška',
        'Molimo prijavite se da dodate u favorite',
        success: false,
      );
      return;
    }

    setState(() => _isLoadingFavorite = true);

    try {
      if (_isFavorite) {
        await _bikeFavoriteProvider.removeFromFavorites(
          widget.bike.bikeId!,
          AuthProvider.userId!,
        );
        if (mounted) {
          setState(() {
            _isFavorite = false;
            _isLoadingFavorite = false;
          });
          await _showResultDialog(
            'Uspješno',
            'Uklonjeno iz favorita',
            success: true,
          );
        }
      } else {
        await _bikeFavoriteProvider.addToFavorites(
          widget.bike.bikeId!,
          AuthProvider.userId!,
        );
        if (mounted) {
          setState(() {
            _isFavorite = true;
            _isLoadingFavorite = false;
          });
          await _showResultDialog(
            'Uspješno',
            'Dodano u favorite',
            success: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFavorite = false);
        await _showResultDialog(
          'Greška',
          'Greška: ${e.toString()}',
          success: false,
        );
      }
    }
  }

  Future<void> _fetchReservationsForDate(DateTime date) async {
    try {
      var reservations = await _reservationProvider.getReservationsForDate(
        widget.bike.bikeId!,
        date,
      );
      if (!mounted) return;
      final now = DateTime.now();
      setState(() {
        _existingReservations =
            reservations.where((r) {
              final status = r.status?.toLowerCase();
              final end =
                  r.endDateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
              return (status == 'active' || status == 'processed') &&
                  end.isAfter(now);
            }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri učitavanju rezervacija')),
        );
      }
    }
  }

  bool _isTimeSlotAvailable(DateTime start, DateTime end) {
    final now = DateTime.now();
    for (var res in _existingReservations) {
      final s = res.startDateTime!;
      final e = res.endDateTime!;
      if (e.isBefore(now)) continue;
      if (start.isBefore(e) && end.isAfter(s)) return false;
    }
    return true;
  }

  Future<void> _showReservationForm() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                Future<void> pickStart() async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDateTime!,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 30)),
                  );
                  if (!mounted || picked == null) return;

                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_startDateTime!),
                  );
                  if (!mounted || time == null) return;

                  setModalState(() {
                    _startDateTime = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      time.hour,
                      time.minute,
                    );
                    if (_endDateTime!.isBefore(_startDateTime!)) {
                      _endDateTime = _startDateTime!.add(Duration(hours: 1));
                    }
                  });

                  await _fetchReservationsForDate(_startDateTime!);
                  if (mounted) setModalState(() {});
                }

                Future<void> pickEnd() async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDateTime!,
                    firstDate: _startDateTime!,
                    lastDate: _startDateTime!.add(Duration(days: 30)),
                  );
                  if (!mounted || picked == null) return;

                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_endDateTime!),
                  );
                  if (!mounted || time == null) return;

                  setModalState(() {
                    _endDateTime = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }

                Widget calendarPreview() {
                  return Container(
                    height: 100,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(7, (index) {
                          final day = _startDateTime!.add(
                            Duration(days: index),
                          );
                          final dayStart = DateTime(
                            day.year,
                            day.month,
                            day.day,
                          );
                          final dayEnd = dayStart.add(Duration(days: 1));
                          final busy = _existingReservations.any((res) {
                            return res.startDateTime!.isBefore(dayEnd) &&
                                res.endDateTime!.isAfter(dayStart);
                          });

                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: 40,
                            decoration: BoxDecoration(
                              color: busy ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              DateFormat('dd').format(day),
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Rezervacija bicikla",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      calendarPreview(),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: pickStart,
                              child: Text(
                                _startDateTime == null
                                    ? "Odaberi početak"
                                    : DateFormat(
                                      'dd.MM.yyyy HH:mm',
                                    ).format(_startDateTime!),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextButton(
                              onPressed: pickEnd,
                              child: Text(
                                _endDateTime == null
                                    ? "Odaberi kraj"
                                    : DateFormat(
                                      'dd.MM.yyyy HH:mm',
                                    ).format(_endDateTime!),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      ElevatedButton(
                        onPressed:
                            _isSubmitting
                                ? null
                                : () async {
                                  if (_startDateTime == null ||
                                      _endDateTime == null) {
                                    await _showResultDialog(
                                      'Greška',
                                      'Molimo odaberite oba vremena.',
                                    );
                                    return;
                                  }

                                  if (AuthProvider.userId == null) {
                                    await _showResultDialog(
                                      'Greška',
                                      'Korisnik nije prijavljen.',
                                    );
                                    return;
                                  }

                                  if (!_isTimeSlotAvailable(
                                    _startDateTime!,
                                    _endDateTime!,
                                  )) {
                                    await _showResultDialog(
                                      'Greška',
                                      'Odabrani termin je već zauzet. Molimo odaberite drugi termin.',
                                      success: false,
                                    );
                                    return;
                                  }

                                  setState(() => _isSubmitting = true);
                                  try {
                                    await _reservationProvider
                                        .insertReservation({
                                          "bikeId": widget.bike.bikeId,
                                          "startDateTime":
                                              _startDateTime!.toIso8601String(),
                                          "endDateTime":
                                              _endDateTime!.toIso8601String(),
                                          "userId": AuthProvider.userId,
                                        });

                                    await _fetchReservationsForDate(
                                      _startDateTime!,
                                    );
                                    if (mounted) setModalState(() {});

                                    await _showResultDialog(
                                      'Uspješno',
                                      'Rezervacija uspješno kreirana!',
                                    );
                                  } catch (e) {
                                    String message =
                                        "Greška pri kreiranju rezervacije";
                                    if (e.toString().toLowerCase().contains(
                                      "reserved",
                                    )) {
                                      message =
                                          "Odabrani termin je već zauzet.";
                                    }
                                    await _showResultDialog(message, message);
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isSubmitting = false);
                                    }
                                  }
                                },
                        child: Text("Rezerviši"),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bike = widget.bike;
    return MasterScreen(
      bike.name ?? 'Detalji bicikla',
      SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bike.image == null
                ? Container(height: 250, color: Colors.grey)
                : Image.memory(
                  base64Decode(bike.image!),
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.label, size: 28, color: Colors.black54),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bike.name ?? '',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 24, color: Colors.black54),
                      SizedBox(width: 6),
                      Text(
                        'Cijena po danu: ${formatNumber(bike.price)} KM',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _showReservationForm,
                      child: Text("Rezerviši"),
                    ),
                  ),
                  SizedBox(height: 24),

                  if (!_isLoadingRating) ...[
                    Row(
                      children: [
                        Icon(Icons.star, size: 24, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'Ocjena: ${_averageRating.toStringAsFixed(1)}/5.0',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    if (_userReview != null) ...[
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Vaša ocjena: ${_userReview!.rating}/5',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.amber[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                    ],

                    if (_userReview == null) ...[
                      Text(
                        'Ocijenite ovaj bicikl:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () => _submitRating(index + 1),
                            child: Icon(
                              index < _userRating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 32,
                              color: Colors.amber,
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 24),
                    ],
                  ],

                  Text(
                    'Dodajte komentar:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Napišite svoj komentar...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _submitComment,
                    child: Text('Dodaj komentar'),
                  ),
                  SizedBox(height: 24),

                  Row(
                    key: _commentsKey,
                    children: [
                      Text(
                        'Komentari (${_comments.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            _showComments = !_showComments;
                          });
                          await Future.delayed(Duration(milliseconds: 100));
                          if (_showComments) {
                            final context = _commentsKey.currentContext;
                            if (context != null) {
                              Scrollable.ensureVisible(
                                context,
                                duration: Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            }
                          } else {
                            _scrollController.animateTo(
                              0,
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(_showComments ? 'Sakrij' : 'Prikaži'),
                      ),
                    ],
                  ),
                  if (_showComments && !_isLoadingComments) ...[
                    SizedBox(height: 8),
                    if (_comments.isEmpty)
                      Text(
                        'Još nema komentara za ovaj bicikl.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        comment.username ?? 'Anonimni korisnik',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        comment.dateAdded != null
                                            ? DateFormat(
                                              'dd.MM.yyyy HH:mm',
                                            ).format(comment.dateAdded!)
                                            : '',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(comment.content ?? ''),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actionButton: IconButton(
        icon:
            _isLoadingFavorite
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : null,
                ),
        onPressed: _isLoadingFavorite ? null : _toggleFavorite,
      ),
    );
  }
}
