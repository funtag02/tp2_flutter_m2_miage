import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/service/article_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_2/model/article.dart';


class AddArticlePage extends StatefulWidget {
  const AddArticlePage({super.key});

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage>
    with SingleTickerProviderStateMixin {
  // ── État du formulaire ──────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _sizeController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();

  File? _imageFile;
  String? _imageBase64;           // ← stockage base64
  ArticleCategory? _category;     // ← enum à la place de String
  bool _detectionEnCours = false;
  bool _sauvegadeEnCours = false;

  // ── Animation d'entrée ─────────────────────────────────────────
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── Listes de référence ────────────────────────────────────────
  static const List<String> _tailles = [
    'XS', 'S', 'M', 'L', 'XL', 'XXL',
    '34', '36', '38', '40', '42', '44',
    '36 EU', '37 EU', '38 EU', '39 EU', '40 EU', '41 EU', '42 EU',
  ];

  // ── Thème couleurs ─────────────────────────────────────────────
  static const Color _white = Color.fromRGBO(255, 255, 255, 1);
  static const Color _deepPurple = Colors.deepPurple;
  static const Color _grey = Color(0xFF8E8E93);
  static const Color _bgColor = Color.fromRGBO(254, 247, 255, 1);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleController.dispose();
    _sizeController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ── Sélection image ────────────────────────────────────────────
  Future<void> _choisirImage(ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked == null) return;

    final file = File(picked.path);

    // Conversion en base64
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);

    setState(() {
      _imageFile = file;
      _imageBase64 = base64String;
      _category = null;
      _detectionEnCours = true;
    });

    final cat = await ArticleService.detecterCategorie(file);
    if (mounted) {
      setState(() {
        _category = cat;
        _detectionEnCours = false;
      });
    }
  }

  void _afficherChoixImage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: _white,
                  child:
                      Icon(Icons.camera_alt_rounded, color: _deepPurple),
                ),
                title: const Text('Prendre une photo',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => _choisirImage(ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: _white,
                  child: Icon(Icons.photo_library_rounded,
                      color: _deepPurple),
                ),
                title: const Text('Choisir depuis la galerie',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => _choisirImage(ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Validation & sauvegarde ────────────────────────────────────
  Future<void> _valider() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null || _imageBase64 == null) {
      _showSnack('Veuillez ajouter une photo.', isError: true);
      return;
    }
    if (_category == null) {
      _showSnack('La catégorie n\'a pas encore été détectée.',
          isError: true);
      return;
    }

    setState(() => _sauvegadeEnCours = true);

    try {
      final article = Article(
        imageBase64: _imageBase64!,          // ← base64
        title: _titleController.text.trim(), // ← title
        category: _category!,               // ← ArticleCategory enum
        size: _sizeController.text.trim(),   // ← size
        brand: _brandController.text.trim(), // ← brand
        price: double.parse(
            _priceController.text.replaceAll(',', '.')),  // ← price
      );

      await ArticleService.sauvegarder(article);

      if (mounted) {
        _showSnack('Vêtement ajouté avec succès ! 🎉');
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Erreur lors de la sauvegarde. Réessayez.',
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _sauvegadeEnCours = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : _deepPurple,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImagePicker(),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Informations générales',
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        label: 'Titre',
                        hint: 'Ex : Jean slim bleu Levi\'s',
                        icon: Icons.label_outline_rounded,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Titre requis'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildCategorieField(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Détails',
                    children: [
                      _buildTailleDropdown(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _brandController,
                        label: 'Marque',
                        hint: 'Ex : Levi\'s, Zara, H&M…',
                        icon: Icons.sell_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Marque requise'
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Prix',
                    children: [_buildPrixField()],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: _deepPurple),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Ajouter un vêtement',
        style: TextStyle(
          color: _deepPurple,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey.shade200),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _afficherChoixImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 220,
        decoration: BoxDecoration(
          color: _imageFile == null ? _white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _imageFile == null
                ? _deepPurple.withOpacity(0.4)
                : Colors.transparent,
            width: 2,
            style: _imageFile == null
                ? BorderStyle.solid
                : BorderStyle.none,
          ),
          image: _imageFile != null
              ? DecorationImage(
                  image: FileImage(_imageFile!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _imageFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _deepPurple.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_rounded,
                        color: _deepPurple, size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ajouter une photo',
                    style: TextStyle(
                      color: _deepPurple,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'La catégorie sera détectée automatiquement',
                    style: TextStyle(color: _grey, fontSize: 12),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: _afficherChoixImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Modifier',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style:
          const TextStyle(color: _deepPurple, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle:
            TextStyle(color: _grey.withOpacity(0.6), fontSize: 14),
        labelStyle: const TextStyle(color: _grey, fontSize: 14),
        prefixIcon: Icon(icon, color: _deepPurple, size: 20),
        suffix: suffix,
        filled: true,
        fillColor: _bgColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _deepPurple, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  // ── Catégorie — affiche le label de l'enum ─────────────────────
  Widget _buildCategorieField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.category_outlined, color: _deepPurple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Catégorie',
                    style: TextStyle(color: _grey, fontSize: 12)),
                const SizedBox(height: 2),
                if (_detectionEnCours)
                  Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _deepPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Détection en cours…',
                          style: TextStyle(color: _grey, fontSize: 14)),
                    ],
                  )
                else if (_category != null)
                  Text(
                    _category!.label, // ← .label de l'enum
                    style: const TextStyle(
                      color: _deepPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  )
                else
                  Text(
                    _imageFile == null
                        ? 'Ajoutez une image pour détecter la catégorie'
                        : '—',
                    style: TextStyle(
                      color: _grey.withOpacity(0.7),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          if (_category != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Auto',
                  style: TextStyle(
                      color: _deepPurple,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _buildTailleDropdown() {
    String? selectedTaille =
        _sizeController.text.isEmpty ? null : _sizeController.text;

    return DropdownButtonFormField<String>(
      value: selectedTaille,
      hint: const Text('Sélectionner une taille',
          style: TextStyle(color: Colors.grey, fontSize: 14)),
      style: const TextStyle(
          color: _deepPurple, fontWeight: FontWeight.w500, fontSize: 15),
      icon:
          const Icon(Icons.expand_more_rounded, color: _deepPurple),
      decoration: InputDecoration(
        labelText: 'Taille',
        labelStyle: const TextStyle(color: _grey, fontSize: 14),
        prefixIcon: const Icon(Icons.straighten_rounded,
            color: _deepPurple, size: 20),
        filled: true,
        fillColor: _bgColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _deepPurple, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      items: _tailles
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: (v) {
        if (v != null) _sizeController.text = v;
      },
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Taille requise' : null,
    );
  }

  Widget _buildPrixField() {
    return _buildTextField(
      controller: _priceController,
      label: 'Prix',
      hint: '0.00',
      icon: Icons.euro_rounded,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,2}')),
      ],
      suffix: const Text('€',
          style: TextStyle(
              color: _deepPurple,
              fontWeight: FontWeight.w600,
              fontSize: 16)),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Prix requis';
        final parsed = double.tryParse(v.replaceAll(',', '.'));
        if (parsed == null || parsed <= 0) return 'Prix invalide';
        return null;
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _sauvegadeEnCours ? null : _valider,
        style: ElevatedButton.styleFrom(
          backgroundColor: _deepPurple,
          disabledBackgroundColor: _deepPurple.withOpacity(0.5),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _sauvegadeEnCours
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Text(
                'Valider',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}