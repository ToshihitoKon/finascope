import { initializeApp } from 'firebase/app';
import {
  getAuth,
  GoogleAuthProvider,
  signInWithPopup,
  signOut,
  setPersistence,
  onAuthStateChanged
} from 'firebase/auth';
import { toast } from 'svelte-sonner';
import { Mutex } from 'async-mutex';

const firebaseConfig = {
  apiKey: 'AIzaSyBTzYRjcGVQ39dS-Y6lwliLZ8I7f0HbKjQ',
  authDomain: 'temama-finascope.firebaseapp.com',
  projectId: 'temama-finascope',
  storageBucket: 'temama-finascope.firebasestorage.app',
  messagingSenderId: '207396540319',
  appId: '1:207396540319:web:df270a6187c4aaecfdb7aa'
};

const authMutex = new Mutex();

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
auth.languageCode = 'it';
setPersistence(auth, 'local');

export const signInWithGoogle = async () => {
  await authMutex.runExclusive(async () => {
    try {
      const userCred = await signInWithPopup(auth, new GoogleAuthProvider());
      toast.success(`Login Successful. Welcome ${userCred.user.displayName}!`);
    } catch (error) {
      toast.error('Error signing in with Google: ' + error.message);
      console.error(error);
    }
  });
};

export const logout = async () => {
  await authMutex.runExclusive(async () => {
    signOut(auth);
    toast.success('Logout Successful');
  });
};

// getFirebaseAuth
// if return empty string, user is not logged in
export const getFirebaseToken = async (): string => {
  return await authMutex.runExclusive(async () => {
    if (!user.user) {
      return '';
    }
    return await user.user.getIdToken();
  });
};

export const user = $state({ user: null, isLoggedIn: false });
onAuthStateChanged(auth, (currentUser) => {
  user.user = currentUser;
  user.isLoggedIn = !!currentUser;
});
