import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, tap } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface User {
  id: string;
  email: string;
  role: 'Admin' | 'Cliente';
}

export interface AuthResponse {
  token: string;
  expiry: Date;
}

export interface RegisterPayload {
  email: string;
  password: string;
  cpf: string;
  address?: {
    street: string;
    number: string;
    neighborhood: string;
    zipCode: string;
    city: string;
    state: string;
  };
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);
  private readonly AUTH_TOKEN_KEY = 'agende_token';
  private readonly USER_KEY = 'agende_user';

  // Signals for reactive state
  public currentUser = signal<User | null>(this.getStoredUser());
  public isAuthenticated = signal<boolean>(!!this.getStoredToken());

  login(credentials: { email: string; password: string }): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${environment.apiUrl}/auth/login`, credentials).pipe(
      tap(res => {
        this.setAuthenticatedSession(res.token, credentials.email);
      })
    );
  }

  register(userData: RegisterPayload): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${environment.apiUrl}/auth/register`, userData).pipe(
      tap(res => {
        this.setAuthenticatedSession(res.token, userData.email);
      })
    );
  }

  logout(): void {
    localStorage.removeItem(this.AUTH_TOKEN_KEY);
    localStorage.removeItem(this.USER_KEY);
    this.currentUser.set(null);
    this.isAuthenticated.set(false);
    this.router.navigate(['/login']);
  }

  private setSession(token: string): void {
    localStorage.setItem(this.AUTH_TOKEN_KEY, token);
  }

  private setAuthenticatedSession(token: string, fallbackEmail: string): void {
    this.setSession(token);
    const user = this.decodeToken(token, fallbackEmail);
    this.currentUser.set(user);
    this.isAuthenticated.set(true);
  }

  private getStoredToken(): string | null {
    return localStorage.getItem(this.AUTH_TOKEN_KEY);
  }

  private getStoredUser(): User | null {
    const userJson = localStorage.getItem(this.USER_KEY);
    return userJson ? JSON.parse(userJson) : null;
  }

  private decodeToken(token: string, fallbackEmail = ''): User {
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      const id = payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] || payload.sub;
      const role = payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] || 'Cliente';
      const email = payload.email || fallbackEmail;

      const user: User = { id, email, role };
      localStorage.setItem(this.USER_KEY, JSON.stringify(user));
      return user;
    } catch (e) {
      console.error('Error decoding token', e);
      return { id: '', email: '', role: 'Cliente' };
    }
  }
}
