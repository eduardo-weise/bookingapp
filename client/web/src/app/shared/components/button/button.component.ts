import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';

@Component({
    selector: 'app-button',
    standalone: true,
    templateUrl: './button.component.html',
    styleUrl: './button.component.scss',
    host: {
        '[class.button-host--full]': 'fullWidth()'
    },
    changeDetection: ChangeDetectionStrategy.OnPush
})
export class ButtonComponent {
    readonly label = input('Action');
    readonly variant = input<'primary' | 'secondary' | 'ghost'>('primary');
    readonly size = input<'sm' | 'md' | 'lg'>('md');
    readonly type = input<'button' | 'submit' | 'reset'>('button');
    readonly disabled = input(false);
    readonly fullWidth = input(false);

    protected readonly buttonClass = computed(() => [
        'button',
        `button--${this.variant()}`,
        `button--${this.size()}`,
        this.fullWidth() ? 'button--full' : ''
    ].filter(Boolean).join(' '));
}