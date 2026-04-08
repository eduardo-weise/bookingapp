import { HttpClient } from '@angular/common/http';
import { OnInit, ChangeDetectionStrategy, Component, DestroyRef, ElementRef, ViewChild, afterNextRender, inject, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { AbstractControl, FormBuilder, ReactiveFormsModule, ValidationErrors, ValidatorFn, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { animate, createLayout } from 'animejs';
import type { AutoLayout } from 'animejs/layout';
import { catchError, debounceTime, distinctUntilChanged, filter, finalize, of, tap } from 'rxjs';
import { AuthService } from '../../../core/services/auth.service';
import { ButtonComponent } from '../../../shared/components/button/button.component';
import { CardComponent } from '../../../shared/components/card/card.component';
import { InputComponent } from '../../../shared/components/input/input.component';

type AuthMode = 'login' | 'register';
type FormField = 'email' | 'password' | 'confirmPassword' | 'cpf' | 'street' | 'number' | 'neighborhood' | 'zipCode' | 'city' | 'state' | 'rememberMe';

const LAYOUT_ANIMATION_DURATION = 880;
const LAYOUT_ANIMATION_EASING = 'outExpo';

interface ViaCepResponse {
	cep?: string;
	logradouro?: string;
	bairro?: string;
	localidade?: string;
	uf?: string;
	erro?: boolean;
}

@Component({
	selector: 'app-login-page',
	standalone: true,
	imports: [ReactiveFormsModule, ButtonComponent, CardComponent, InputComponent],
	templateUrl: './login-page.component.html',
	styleUrl: './login-page.component.scss',
	changeDetection: ChangeDetectionStrategy.OnPush
})
export class LoginPageComponent implements OnInit {
	@ViewChild('stage')
	private readonly stageRef?: ElementRef<HTMLElement>;

	@ViewChild('infoPanel')
	private readonly infoPanelRef?: ElementRef<HTMLElement>;

	@ViewChild('cardShell', { read: ElementRef })
	private readonly formCardRef?: ElementRef<HTMLElement>;

	private readonly formBuilder = inject(FormBuilder);
	private readonly http = inject(HttpClient);
	private readonly authService = inject(AuthService);
	private readonly router = inject(Router);
	private readonly destroyRef = inject(DestroyRef);
	private stageLayout?: AutoLayout;

	protected readonly mode = signal<AuthMode>('login');
	protected readonly isSubmitting = signal(false);
	protected readonly authError = signal('');
	protected readonly isAnimating = signal(false);
	protected readonly zipFeedback = signal('');
	protected readonly isZipLookupLoading = signal(false);
	protected readonly authForm = this.formBuilder.nonNullable.group({
		email: ['', [Validators.required, Validators.email]],
		password: ['', [Validators.required, Validators.minLength(8)]],
		confirmPassword: [{ value: '', disabled: true }],
		cpf: [{ value: '', disabled: true }],
		street: [{ value: '', disabled: true }],
		number: [{ value: '', disabled: true }],
		neighborhood: [{ value: '', disabled: true }],
		zipCode: [{ value: '', disabled: true }],
		city: [{ value: '', disabled: true }],
		state: [{ value: '', disabled: true }],
		rememberMe: [true]
	});

	constructor() {
		this.setupZipLookup();
		this.setupCpfSanitizer();
		this.authForm.controls.password.valueChanges
			.pipe(takeUntilDestroyed(this.destroyRef))
			.subscribe(() => {
				this.authForm.controls.confirmPassword.updateValueAndValidity({ onlySelf: true });
			});

		afterNextRender(() => {
			this.stageLayout = createLayout('.auth-page', {
				duration: LAYOUT_ANIMATION_DURATION,
				ease: LAYOUT_ANIMATION_EASING,
				onBegin: () => this.isAnimating.set(true),
				onComplete: () => this.isAnimating.set(false)
			});
		});
	}

	ngOnInit(): void {
		animate('.js-entrance', {
			translateY: [24, 0],
			delay: (_, index) => index * 110,
			duration: 640,
			ease: 'outExpo'
		});
	}

	protected async toggleMode(): Promise<void> {
		if (this.isAnimating()) {
			return;
		}

		const nextMode: AuthMode = this.mode() === 'login' ? 'register' : 'login';
		const stage = this.stageRef?.nativeElement;
		const formCard = this.formCardRef?.nativeElement;
		const infoPanel = this.infoPanelRef?.nativeElement;

		if (!stage || !formCard || !infoPanel || !this.stageLayout) {
			this.mode.set(nextMode);
			this.authError.set('');
			this.configureMode(nextMode);
			return;
		}

		this.authError.set('');
		const currentRect = formCard.getBoundingClientRect();

		const layoutTransition = this.stageLayout.update(() => {
			this.mode.set(nextMode);
			this.configureMode(nextMode);
			this.authForm.markAsPristine();
			this.authForm.markAsUntouched();

			stage.dataset['mode'] = nextMode;
			formCard.classList.toggle('auth-card--right', this.isRegisterMode);
			infoPanel.classList.toggle('auth-info--left', this.isRegisterMode);
		});

		await this.waitForNextFrame();
		const targetSize = this.getElementSize(formCard);
		const sizeTransition = this.animateCardSize(formCard, currentRect, targetSize.width, targetSize.height);


		await Promise.all([layoutTransition, sizeTransition]);
	}

	protected submitAuth(): void {
		if (this.authForm.invalid) {
			this.authForm.markAllAsTouched();
			return;
		}

		const { email, password, cpf, street, number, neighborhood, zipCode, city, state } = this.authForm.getRawValue();
		const request$ = this.mode() === 'login'
			? this.authService.login({ email, password })
			: this.authService.register({
				email,
				password,
				cpf,
				address: {
					street,
					number,
					neighborhood,
					zipCode,
					city,
					state
				}
			});

		this.isSubmitting.set(true);
		this.authError.set('');

		request$
			.pipe(finalize(() => this.isSubmitting.set(false)))
			.subscribe({
				next: () => void this.router.navigateByUrl('/home'),
				error: (error) => {
					const fallbackMessage = this.isRegisterMode
						? 'Nao foi possivel criar sua conta agora. Tente novamente.'
						: 'Nao foi possivel entrar. Verifique suas credenciais.';

					this.authError.set(error?.error?.message ?? fallbackMessage);
				}
			});
	}

	protected isFieldInvalid(fieldName: FormField): boolean {
		const field = this.authForm.controls[fieldName];
		return field.invalid && (field.touched || field.dirty);
	}

	protected get isRegisterMode(): boolean {
		return this.mode() === 'register';
	}

	protected get welcomeEyebrow(): string {
		return this.isRegisterMode ? 'Ja tem uma conta?' : 'Novo por aqui?';
	}

	protected get welcomeTitle(): string {
		return this.isRegisterMode ? 'Volte para entrar e acompanhar seus agendamentos.' : 'Crie sua conta e comece a organizar seus agendamentos.';
	}

	protected get sideButtonLabel(): string {
		return this.isRegisterMode ? 'Entrar agora' : 'Cadastrar';
	}

	protected get cardEyebrow(): string {
		return this.isRegisterMode ? 'Criar conta' : 'Seu logo';
	}

	protected get cardTitle(): string {
		return this.isRegisterMode ? 'Cadastro' : 'Login';
	}

	protected get cardDescription(): string {
		return this.isRegisterMode
			? 'Preencha seus dados para criar a conta e finalizar seu perfil.'
			: 'Use seu email e senha para acessar a plataforma.';
	}

	protected get submitLabel(): string {
		if (this.isSubmitting()) {
			return this.isRegisterMode ? 'Criando conta...' : 'Entrando...';
		}

		return this.isRegisterMode ? 'Criar conta' : 'Sign in';
	}

	private configureMode(mode: AuthMode): void {
		if (mode === 'login') {
			this.authForm.controls.confirmPassword.reset('', { emitEvent: false });
			this.authForm.controls.confirmPassword.clearValidators();
			this.authForm.controls.confirmPassword.disable({ emitEvent: false });
			this.authForm.controls.confirmPassword.updateValueAndValidity({ emitEvent: false });
			this.authForm.controls.cpf.clearValidators();
			this.authForm.controls.cpf.disable({ emitEvent: false });
			this.authForm.controls.cpf.updateValueAndValidity({ emitEvent: false });
			for (const fieldName of ['street', 'number', 'neighborhood', 'zipCode', 'city', 'state'] as const) {
				this.authForm.controls[fieldName].clearValidators();
				this.authForm.controls[fieldName].disable({ emitEvent: false });
				this.authForm.controls[fieldName].updateValueAndValidity({ emitEvent: false });
			}
			this.authForm.controls.rememberMe.enable({ emitEvent: false });
			this.zipFeedback.set('');
			return;
		}

		this.authForm.controls.confirmPassword.enable({ emitEvent: false });
		this.authForm.controls.confirmPassword.setValidators([
			Validators.required,
			Validators.minLength(8),
			this.confirmPasswordValidator()
		]);
		this.authForm.controls.confirmPassword.updateValueAndValidity({ emitEvent: false });

		for (const fieldName of ['street', 'number', 'neighborhood', 'city', 'state'] as const) {
			this.authForm.controls[fieldName].setValidators([Validators.required]);
			this.authForm.controls[fieldName].updateValueAndValidity({ emitEvent: false });

			if (fieldName === 'city' || fieldName === 'state')
				continue;

			this.authForm.controls[fieldName].enable({ emitEvent: false });
		}

		this.authForm.controls.cpf.enable({ emitEvent: false });
		this.authForm.controls.cpf.setValidators([
			Validators.required,
			Validators.minLength(11),
			Validators.maxLength(11)
		]);
		this.authForm.controls.cpf.updateValueAndValidity({ emitEvent: false });

		this.authForm.controls.zipCode.enable({ emitEvent: false });
		this.authForm.controls.zipCode.setValidators([
			Validators.required,
			Validators.minLength(8),
			Validators.maxLength(8)
		]);
		this.authForm.controls.zipCode.updateValueAndValidity({ emitEvent: false });
		this.authForm.controls.rememberMe.setValue(false, { emitEvent: false });
		this.authForm.controls.rememberMe.disable({ emitEvent: false });
	}

	private confirmPasswordValidator(): ValidatorFn {
		return (control: AbstractControl): ValidationErrors | null => {
			const password = control.parent?.get('password')?.value;
			return !control.value || control.value === password ? null : { passwordMismatch: true };
		};
	}

	private setupZipLookup(): void {
		this.authForm.controls.zipCode.valueChanges
			.pipe(
				tap((rawValue) => {
					const digitsOnly = this.onlyDigits(rawValue);
					if (rawValue !== digitsOnly) {
						this.authForm.controls.zipCode.setValue(digitsOnly, { emitEvent: false });
					}
				}),
				debounceTime(350),
				distinctUntilChanged(),
				filter((zipCode) => zipCode.length === 8 && this.mode() === 'register'),
				takeUntilDestroyed(this.destroyRef)
			)
			.subscribe((zipCode) => {
				this.fetchAddressByZipCode(zipCode);
			});
	}

	private setupCpfSanitizer(): void {
		this.authForm.controls.cpf.valueChanges
			.pipe(
				takeUntilDestroyed(this.destroyRef),
				tap((rawValue) => {
					const digitsOnly = this.onlyDigits(rawValue).slice(0, 11);
					if (rawValue !== digitsOnly) {
						this.authForm.controls.cpf.setValue(digitsOnly, { emitEvent: false });
					}
				})
			)
			.subscribe();
	}

	private fetchAddressByZipCode(zipCode: string): void {
		this.isZipLookupLoading.set(true);
		this.zipFeedback.set('Consultando CEP...');

		this.http
			.get<ViaCepResponse>(`https://viacep.com.br/ws/${zipCode}/json/`)
			.pipe(
				finalize(() => this.isZipLookupLoading.set(false)),
				catchError(() => {
					this.zipFeedback.set('Nao foi possivel consultar o CEP.');
					return of(null);
				})
			)
			.subscribe((response) => {
				if (!response || response.erro) {
					this.zipFeedback.set('CEP nao encontrado.');
					return;
				}

				this.authForm.patchValue({
					street: response.logradouro ?? this.authForm.controls.street.value,
					neighborhood: response.bairro ?? this.authForm.controls.neighborhood.value,
					city: response.localidade ?? '',
					state: response.uf ?? ''
				});

				this.zipFeedback.set('Cidade e estado preenchidos automaticamente.');
			});
	}

	private onlyDigits(value: string): string {
		return value.replaceAll(/\D/g, '');
	}

	private waitForNextFrame(): Promise<void> {
		return new Promise((resolve) => requestAnimationFrame(() => resolve()));
	}

	private getElementSize(element: HTMLElement): { width: number; height: number } {
		const computedStyle = getComputedStyle(element);
		return {
			width: Number.parseFloat(computedStyle.width),
			height: Number.parseFloat(computedStyle.height)
		};
	}

	private animateCardSize(
		cardElement: HTMLElement,
		fromRect: DOMRect,
		toWidth: number,
		toHeight: number
	): Promise<void> {
		if (!Number.isFinite(toWidth) || !Number.isFinite(toHeight)) {
			return Promise.resolve();
		}

		if (Math.abs(fromRect.width - toWidth) < 0.5 && Math.abs(fromRect.height - toHeight) < 0.5) {
			return Promise.resolve();
		}

		cardElement.style.width = `${fromRect.width}px`;
		cardElement.style.height = `${fromRect.height}px`;
		cardElement.style.flex = '0 0 auto';

		return new Promise((resolve) => {
			animate(cardElement, {
				width: [`${fromRect.width}px`, `${toWidth}px`],
				height: [`${fromRect.height}px`, `${toHeight}px`],
				duration: LAYOUT_ANIMATION_DURATION,
				ease: LAYOUT_ANIMATION_EASING,
				onComplete: () => {
					cardElement.style.width = '';
					cardElement.style.height = '';
					cardElement.style.flex = '';
					resolve();
				}
			});
		});
	}
}
