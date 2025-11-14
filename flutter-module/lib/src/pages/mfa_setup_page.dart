import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../services/mfa_service.dart';
import '../services/secure_storage_service.dart';
import '../services/audit_log_service.dart';

/// MFA Setup Page for configuring Two-Factor Authentication
///
/// Features:
/// - QR code generation for authenticator apps
/// - Manual secret key entry option
/// - TOTP verification
/// - Recovery codes display and download
/// - Step-by-step setup wizard
class MFASetupPage extends StatefulWidget {
  final String userId;
  final String username;
  final String userRole;

  const MFASetupPage({
    super.key,
    required this.userId,
    required this.username,
    required this.userRole,
  });

  @override
  State<MFASetupPage> createState() => _MFASetupPageState();
}

class _MFASetupPageState extends State<MFASetupPage> {
  late final MFAService _mfaService;
  MFASetupData? _setupData;
  int _currentStep = 0;
  bool _isLoading = false;
  String _verificationCode = '';
  bool _verificationError = false;
  bool _setupComplete = false;

  @override
  void initState() {
    super.initState();
    _initMFAService();
    _setupMFA();
  }

  void _initMFAService() {
    _mfaService = MFAService(
      secureStorage: SecureStorageService(),
      auditLogService: null, // Will be injected in production
    );
  }

  Future<void> _setupMFA() async {
    setState(() => _isLoading = true);

    try {
      final setupData = await _mfaService.setupMFA(
        userId: widget.userId,
        username: widget.username,
      );

      setState(() {
        _setupData = setupData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to setup MFA: $e');
    }
  }

  Future<void> _verifyAndEnable() async {
    if (_verificationCode.length != 6) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _mfaService.enableMFA(
        userId: widget.userId,
        username: widget.username,
        verificationCode: _verificationCode,
      );

      setState(() {
        _isLoading = false;
        if (success) {
          _setupComplete = true;
          _currentStep = 2;
          _verificationError = false;
        } else {
          _verificationError = true;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _verificationError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Two-Factor Authentication'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildStepper(),
    );
  }

  Widget _buildStepper() {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: _onStepContinue,
      onStepCancel: _onStepCancel,
      controlsBuilder: _buildStepControls,
      steps: [
        Step(
          title: const Text('Scan QR Code'),
          content: _buildQRCodeStep(),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Verify Setup'),
          content: _buildVerificationStep(),
          isActive: _currentStep >= 1,
          state: _setupComplete
              ? StepState.complete
              : _currentStep > 1
                  ? StepState.complete
                  : StepState.indexed,
        ),
        Step(
          title: const Text('Save Recovery Codes'),
          content: _buildRecoveryCodesStep(),
          isActive: _currentStep >= 2,
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        ),
      ],
    );
  }

  Widget _buildQRCodeStep() {
    if (_setupData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scan this QR code with your authenticator app:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Compatible apps: Google Authenticator, Authy, Microsoft Authenticator',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: _setupData!.qrCodeData,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ExpansionTile(
          title: const Text('Can\'t scan QR code?'),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter this secret key manually in your authenticator app:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _setupData!.secret,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _setupData!.secret),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Secret key copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          tooltip: 'Copy secret key',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter the 6-digit code from your authenticator app:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        PinCodeTextField(
          appContext: context,
          length: 6,
          obscureText: false,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(8),
            fieldHeight: 50,
            fieldWidth: 40,
            activeFillColor: Colors.white,
            inactiveFillColor: Colors.white,
            selectedFillColor: Colors.white,
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: _verificationError ? Colors.red : Colors.grey,
            selectedColor: Theme.of(context).primaryColor,
            errorBorderColor: Colors.red,
          ),
          animationDuration: const Duration(milliseconds: 300),
          backgroundColor: Colors.transparent,
          enableActiveFill: true,
          keyboardType: TextInputType.number,
          onCompleted: (value) {
            setState(() {
              _verificationCode = value;
            });
            _verifyAndEnable();
          },
          onChanged: (value) {
            setState(() {
              _verificationCode = value;
              _verificationError = false;
            });
          },
        ),
        if (_verificationError)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Invalid code. Please try again.',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        const SizedBox(height: 16),
        const Text(
          'The code refreshes every 30 seconds.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRecoveryCodesStep() {
    if (_setupData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Save these recovery codes in a safe place!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'If you lose access to your authenticator app, you can use these codes to access your account. Each code can only be used once.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              ...(_setupData!.recoveryCodes.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${entry.key + 1}.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SelectableText(
                        entry.value,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              })),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _copyRecoveryCodes,
              icon: const Icon(Icons.copy),
              label: const Text('Copy All'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _downloadRecoveryCodes,
              icon: const Icon(Icons.download),
              label: const Text('Download'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepControls(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          if (_currentStep < 2)
            ElevatedButton(
              onPressed: details.onStepContinue,
              child: const Text('Continue'),
            ),
          if (_currentStep == 2)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return success
              },
              child: const Text('Finish'),
            ),
          const SizedBox(width: 8),
          if (_currentStep > 0 && _currentStep < 2)
            TextButton(
              onPressed: details.onStepCancel,
              child: const Text('Back'),
            ),
        ],
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1 && _setupComplete) {
      setState(() => _currentStep = 2);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _copyRecoveryCodes() {
    final codes = _setupData!.recoveryCodes.join('\n');
    Clipboard.setData(ClipboardData(text: codes));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recovery codes copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _downloadRecoveryCodes() {
    // In a real app, this would trigger a file download
    // For now, we'll just copy to clipboard
    _copyRecoveryCodes();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download feature coming soon. Codes copied to clipboard.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
