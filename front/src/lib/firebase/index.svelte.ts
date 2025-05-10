import { initializeApp } from 'firebase/app';
import { getAuth, GoogleAuthProvider, signInWithPopup } from 'firebase/auth';
import { toast } from 'svelte-sonner';
import { get } from 'svelte/store';
import { persisted } from 'svelte-persisted-store';

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
const USER_JWT_KEY = 'fs-firebase-jwt';

// Initialize
const userJWT = persisted(USER_JWT_KEY, '');
export const loggedInUserInformation = $state({
  jwt: get(userJWT),
  isLoggedIn: get(userJWT) !== ''
});

export const revokeLogin = () => {
  userJWT.set('');
  loggedInUserInformation.jwt = '';
  loggedInUserInformation.isLoggedIn = false;

  toast.success('Logout Successful');
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
  }
  return firebaseAuth;
};

const getUserJWT = async (): string => {
  try {
    const user = await getFirebaseAuth().currentUser;
    if (!user) {
      return '';
    }
    return user.getIdToken();
  } catch (error) {
    throw new Error('Error getting user JWT: ' + error);
  }
};

export const signInWithGoogle = async () => {
  let userCred;
  try {
    userCred = await signInWithPopup(getFirebaseAuth(), new GoogleAuthProvider());
    const name = userCred.user.displayName;

    const jwt = await getUserJWT();
    userJWT.set(jwt);
    loggedInUserInformation.jwt = jwt;
    loggedInUserInformation.isLoggedIn = true;

    toast.success(`Login Successful. Welcome ${name}!`);
  } catch (error) {
    console.log('Error signing in with Google', error);
    toast.error('Error signing in with Google');
  }
};
