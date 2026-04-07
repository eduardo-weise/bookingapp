import { Injectable, Inject, PLATFORM_ID, effect, signal } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';

export type Theme = 'light' | 'dark';

@Injectable({
	providedIn: 'root'
})
export class ThemeService {
	private readonly THEME_KEY = 'agende-theme-preference';
	public currentTheme = signal<Theme>('light');

	constructor(@Inject(PLATFORM_ID) private platformId: Object) {
		if (isPlatformBrowser(this.platformId)) {
			this.initTheme();

			// Effect to reactively update the DOM when the signal changes
			effect(() => {
				document.documentElement.setAttribute('data-theme', this.currentTheme());
			});
		}
	}

	private initTheme(): void {
		const savedTheme = localStorage.getItem(this.THEME_KEY) as Theme | null;
		if (savedTheme) {
			this.currentTheme.set(savedTheme);
		} else {
			const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
			this.currentTheme.set(prefersDark ? 'dark' : 'light');
		}

		// Listen for OS theme changes if user hasn't explicitly set a preference
		window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
			const saved = localStorage.getItem(this.THEME_KEY);
			if (!saved) { // Only auto-switch if user didn't force a theme
				this.currentTheme.set(e.matches ? 'dark' : 'light');
			}
		});
	}

	public toggleTheme(): void {
		const next: Theme = this.currentTheme() === 'light' ? 'dark' : 'light';
		this.currentTheme.set(next);
		localStorage.setItem(this.THEME_KEY, next);
	}

	public setTheme(theme: Theme): void {
		this.currentTheme.set(theme);
		localStorage.setItem(this.THEME_KEY, theme);
	}
}
