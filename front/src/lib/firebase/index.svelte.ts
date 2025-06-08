import { initializeApp } from 'firebase/app';
import {
  getAuth,
  GoogleAuthProvider,
  signInWithPopup,
  signOut,
  setPersistence,
  onAuthStateChanged,
  browserLocalPersistence
} from 'firebase/auth';
import { toast } from 'svelte-sonner';
import { Mutex } from 'async-mutex';
import { writable } from 'svelte/store';

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
setPersistence(auth, browserLocalPersistence);

export const loginEventBus = writable<string>('');
let unsubscrib = null;
if (!unsubscrib) {
  unsubscrib = onAuthStateChanged(auth, (user) => {
    if (user) {
      loginEventBus.set(user.displayName || '');
    } else {
      loginEventBus.set('');
    }
  });
}

export const signInWithGoogle = async () => {
  await authMutex.runExclusive(async () => {
    try {
      const userCred = await signInWithPopup(auth, new GoogleAuthProvider());
      toast.success(`Login Successful. Welcome ${userCred.user.displayName}!`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      toast.error('Error signing in with Google: ' + errorMessage);
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
export const getFirebaseToken = async (): Promise<string> => {
  return await authMutex.runExclusive(async () => {
    if (!auth.currentUser) {
      return '';
    }
    return await auth.currentUser.getIdToken();
  });
};
