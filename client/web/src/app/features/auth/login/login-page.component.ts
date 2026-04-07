import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { finalize } from 'rxjs';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-login-page',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './login-page.component.html',
  styleUrl: './login-page.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class LoginPageComponent {
  private readonly formBuilder = inject(FormBuilder);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);

  protected readonly mode = signal<'login' | 'register'>('login');
  protected readonly isSubmitting = signal(false);
  protected readonly authError = signal('');
  protected readonly authForm = this.formBuilder.nonNullable.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]],
    rememberMe: [true]
  });

  protected setMode(mode: 'login' | 'register'): void {
    if (this.mode() === mode) {
      return;
    }

    this.mode.set(mode);
    this.authError.set('');
    this.authForm.markAsPristine();
    this.authForm.markAsUntouched();
  }

  protected submitAuth(): void {
    if (this.authForm.invalid) {
      this.authForm.markAllAsTouched();
      return;
    }

    this.isSubmitting.set(true);
    this.authError.set('');

    const { email, password } = this.authForm.getRawValue();
    const request$ = this.mode() === 'login'
      ? this.authService.login({ email, password })
      : this.authService.register({ email, password });

    request$
      .pipe(finalize(() => this.isSubmitting.set(false)))
      .subscribe({
        next: () => {
          void this.router.navigateByUrl('/home');
        },
        error: (error) => {
          const message = this.mode() === 'login'
            ? 'Nao foi possivel entrar. Verifique seu email e senha.'
            : 'Nao foi possivel criar sua conta agora. Tente novamente.';

          this.authError.set(error?.error?.message ?? message);
        }
      });
  }

  protected isFieldInvalid(fieldName: 'email' | 'password'): boolean {
    const field = this.authForm.controls[fieldName];
    return field.invalid && (field.touched || field.dirty);
  }

  protected get submitLabel(): string {
    if (this.isSubmitting()) {
      return this.mode() === 'login' ? 'Entrando...' : 'Criando conta...';
    }

    return this.mode() === 'login' ? 'Entrar' : 'Criar conta';
  }
}