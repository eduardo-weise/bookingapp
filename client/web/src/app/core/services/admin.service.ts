import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface ServiceItem {
  id: string;
  name: string;
  price: number;
  duration: number;
}

export interface UserBalance {
  userId: string;
  userEmail: string;
  balance: number;
}

@Injectable({
  providedIn: 'root'
})
export class AdminService {
  private http = inject(HttpClient);

  getBalances(): Observable<UserBalance[]> {
    return this.http.get<UserBalance[]>(`${environment.apiUrl}/balances`);
  }

  payBalance(userId: string): Observable<any> {
    return this.http.post(`${environment.apiUrl}/balances/${userId}/pay`, {});
  }

  getServices(): Observable<ServiceItem[]> {
    return this.http.get<ServiceItem[]>(`${environment.apiUrl}/services`);
  }

  // Add more methods for CRUD services if needed based on /server/Features/Services
}
