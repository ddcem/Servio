import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../../widgets/form_dialog.dart';
import 'reference_forms.dart';

/// Add or edit a menu item, including its image and tags. Returns true when saved.
Future<bool?> showMenuItemForm(BuildContext context, {MenuItem? item}) => showDialog<bool>(
  context: context,
  builder: (_) => _MenuItemForm(item: item),
);

class _MenuItemForm extends StatefulWidget {
  const _MenuItemForm({this.item});

  final MenuItem? item;

  @override
  State<_MenuItemForm> createState() => _MenuItemFormState();
}

class _MenuItemFormState extends State<_MenuItemForm> {
  static final _imageTypes = XTypeGroup(label: l10n.images, extensions: ['jpg', 'jpeg', 'png', 'webp']);
  static const _maxImageBytes = 2 * 1024 * 1024;

  final _formKey = GlobalKey<FormState>();
  final _server = ServerErrors();
  late final _name = TextEditingController(text: widget.item?.name);
  late final _description = TextEditingController(text: widget.item?.description);
  late final _price = TextEditingController(text: widget.item == null ? null : Formatters.decimal(widget.item!.price, digits: 2));
  late int? _categoryId = widget.item?.categoryId;
  late bool _available = widget.item?.isAvailableToday ?? true;
  late final Set<int> _tagIds = {...?widget.item?.tags.map((t) => t.id)};

  List<MenuCategory> _categories = [];
  List<ItemTag> _tags = [];
  Uint8List? _newImage;
  String? _newImageName;
  String? _imageError;
  late bool _removeImage = false;

  bool get _editing => widget.item != null;
  bool get _hasImage => _newImage != null || (widget.item?.hasImage == true && !_removeImage);

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  Future<void> _loadReferenceData() async {
    final results = await Future.wait([context.read<MenuCategoryProvider>().getAll(), context.read<ItemTagProvider>().getAll()]);
    if (!mounted) return;
    setState(() {
      _categories = results[0] as List<MenuCategory>;
      _tags = results[1] as List<ItemTag>;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await openFile(acceptedTypeGroups: [_imageTypes]);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      if (bytes.length > _maxImageBytes) {
        _imageError = l10n.imageTooLarge;
        return;
      }
      _imageError = null;
      _newImage = bytes;
      _newImageName = file.name;
      _removeImage = false;
    });
  }

  Future<void> _addCategory() async {
    final category = await showCategoryForm(context);
    if (category == null) return;
    await _loadReferenceData();
    setState(() => _categoryId = category.id);
  }

  Future<void> _addTag() async {
    final tag = await showNameForm<ItemTag>(
      context,
      provider: context.read<ItemTagProvider>(),
      entityLabel: l10n.entityTag,
      hint: l10n.tagHint,
    );
    if (tag == null) return;
    await _loadReferenceData();
    setState(() => _tagIds.add(tag.id));
  }

  Future<void> _save() async {
    final provider = context.read<MenuItemProvider>();
    final request = {
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'price': Validators.parseDecimal(_price.text),
      'categoryId': _categoryId,
      'isAvailableToday': _available,
      'tagIds': _tagIds.toList(),
    };

    final saved = _editing ? await provider.update(widget.item!.id, request) : await provider.insert(request);

    // The item is saved first; an image problem is reported without losing the other changes.
    try {
      if (_newImage != null) {
        await provider.uploadImage(saved.id, _newImage!, _newImageName!);
      } else if (_removeImage) {
        await provider.deleteImage(saved.id);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      Navigator.pop(context, true);
      showError(context, ApiException(l10n.savedButImageFailed(saved.name, e.message)));
      return;
    }

    if (!mounted) return;
    Navigator.pop(context, true);
    showSuccess(context, _editing ? l10n.itemUpdated(saved.name) : l10n.itemAddedToMenu(saved.name));
  }

  @override
  Widget build(BuildContext _) {
    final api = context.read<ApiClient>();
    final menuItems = context.read<MenuItemProvider>();

    return FormDialog(
      title: _editing ? l10n.editMenuItem : l10n.addMenuItem,
      formKey: _formKey,
      serverErrors: _server,
      width: 640,
      onSave: _save,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: ServioColors.surfaceMuted, borderRadius: BorderRadius.circular(14)),
                  child: _newImage != null
                      ? Image.memory(_newImage!, fit: BoxFit.contain)
                      : AuthImage(
                          url: _editing ? menuItems.imageUrl(widget.item!.id) : '',
                          headers: api.authHeaders,
                          hasImage: _hasImage,
                          size: 100,
                        ),
                ),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload),
                  label: Text(_hasImage ? l10n.changeImage : l10n.addImage),
                ),
                if (_hasImage)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: ServioColors.danger),
                    onPressed: () => setState(() {
                      _newImage = null;
                      _removeImage = true;
                    }),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.remove),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    autofocus: true,
                    maxLength: 100,
                    decoration: InputDecoration(labelText: l10n.name, hintText: l10n.nameHintDish),
                    validator: (value) => _server['Name'] ?? Validators.length(value, l10n.name, min: 2, max: 100),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _price,
                    decoration: InputDecoration(
                      labelText: l10n.price,
                      hintText: Formatters.language == 'bs' ? 'npr. 12,50' : 'e.g. 12.50',
                    ),
                    validator: (value) => _server['Price'] ?? Validators.decimal(value, l10n.price, min: 0.01, max: 10000),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_imageError != null) Text(_imageError!, style: const TextStyle(color: ServioColors.danger)),
        TextFormField(
          controller: _description,
          maxLines: 2,
          maxLength: 500,
          decoration: InputDecoration(labelText: l10n.descriptionOptional, hintText: l10n.descriptionHint),
          validator: (value) => _server['Description'] ?? Validators.length(value, l10n.description, max: 500, isRequired: false),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                key: ValueKey(_categories.length),
                initialValue: _categoryId,
                decoration: InputDecoration(labelText: l10n.category),
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(l10n.categoryWithStation(c.name, Stations.label(c.preparationStationName).toLowerCase())),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _categoryId = value),
                validator: (value) => _server['CategoryId'] ?? (value == null ? l10n.categoryRequired : null),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: IconButton.filledTonal(tooltip: l10n.addNewCategory, onPressed: _addCategory, icon: const Icon(Icons.add)),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l10n.tags, style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(onPressed: _addTag, icon: const Icon(Icons.add, size: 18), label: Text(l10n.newTag)),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in _tags)
                  FilterChip(
                    label: Text(tag.name),
                    selected: _tagIds.contains(tag.id),
                    onSelected: (selected) => setState(() => selected ? _tagIds.add(tag.id) : _tagIds.remove(tag.id)),
                  ),
              ],
            ),
            if (_server['TagIds'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_server['TagIds']!, style: const TextStyle(color: ServioColors.danger, fontSize: 12)),
              ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.availableToday),
          subtitle: Text(l10n.unavailableHidden),
          value: _available,
          onChanged: (value) => setState(() => _available = value),
        ),
      ],
    );
  }
}
