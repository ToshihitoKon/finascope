import { initializeApp } from 'firebase/app';
import { getAuth, GoogleAuthProvider, signInWithPopup, onAuthStateChanged, signOut } from 'firebase/auth';
import { toast } from 'svelte-sonner';

const firebaseConfig = {
  apiKey: 'AIzaSyBTzYRjcGVQ39dS-Y6lwliLZ8I7f0HbKjQ',
  authDomain: 'temama-finascope.firebaseapp.com',
  projectId: 'temama-finascope',
  storageBucket: 'temama-finascope.firebasestorage.app',
  messagingSenderId: '207396540319',
  appId: '1:207396540319:web:df270a6187c4aaecfdb7aa'
};

let app;
let firebaseAuth;

// Initialize
export const loggedInUserInformation = $state({
  jwt: '',
  isLoggedIn: false
});

export const revokeLogin = async () => {
  try {
    await signOut(getFirebaseAuth());
    // onAuthStateChanged will handle updating loggedInUserInformation
    toast.success('Logout Successful');
  } catch (error) {
    console.error('Error signing out: ', error);
    toast.error('Error signing out');
  }
};

const getApp = () => {
  if (!app) {
    app = initializeApp(firebaseConfig);
  }
  return app;
};
const getFirebaseAuth = () => {
  if (!firebaseAuth) {
    firebaseAuth = getAuth(getApp());
    firebaseAuth.languageCode = 'it';
    onAuthStateChanged(firebaseAuth, async (user) => {
      if (user) {
        loggedInUserInformation.jwt = await user.getIdToken();
        loggedInUserInformation.isLoggedIn = true;
      } else {
        loggedInUserInformation.jwt = '';
        loggedInUserInformation.isLoggedIn = false;
      }
    });
  }
  return firebaseAuth;
};

export const signInWithGoogle = async () => {
  let userCred;
  try {
    userCred = await signInWithPopup(getFirebaseAuth(), new GoogleAuthProvider());
    const name = userCred.user.displayName;

    // const jwt = await getUserJWT(); // This will be handled by onAuthStateChanged
    // loggedInUserInformation.jwt = jwt; // This will be handled by onAuthStateChanged
    // loggedInUserInformation.isLoggedIn = true; // This will be handled by onAuthStateChanged

    toast.success(`Login Successful. Welcome ${name}!`);
  } catch (error) {
    console.log('Error signing in with Google', error);
    toast.error('Error signing in with Google');
  }
};
