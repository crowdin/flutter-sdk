import 'package:flutter/material.dart';

import '../../crowdin_sdk.dart';

/// Wrap your app root widget with the CrowdinRealTimePreviewWidget to provide UI updates after
/// translation updates receiving
class CrowdinRealTimePreviewWidget extends StatefulWidget {
  final Widget child;

  const CrowdinRealTimePreviewWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<CrowdinRealTimePreviewWidget> createState() =>
      _CrowdinRealTimePreviewWidgetState();
}

class _CrowdinRealTimePreviewWidgetState
    extends State<CrowdinRealTimePreviewWidget> {
  final GlobalKey<_CrowdinRealTimePreviewWidgetState> childKey =
      GlobalKey<_CrowdinRealTimePreviewWidgetState>();

  @override
  void initState() {
    super.initState();
    if (Crowdin.withRealTimeUpdates) {
      Crowdin.crowdinPreviewManager.init((key) {
        _rebuildTree(key);
      });
    }
  }

  // rebuild every widget in the tree without calling setState()
  void _rebuildTree(String textKey) {
    (context as Element).visitChildElements(
        (element) => _elementRebuildVisitor(element, textKey));
  }

  void _elementRebuildVisitor(Element element, String textKey) {
    ///todo find certain text widget and rebuild his ancestors
    // if(element.renderObject is RenderParagraph) {
    //   RenderParagraph rObj = element.renderObject as RenderParagraph;
    //   String crowdinText = Crowdin.getText('en', textKey) ?? '';
    //   // if(rObj.text.toPlainText() == Crowdin.getText('en', textKey)) {
    //     element.visitAncestorElements((element) {
    //       print('------markNeedsBuild');
    //
    //       element.markNeedsBuild();
    //       return true;
    //     });
    //   // }
    //   // print(rObj.text.toPlainText());
    // }

    element
      ..markNeedsBuild()
      ..visitChildren((element) => _elementRebuildVisitor(element, textKey));
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      key: childKey,
      builder: (context) => widget.child,
    );
  }
}
