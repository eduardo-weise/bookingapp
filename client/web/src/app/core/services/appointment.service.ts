import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Appointment } from '../../shared/components/appointment-card/appointment-card.component';

@Injectable({
  providedIn: 'root'
})
export class AppointmentService {
  private http = inject(HttpClient);

  getHistory(): Observable<Appointment[]> {
    return this.http.get<Appointment[]>(`${environment.apiUrl}/scheduling/history`);
  }

  getAvailableSlots(date: string): Observable<string[]> {
    return this.http.get<string[]>(`${environment.apiUrl}/scheduling/available-slots?date=${date}`);
  }

  book(appointmentData: any): Observable<any> {
    return this.http.post(`${environment.apiUrl}/scheduling/book`, appointmentData);
  }

  cancel(id: string): Observable<any> {
    return this.http.delete(`${environment.apiUrl}/scheduling/cancel?id=${id}`);
  }
}
