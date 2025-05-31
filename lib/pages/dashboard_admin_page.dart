import 'package:flutter/material.dart';
import '../models/Utilisateur.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  late Future<List<Utilisateur>> _utilisateursFuture;

  @override
  void initState() {
    super.initState();
    _utilisateursFuture = _loadUtilisateurs();
  }

  Future<List<Utilisateur>> _loadUtilisateurs() {
    return ApiService.fetchAllUsers();
  }

  Future<void> _refreshUtilisateurs() async {
    setState(() {
      _utilisateursFuture = _loadUtilisateurs();
    });
  }

  Widget _buildUserCard(BuildContext context, Utilisateur utilisateur) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            ApiService.getUserProfileImageUrl(utilisateur.photProfil),
          ),
          backgroundColor: Colors.grey[200],
        ),
        title: Text(
          '${utilisateur.prenom} ${utilisateur.nom}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(utilisateur.email),
            Text('Rôle: ${utilisateur.role.nom}'),
            Text('Date de naissance: ${DateFormat('dd/MM/yyyy').format(utilisateur.dateNaissance)}'),
            Text(
              'Statut: ${utilisateur.isActif ? 'Actif' : 'Bloqué'}',
              style: TextStyle(
                color: utilisateur.isActif ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                utilisateur.isActif ? Icons.block : Icons.check_circle_outline,
                color: AppColors.accentColor,
              ),
              onPressed: () async {
                try {
                  final action = utilisateur.isActif ? 'bloquer' : 'débloquer';
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmation'),
                      content: Text('Voulez-vous vraiment $action cet utilisateur ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            action[0].toUpperCase() + action.substring(1),
                            style: TextStyle(
                              color: utilisateur.isActif ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await ApiService.toggleUserStatus(utilisateur.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Utilisateur ${action} avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _refreshUtilisateurs();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard Admin',
          style: TextStyle(
            color: AppColors.neutralColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUtilisateurs,
        color: AppColors.primaryColor,
        child: FutureBuilder<List<Utilisateur>>(
          future: _utilisateursFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Aucun utilisateur disponible'),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) =>
                  _buildUserCard(context, snapshot.data![index]),
            );
          },
        ),
      ),
    );
  }
}