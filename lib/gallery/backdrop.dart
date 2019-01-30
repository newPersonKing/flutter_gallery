
import 'package:flutter/material.dart';
import 'dart:math' as math;

const double _kFrontHeadingHeight = 32.0; // front layer beveled rectangle
const double _kFrontClosedHeight = 92.0; // front layer height when closed
const double _kBackAppBarHeight = 56.0; // back layer (options) appbar height

class Backdrop extends StatefulWidget{

  const Backdrop({
    this.frontAction,/*左上角回退按钮*/
    this.frontTitle,/*左上角title*/
    this.frontHeading,
    this.frontLayer,
    this.backTitle,
    this.backLayer,
  });

  final Widget frontAction;
  final Widget frontTitle;
  final Widget frontLayer;
  final Widget frontHeading;
  final Widget backTitle;
  final Widget backLayer;


  @override
  State<StatefulWidget> createState() =>_BackdropState();
}

class _BackdropState extends State<Backdrop> with SingleTickerProviderStateMixin{

  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');

  AnimationController _controller;
  Animation<double> _frontOpacity;

  static final Animatable<double> _frontOpacityTween = Tween<double>(begin: 0.2, end: 1.0)
      .chain(CurveTween(curve: const Interval(0.0, 0.4, curve: Curves.easeInOut)));

  @override
  void initState() {
    super.initState();
    _controller  = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),/*value 设置最终值*/
      value: 1.0,);

    _frontOpacity = _frontOpacityTween.animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _backdropHeight {
    // Warning: this can be safely called from the event handlers but it may
    // not be called at build time.
    final RenderBox renderBox = _backdropKey.currentContext.findRenderObject();
    return math.max(0.0, renderBox.size.height - _kBackAppBarHeight - _kFrontClosedHeight);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.primaryDelta / (_backdropHeight ?? details.primaryDelta);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating || _controller.status == AnimationStatus.completed)
      return;

    final double flingVelocity = details.velocity.pixelsPerSecond.dy / _backdropHeight;
    if (flingVelocity < 0.0)
      _controller.fling(velocity: math.max(2.0, -flingVelocity));
    else if (flingVelocity > 0.0)
      _controller.fling(velocity: math.min(-2.0, -flingVelocity));
    else
      _controller.fling(velocity: _controller.value < 0.5 ? -2.0 : 2.0);
  }

  void _toggleFrontLayer() {
    final AnimationStatus status = _controller.status;
    final bool isOpen = status == AnimationStatus.completed || status == AnimationStatus.forward;
    print(_controller.status);
    print(_controller.value);
    _controller.fling(velocity: isOpen ? -2.0 : 2.0);/* fling 直接跳到某个值*/
//    _controller.forward(from: 0.0);  /*forward 从某个值开始 直到结束*/
  }


  Widget _buildStack(BuildContext context, BoxConstraints constraints) {

    Animatable<RelativeRect> animatable= RelativeRectTween(
        begin: RelativeRect.fromLTRB(0.0, constraints.biggest.height - _kFrontClosedHeight, 0.0, 0.0),
        end: const RelativeRect.fromLTRB(0.0, _kBackAppBarHeight, 0.0, 0.0));
    Animation<RelativeRect> frontRelativeRect = animatable.animate(_controller);

    final List<Widget> layers = <Widget>[
      // Back layer
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,/*让children填满交叉轴方向*/
        children: <Widget>[
          _BackAppBar(
            leading: widget.frontAction,
            title: _CrossFadeTransition(  /*左上角title*/
              progress: _controller,
              alignment: AlignmentDirectional.centerStart,
              child0: Semantics(namesRoute: true, child: widget.frontTitle),
              child1: Semantics(namesRoute: true, child: widget.backTitle),
            ),
            trailing: IconButton( /*右上角切换的按钮*/
              onPressed: _toggleFrontLayer, /*点击这里 控制 controller 完成与开始*/
              tooltip: 'Toggle options page',
              icon: AnimatedIcon(
                icon: AnimatedIcons.close_menu,
                progress: _controller, /*切换动画的controller*/
              ),
            ),
          ),
          Expanded(
              child: Visibility(
                child: widget.backLayer,  /*optionsPage 根据_controller 的状态来判断optionspage 是否显示*/
                visible: _controller.status != AnimationStatus.completed,
                maintainState: true,
              )
          ),
        ],
      ),
      // Front layer
      PositionedTransition(
        rect: frontRelativeRect,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget child) {/*_controller 的值每次发生改变 就会回调 */
            return PhysicalShape(
              elevation: 100.0,
              color: Colors.red,
              clipper: ShapeBorderClipper(
                shape: BeveledRectangleBorder(
                  side: BorderSide(color: Colors.deepOrange,width: 10.0),/*暂时没看出啥效果*/
//                  borderRadius: _kFrontHeadingBevelRadius.transform(_controller.value),
                  borderRadius: BorderRadius.only(topLeft:Radius.circular(_kFrontHeadingHeight*_controller.value)),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: child,
              shadowColor: Colors.green,
            );
          },
          child: _TappableWhileStatusIs(
            AnimationStatus.completed,
            controller: _controller,
            child: FadeTransition(
              opacity: _frontOpacity,
              child: widget.frontLayer,/*主页面*/
            ),
          ),
        ),
      ),
    ];

    // The front "heading" is a (typically transparent) widget that's stacked on
    // top of, and at the top of, the front layer. It adds support for dragging
    // the front layer up and down and for opening and closing the front layer
    // with a tap. It may obscure part of the front layer's topmost child.
    if (widget.frontHeading != null) {
      layers.add(
        PositionedTransition(
          rect: frontRelativeRect,
          child: ExcludeSemantics(
            child: Container(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleFrontLayer,
                onVerticalDragUpdate: _handleDragUpdate,
                onVerticalDragEnd: _handleDragEnd,
                child: widget.frontHeading,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      key: _backdropKey,
      children: layers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _buildStack);
  }
}

class _BackAppBar extends StatelessWidget {
  const _BackAppBar({
    Key key,
    this.leading = const SizedBox(width: 56.0),
    @required this.title,
    this.trailing,
  }) : assert(leading != null), assert(title != null), super(key: key);

  final Widget leading;
  final Widget title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      Container(
        alignment: Alignment.center,
        width: 56.0,
        child: leading,
      ),
      Expanded(
        child: title,
      ),
    ];

    if (trailing != null) {
      children.add(
        Container(
          alignment: Alignment.center,
          width: 56.0,
          child: trailing,
        ),
      );
    }

    final ThemeData theme = Theme.of(context);

    return IconTheme.merge(
      data: theme.primaryIconTheme,
      child: DefaultTextStyle(
        style: theme.primaryTextTheme.title,
        child: SizedBox(
          height: _kBackAppBarHeight,
          child: Row(children: children),
        ),
      ),
    );
  }
}

class _CrossFadeTransition extends AnimatedWidget {
  const _CrossFadeTransition({
    Key key,
    this.alignment = Alignment.center,
    Animation<double> progress,
    this.child0,
    this.child1,
  }) : super(key: key, listenable: progress);

  final AlignmentGeometry alignment;
  final Widget child0;/*文字 左上角*/
  final Widget child1;/*文字 左上角*/

  @override
  Widget build(BuildContext context) {
    final Animation<double> progress = listenable;

    final double opacity1 = CurvedAnimation(
      parent: ReverseAnimation(progress),
      curve: const Interval(0.5, 1.0),
    ).value;

    final double opacity2 = CurvedAnimation(
      parent: progress,
      curve: const Interval(0.5, 1.0),
    ).value;

    return Stack(   /*左上角文字切换*/
      alignment: alignment,
      children: <Widget>[
        Opacity(
          opacity: opacity1,
          child: Semantics(
            scopesRoute: true,
            explicitChildNodes: true,
            child: child1,
          ),
        ),
        Opacity(
          opacity: opacity2,
          child: Semantics(
            scopesRoute: true,
            explicitChildNodes: true,
            child: child0,
          ),
        ),
      ],
    );
  }
}

class _TappableWhileStatusIs extends StatefulWidget {
  const _TappableWhileStatusIs(this.status, {
    Key key,
    this.controller,
    this.child,
  }) : super(key: key);

  final AnimationController controller;
  final AnimationStatus status;
  final Widget child;

  @override
  _TappableWhileStatusIsState createState() => _TappableWhileStatusIsState();

}

class _TappableWhileStatusIsState extends State<_TappableWhileStatusIs> {
  bool _active;

  @override
  void initState() {
    super.initState();
    widget.controller.addStatusListener(_handleStatusChange);
    _active = widget.controller.status == widget.status;
  }

  @override
  void dispose() {
    widget.controller.removeStatusListener(_handleStatusChange);
    super.dispose();
  }

  void _handleStatusChange(AnimationStatus status) {
    final bool value = widget.controller.status == widget.status;
    if (_active != value) {
      setState(() {
        _active = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !_active,
      child: widget.child,
    );
  }
}

final Animatable<BorderRadius> _kFrontHeadingBevelRadius = BorderRadiusTween(
  begin: const BorderRadius.only(
    topLeft: Radius.circular(12.0),
    topRight: Radius.circular(12.0),
  ),
  end: const BorderRadius.only(
    topLeft: Radius.circular(_kFrontHeadingHeight),
    topRight: Radius.circular(_kFrontHeadingHeight),
  ),
);