import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ GETTERS
  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => _auth.currentUser != null;
  static String? get userId => _auth.currentUser?.uid;

  // ✅ REGISTRO CON EMAIL
  static Future<User?> signUpWithEmail(String email, String password, String name) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🆕 Crear documento de usuario en Firestore
      await _createUserDocument(userCredential.user!, name, email);

      return userCredential.user;
    } catch (e) {
      print('❌ Error en registro: $e');
      throw _handleAuthError(e);
    }
  }

  // ✅ LOGIN CON EMAIL
  static Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('❌ Error en login: $e');
      throw _handleAuthError(e);
    }
  }

  // ✅ LOGIN CON GOOGLE
  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // 🆕 Crear documento de usuario si es nuevo
      if (userCredential.additionalUserInfo!.isNewUser) {
        await _createUserDocument(
          userCredential.user!, 
          googleUser.displayName ?? 'Usuario', 
          googleUser.email
        );
      }

      return userCredential.user;
    } catch (e) {
      print('❌ Error en Google Sign-In: $e');
      throw _handleAuthError(e);
    }
  }

  // ✅ CERRAR SESIÓN
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
      throw Exception('Error al cerrar sesión');
    }
  }

  // ✅ RESTABLECER CONTRASEÑA
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('❌ Error restableciendo password: $e');
      throw _handleAuthError(e);
    }
  }

  // 🆕 CREAR DOCUMENTO DE USUARIO EN FIRESTORE
  static Future<void> _createUserDocument(User user, String name, String? email) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'premium': false,
        'premiumSince': null,
        'analysisCount': 0,
        'goal': 'fitness', // Por defecto
      });
    } catch (e) {
      print('❌ Error creando documento usuario: $e');
    }
  }

  // 🆕 MANEJO DE ERRORES EN ESPAÑOL
  static String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No existe una cuenta con este email';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'email-already-in-use':
          return 'Este email ya está registrado';
        case 'invalid-email':
          return 'Email no válido';
        case 'weak-password':
          return 'La contraseña es demasiado débil';
        case 'network-request-failed':
          return 'Error de conexión. Verifica tu internet';
        default:
          return 'Error de autenticación: ${error.code}';
      }
    }
    return 'Error inesperado. Intenta nuevamente';
  }

  // 🆕 OBTENER DATOS DEL USUARIO
  static Future<Map<String, dynamic>?> getUserData() async {
    if (userId == null) return null;
    
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('❌ Error obteniendo datos usuario: $e');
      return null;
    }
  }

  // 🆕 ACTUALIZAR DATOS DEL USUARIO
  static Future<void> updateUserData(Map<String, dynamic> data) async {
    if (userId == null) return;
    
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('❌ Error actualizando datos usuario: $e');
    }
  }

  // 🆕 ELIMINAR CUENTA
  static Future<void> deleteAccount() async {
    if (currentUser == null) return;
    
    try {
      // 1. Eliminar datos de Firestore
      await _firestore.collection('users').doc(userId).delete();
      
      // 2. Eliminar cuenta de autenticación
      await currentUser!.delete();
      
      // 3. Cerrar sesión
      await signOut();
    } catch (e) {
      print('❌ Error eliminando cuenta: $e');
      throw Exception('Error al eliminar la cuenta');
    }
  }
}