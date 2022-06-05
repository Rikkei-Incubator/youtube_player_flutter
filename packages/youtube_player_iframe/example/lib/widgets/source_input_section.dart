// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

///
class SourceInputSection extends StatefulWidget {
  @override
  _SourceInputSectionState createState() => _SourceInputSectionState();
}

class _SourceInputSectionState extends State<SourceInputSection> {
  late TextEditingController _textController;
  ListType? _playlistType;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubeValueBuilder(
      builder: (context, value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlaylistTypeDropDown(
              onChanged: (type) => _playlistType = type,
            ),
            const SizedBox(height: 10),
            TextField(
              enabled: value.isReady,
              controller: _textController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: _hint,
                helperText: _helperText,
                fillColor: Theme.of(context).primaryColor.withAlpha(20),
                filled: true,
                hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _textController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 20 / 6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: [
                _Button(
                  action: 'LOAD',
                  onTap: () {
                    context.ytController.loadVideoById(
                      videoId: _cleanId(_textController.text) ?? '',
                    );
                  },
                ),
                _Button(
                  action: 'CUE',
                  onTap: () {
                    context.ytController.cueVideoById(
                      videoId: _cleanId(_textController.text) ?? '',
                    );
                  },
                ),
                _Button(
                  action: 'LOAD PLAYLIST',
                  onTap: _playlistType == null
                      ? null
                      : () {
                          context.ytController.loadPlaylist(
                            list: [_textController.text],
                            listType: _playlistType!,
                          );
                        },
                ),
                _Button(
                  action: 'CUE PLAYLIST',
                  onTap: _playlistType == null
                      ? null
                      : () {
                          context.ytController.cuePlaylist(
                            list: [_textController.text],
                            listType: _playlistType!,
                          );
                        },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String? get _helperText {
    switch (_playlistType) {
      case ListType.playlist:
        return '"PLj0L3ZL0ijTdhFSueRKK-mLFAtDuvzdje", ...';
      case ListType.userUploads:
        return '"pewdiepie", "tseries"';
      default:
        return null;
    }
  }

  String get _hint {
    switch (_playlistType) {
      case ListType.playlist:
        return 'Enter playlist id';
      case ListType.userUploads:
        return 'Enter channel name';
      default:
        return 'Enter youtube \<video id\> or \<link\>';
    }
  }

  String? _cleanId(String source) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return YoutubePlayerController.convertUrlToId(source);
    } else if (source.length != 11) {
      _showSnackBar('Invalid Source');
    }
    return source;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class _PlaylistTypeDropDown extends StatefulWidget {
  const _PlaylistTypeDropDown({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  final ValueChanged<ListType> onChanged;

  @override
  _PlaylistTypeDropDownState createState() => _PlaylistTypeDropDownState();
}

class _PlaylistTypeDropDownState extends State<_PlaylistTypeDropDown> {
  ListType? _playlistType;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<ListType>(
      isExpanded: true,
      hint: const Text(
        ' -- Choose playlist type',
        style: TextStyle(fontWeight: FontWeight.w400),
      ),
      value: _playlistType,
      items: ListType.values
          .map(
            (type) => DropdownMenuItem(child: Text(type.value), value: type),
          )
          .toList(),
      onChanged: (value) {
        _playlistType = value;
        setState(() {});
        if (value != null) widget.onChanged(value);
      },
    );
  }
}

class _Button extends StatelessWidget {
  final VoidCallback? onTap;
  final String action;

  const _Button({
    Key? key,
    required this.onTap,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Theme.of(context).primaryColor,
      onPressed: onTap == null
          ? null
          : () {
              onTap?.call();
              FocusScope.of(context).unfocus();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Text(
          action,
          style: const TextStyle(
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
