import { ChangeDetectionStrategy, Component, input } from '@angular/core';

let nextInputId = 0;

@Component({
    selector: 'app-input',
    standalone: true,
    templateUrl: './input.component.html',
    styleUrl: './input.component.scss',
    changeDetection: ChangeDetectionStrategy.OnPush
})
export class InputComponent {
    readonly label = input('');
    readonly placeholder = input('');
    readonly type = input<'text' | 'email' | 'tel' | 'password' | 'date' | 'time'>('text');
    readonly value = input('');
    readonly hint = input('');
    readonly disabled = input(false);
    readonly readonly = input(false);
    readonly required = input(false);
    protected readonly inputId = `app-input-${++nextInputId}`;
}