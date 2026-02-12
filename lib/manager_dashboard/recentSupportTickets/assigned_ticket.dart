import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart'; // Use the centralized API service
import 'ticket_details.dart';

// Model for an assigned ticket based on the UI and API speculation
class AssignedTicket {
  final int id;
  final String issueBy;
  final String title;
  final String priority;
  String status; // mutable for dropdown
  final String category;
  final DateTime createdAt;

  AssignedTicket({
    required this.id,
    required this.issueBy,
    required this.title,
    required this.priority,
    required this.status,
    required this.category,
    required this.createdAt,
  });

  factory AssignedTicket.fromJson(Map<String, dynamic> json) {
    // This factory is designed to be highly robust against unexpected API data types.
    // It safely parses all fields, providing default values to prevent crashes.
    return AssignedTicket(
      // Safely parse ID, converting from String if necessary.
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,

      // Safely get the 'issueBy' name from a potentially nested object.
      issueBy: (json['user_detail'] is Map
              ? json['user_detail']['name']?.toString()
              : null) ??
          'N/A',

      title: json['title']?.toString() ?? 'No Title',
      priority: json['priority']?.toString() ?? 'low',
      status: json['status']?.toString() ?? 'open',

      // Safely get the 'category' name from a potentially nested object.
      category: (json['category'] is Map
              ? json['category']['name']?.toString()
              : null) ??
          'General',

      // Safely parse the date, with a fallback to the current time.
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class AssignedTicketsScreen extends StatefulWidget {
  const AssignedTicketsScreen({super.key});

  @override
  AssignedTicketsScreenState createState() => AssignedTicketsScreenState();
}

class AssignedTicketsScreenState extends State<AssignedTicketsScreen> {
  late Future<List<AssignedTicket>> _ticketsFuture;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _fetchAssignedTickets();
    _searchController.addListener(() {
      setState(() {}); // Rebuild the widget to apply the filter
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshTickets() async {
    setState(() {
      // Clear search and re-fetch tickets
      _searchController.clear();
      _ticketsFuture = _fetchAssignedTickets();
    });
  }

  Future<List<AssignedTicket>> _fetchAssignedTickets() async {
    try {
      final response = await ApiService.get('manager/assigned-tickets');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          final List<dynamic> ticketsJson = responseData['data'];
          // The FutureBuilder will use this returned list
          return ticketsJson.map((json) => AssignedTicket.fromJson(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load tickets: API status false');
        }
      } else {
        throw Exception('Failed to load tickets: Server error ${response.statusCode}');
      }
    } catch (e) {
      // The ApiService handles connection errors, so we just rethrow its message.
      throw Exception('Failed to fetch tickets: $e');
    }
  }

  Future<void> _updateTicketStatus(AssignedTicket ticket, String newStatus) async {
    try {
      final response = await ApiService.post(
        'manager/tickets/${ticket.id}/status',
        {'status': newStatus},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          setState(() {
            ticket.status = newStatus;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ticket #${ticket.id} status updated to $newStatus')),
          );
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update status');
        }
      } else {
        throw Exception('Failed to update status: Server error ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Tickets'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: FutureBuilder<List<AssignedTicket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
            ));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No assigned tickets found.'));
          } else {
            final allTickets = snapshot.data!;
            final searchQuery = _searchController.text.toLowerCase();
            
            final filteredTickets = allTickets.where((ticket) {
              return ticket.title.toLowerCase().contains(searchQuery) ||
                     ticket.issueBy.toLowerCase().contains(searchQuery) ||
                     ticket.id.toString().contains(searchQuery);
            }).toList();

            return RefreshIndicator(
              onRefresh: _refreshTickets,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by ID, Title, or Issue By',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('#ID')),
                          DataColumn(label: Text('ISSUE BY')),
                          DataColumn(label: Text('TITLE')),
                          DataColumn(label: Text('PRIORITY')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('CATEGORY')),
                          DataColumn(label: Text('CREATED AT')),
                          DataColumn(label: Text('ACTION')),
                        ],
                        // Use the filtered list to build the rows
                        rows: filteredTickets.map((ticket) => _buildDataRow(ticket)).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  DataRow _buildDataRow(AssignedTicket ticket) {
    return DataRow(cells: [
      DataCell(Text(ticket.id.toString())),
      DataCell(Text(ticket.issueBy)),
      DataCell(Text(ticket.title, overflow: TextOverflow.ellipsis)),
      DataCell(_buildPriorityChip(ticket.priority)),
      DataCell(_buildStatusDropdown(ticket)),
      DataCell(Text(ticket.category)),
      DataCell(Text(DateFormat('dd MMM, yyyy').format(ticket.createdAt))),
      DataCell(
        ElevatedButton(
          child: const Text('VIEW / REPLY'),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => TicketDetailsPage(ticketId: ticket.id.toString())));
          },
        ),
      ),
    ]);
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    String label = priority.isNotEmpty ? priority[0].toUpperCase() + priority.substring(1) : '';
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'low':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    );
  }
  
  Widget _buildStatusDropdown(AssignedTicket ticket) {
    const statusOptions = ['open', 'in_progress', 'resolved', 'closed'];

    return DropdownButton<String>(
      value: ticket.status,
      items: statusOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.replaceAll('_', ' ').split(' ').map((l) => l[0].toUpperCase() + l.substring(1)).join(' ')),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null && newValue != ticket.status) {
           _updateTicketStatus(ticket, newValue);
        }
      },
    );
  }
}
