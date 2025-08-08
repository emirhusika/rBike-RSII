import 'package:flutter/material.dart';
import 'package:rbike_admin/models/comment.dart';
import 'package:rbike_admin/models/search_result.dart';
import 'package:rbike_admin/providers/comment_provider.dart';
import 'package:rbike_admin/providers/popup_dialogs.dart';
import 'package:rbike_admin/layouts/master_screen.dart';
import 'package:rbike_admin/widgets/pagination_widget.dart';

class CommentsScreen extends StatefulWidget {
  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final CommentProvider _commentProvider = CommentProvider();
  SearchResult<Comment>? result = null;
  bool _isLoading = true;

  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    
    try {
      var filter = {
        'page': _currentPage,
        'pageSize': _pageSize,
      };

      result = await _commentProvider.get(filter: filter);
    } catch (e) {
      MyDialogs.showError(context, 'Greška pri učitavanju komentara: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      await _commentProvider.deleteComment(commentId);
      await _loadComments();
      MyDialogs.showSuccess(
        context,
        'Komentar uspješno obrisan',
        () {},
      );
    } catch (e) {
      MyDialogs.showError(context, 'Greška pri brisanju komentara: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Komentari',
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 249, 248, 248),
              const Color.fromARGB(255, 73, 70, 70),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: MediaQuery.of(context).size.width * 0.8,
                                  ),
                                  child: DataTable(
                                    headingRowColor: MaterialStateProperty.resolveWith(
                                      (states) => Colors.blueGrey.shade200,
                                    ),
                                    columns: [
                                      DataColumn(label: Text('Bicikl')),
                                      DataColumn(label: Text('Korisnik')),
                                      DataColumn(label: Text('Komentar')),
                                      DataColumn(label: Text('Datum')),
                                      DataColumn(label: Text('Akcija')),
                                    ],
                                    rows: (result?.result ?? []).map((comment) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(comment.bikeName ?? '')),
                                          DataCell(Text(comment.username ?? '')),
                                          DataCell(
                                            Container(
                                              width: 200,
                                              child: Text(
                                                comment.content ?? '',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              comment.dateAdded != null
                                                  ? '${comment.dateAdded!.day}.${comment.dateAdded!.month}.${comment.dateAdded!.year} ${comment.dateAdded!.hour}:${comment.dateAdded!.minute}'
                                                  : '',
                                            ),
                                          ),
                                          DataCell(
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                MyDialogs.showQuestion(
                                                  context,
                                                  'Da li ste sigurni da želite obrisati ovaj komentar?',
                                                  () {
                                                    _deleteComment(comment.commentId!);
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildPaginationControls(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return PaginationWidget(
      currentPage: _currentPage,
      totalCount: result?.count ?? 0,
      pageSize: _pageSize,
      isLoading: _isLoading,
      onPageChanged: (newPage) {
        setState(() => _currentPage = newPage);
        _loadComments();
      },
    );
  }
}
