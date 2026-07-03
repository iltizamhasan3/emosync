import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> plan;

  const PaymentScreen({super.key, required this.plan});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiService _apiService = ApiService();
  
  String _selectedPaymentMethod = 'bca';
  String? _transactionId;
  bool _isProcessing = false;
  bool _isPolling = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'bca',
      'name': 'BCA Virtual Account',
      'icon': Icons.account_balance,
      'iconColor': const Color(0xFF6D5B56),
    },
    {
      'id': 'mandiri',
      'name': 'Mandiri Virtual Account',
      'icon': Icons.account_balance,
      'iconColor': const Color(0xFF6D5B56),
    },
    {
      'id': 'bni',
      'name': 'BNI Virtual Account',
      'icon': Icons.account_balance,
      'iconColor': const Color(0xFF6D5B56),
    },
  ];

  // ============ CREATE TRANSACTION ============
  Future<void> _createTransaction() async {
    setState(() {
      _isProcessing = true;
    });

    final result = await _apiService.createTransaction(
      plan: widget.plan['id'],
      paymentMethod: _selectedPaymentMethod,
    );

    if (result['success'] && mounted) {
      final data = result['data'];
      setState(() {
        _transactionId = data['transaction_id'];
        _isProcessing = false;
      });
      
      _showPaymentInstruction(data);
      _startPolling();
      
    } else if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal membuat transaksi'),
          backgroundColor: const Color(0xFFA83836),
        ),
      );
    }
  }

  // ============ SHOW PAYMENT INSTRUCTION ============
  void _showPaymentInstruction(Map<String, dynamic> data) {
    final instruction = data['instruction'];
    final steps = instruction['steps'] as List;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.payment,
                          color: Color(0xFFFF8A65),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          instruction['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3E2F2B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // ============ VIRTUAL ACCOUNT - CENTER ============
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Nomor Virtual Account',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6D5B56),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ============ CENTER ============
                        Center(
                          child: SelectableText(
                            data['virtual_account'] ?? '888123456789',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFF8A65),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Total: ${data['amount_formatted']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF3E2F2B),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Berlaku hingga: ${_formatDate(data['expires_at'])}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFA83836),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Steps
                  const Text(
                    'CARA PEMBAYARAN:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6D5B56),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...steps.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$index',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF8A65),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF3E2F2B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 20),
                  
                  // ============ ACTION BUTTONS ============
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _cancelTransaction();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFA83836)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Batalkan',
                            style: TextStyle(color: Color(0xFFA83836)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _simulatePayment();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Bayar Sekarang'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // ============ HAPUS TULISAN DEMO ============
                  const Text(
                    '⚠️ Klik "Bayar Sekarang" untuk menyelesaikan pembayaran.',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6D5B56),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============ POLLING STATUS ============
  void _startPolling() {
    if (_transactionId == null) return;
    
    setState(() {
      _isPolling = true;
    });

    int attempts = 0;
    const maxAttempts = 30;

    Future.delayed(const Duration(seconds: 3), () {
      _pollStatus(attempts, maxAttempts);
    });
  }

  Future<void> _pollStatus(int attempts, int maxAttempts) async {
    if (!mounted || _transactionId == null) return;

    if (attempts >= maxAttempts) {
      setState(() {
        _isPolling = false;
      });
      
      final result = await _apiService.checkTransactionStatus(_transactionId!);
      if (result['success'] && result['data']['status'] == 'pending') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi expired. Silakan coba lagi.'),
            backgroundColor: Color(0xFFA83836),
          ),
        );
      }
      return;
    }

    final result = await _apiService.checkTransactionStatus(_transactionId!);
    
    if (result['success']) {
      final status = result['data']['status'];
      
      if (status == 'success') {
        setState(() {
          _isPolling = false;
        });
        
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.refreshUser();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pembayaran berhasil! Anda sekarang premium!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        }
        return;
      } else if (status == 'failed') {
        setState(() {
          _isPolling = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi gagal. Silakan coba lagi.'),
            backgroundColor: Color(0xFFA83836),
          ),
        );
        return;
      }
    }

    attempts++;
    Future.delayed(const Duration(seconds: 3), () {
      _pollStatus(attempts, maxAttempts);
    });
  }

  // ============ SIMULATE PAYMENT ============
  Future<void> _simulatePayment() async {
    if (_transactionId == null) return;

    setState(() {
      _isProcessing = true;
    });

    final result = await _apiService.simulatePayment(_transactionId!);

    setState(() {
      _isProcessing = false;
    });

    if (result['success'] && mounted) {
      setState(() {
        _isPolling = false;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshUser();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil! Anda sekarang premium!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
      
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal memproses pembayaran'),
          backgroundColor: const Color(0xFFA83836),
        ),
      );
    }
  }

  // ============ CANCEL TRANSACTION ============
  Future<void> _cancelTransaction() async {
    if (_transactionId == null) return;

    setState(() {
      _isProcessing = true;
    });

    final result = await _apiService.cancelTransaction(_transactionId!);

    setState(() {
      _isProcessing = false;
    });

    if (result['success'] && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi dibatalkan'),
          backgroundColor: Color(0xFFFF8A65),
        ),
      );
      Navigator.pop(context);
    }
  }

  // ============ HELPERS ============
  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.plan['priceFormatted'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildOrderSummary(),
                      const SizedBox(height: 32),
                      _buildPaymentMethods(),
                      const SizedBox(height: 24),
                      _buildSecurityNote(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(price),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFC3ADA7).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _isProcessing ? null : () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: Color(0xFF3E2F2B),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Payment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3E2F2B),
              ),
            ),
          ),
          const Text(
            'EmoSync+',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFF8A65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RINGKASAN PESANAN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Color(0xFF6D5B56),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.plan['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E2F2B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.plan['id'] == 'yearly' ? 'Berlaku selama 1 tahun' : 'Berlaku selama 30 hari',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6D5B56),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.plan['priceFormatted'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF8A65),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.plan['period'],
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6D5B56),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'METODE PEMBAYARAN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Color(0xFF6D5B56),
          ),
        ),
        const SizedBox(height: 12),
        ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)),
      ],
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['id'];
    final iconColor = method['iconColor'];

    return GestureDetector(
      onTap: _isProcessing ? null : () {
        setState(() {
          _selectedPaymentMethod = method['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F5F5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF8A65).withValues(alpha: 0.4)
                : const Color(0xFFC3ADA7).withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                method['icon'],
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                method['name'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3E2F2B),
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF8A65)
                      : const Color(0xFFC3ADA7),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF8A65),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8A65).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield,
            size: 20,
            color: Color(0xFFFF8A65),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pembayaran Anda aman dan terenkripsi. Dengan melanjutkan, Anda menyetujui Ketentuan Layanan EmoSync+.',
              style: TextStyle(
                fontSize: 10,
                height: 1.4,
                color: const Color(0xFF6D5B56),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(String price) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFC3ADA7).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6D5B56),
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFF8A65),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_isProcessing || _isPolling) ? null : _createTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A65),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing || _isPolling
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Bayar Sekarang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}