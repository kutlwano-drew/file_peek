import 'package:flutter/material.dart'; import 'package:flutter_markdown/flutter_markdown.dart';
class MarkdownPreview extends StatelessWidget{final String content;const MarkdownPreview({super.key,required this.content});@override Widget build(BuildContext c)=>Scrollbar(child:Markdown(data:content,padding:const EdgeInsets.all(24),selectable:true));}
