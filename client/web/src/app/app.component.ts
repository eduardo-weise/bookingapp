import { Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ThemeService } from './shared/services/theme.service';

@Component({
	standalone: true,
	selector: 'app-root',
	imports: [RouterOutlet],
	templateUrl: './app.component.html',
	styleUrl: './app.component.scss'
})
export class AppComponent {
	// Ensure theme service is instantiated on app startup.
	private readonly themeService = inject(ThemeService);

	title = 'web';
}
