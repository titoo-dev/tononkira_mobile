import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tononkira_mobile/data/database_helper.dart';
import 'package:tononkira_mobile/features/home/widgets/featured_section.dart';
import 'package:tononkira_mobile/features/home/widgets/floating_search_button.dart';
import 'package:tononkira_mobile/features/home/widgets/home_app_bar.dart';
import 'package:tononkira_mobile/features/home/widgets/recent_lyric_item.dart';
import 'package:tononkira_mobile/features/home/widgets/section_header.dart';
import 'package:tononkira_mobile/models/models.dart';
import 'package:tononkira_mobile/shared/loader.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingSearchButton = false;

  late Future<Map<String, List<Song>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _dataFuture = _loadData();
  }

  Future<Map<String, List<Song>>> _loadData() async {
    final db = await DatabaseHelper.instance.database;

    // Load songs with artists (featured songs - limit to 5)
    final featuredSongsData = await db.rawQuery('''
      SELECT s.id, s.title, s.slug, s.views, s.createdAt, s.updatedAt 
      FROM Song s 
      ORDER BY s.views DESC LIMIT 5
    ''');

    // Load recent songs (limit to 10)
    final recentSongsData = await db.rawQuery('''
      SELECT s.id, s.title, s.slug, s.views, s.createdAt, s.updatedAt 
      FROM Song s 
      ORDER BY s.createdAt DESC LIMIT 10
    ''');

    final featuredSongs = await DatabaseHelper.instance.transformSongsData(
      featuredSongsData,
    );
    final recentSongs = await DatabaseHelper.instance.transformSongsData(
      recentSongsData,
    );

    return {'featured': featuredSongs, 'recent': recentSongs};
  }

  void _onScroll() {
    const threshold = 150.0;
    if (_scrollController.offset > threshold && !_showFloatingSearchButton) {
      setState(() {
        _showFloatingSearchButton = true;
      });
    } else if (_scrollController.offset <= threshold &&
        _showFloatingSearchButton) {
      setState(() {
        _showFloatingSearchButton = false;
      });
    }
  }

  void _openSearch() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    FocusScope.of(context).requestFocus(FocusNode());
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton:
          _showFloatingSearchButton
              ? FloatingSearchButton(onPressed: _openSearch)
              : null,
      body: SafeArea(
        child: FutureBuilder<Map<String, List<Song>>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Loader());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'Failed to load data. Please try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No data available. Please try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              );
            }

            final featuredSongs = snapshot.data!['featured'] ?? [];
            final recentSongs = snapshot.data!['recent'] ?? [];

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _dataFuture = _loadData();
                });
                await _dataFuture;
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: HomeAppBar(
                      title: 'Tononkira',
                      searchController: _searchController,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child:
                        featuredSongs.isEmpty
                            ? const SizedBox(height: 16)
                            : FeaturedSection(featuredSongs: featuredSongs),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(
                    child: SectionHeader(title: "Recent Lyrics"),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  recentSongs.isEmpty
                      ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'No lyrics found. Try importing data first.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      )
                      : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final song = recentSongs[index];
                          return RecentLyricItem(song: song);
                        }, childCount: recentSongs.length),
                      ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
