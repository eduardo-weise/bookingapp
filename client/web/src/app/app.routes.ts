import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { LoginPageComponent } from './features/auth/login/login-page.component';
import { HomePageComponent } from './features/home/home-page.component';

export const routes: Routes = [
	{ path: '', redirectTo: 'home', pathMatch: 'full' },
	{ path: 'login', component: LoginPageComponent },
	{ path: 'home', component: HomePageComponent, canActivate: [authGuard] },
	{ path: '**', redirectTo: 'home', pathMatch: 'full' },
];
