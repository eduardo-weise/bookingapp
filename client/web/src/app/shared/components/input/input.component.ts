import { ChangeDetectionStrategy, ChangeDetectorRef, Component, forwardRef, inject, input } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';

let nextInputId = 0;

@Component({
    selector: 'app-input',
    standalone: true,
    templateUrl: './input.component.html',
    styleUrl: './input.component.scss',
    providers: [
        {
            provide: NG_VALUE_ACCESSOR,
            useExisting: forwardRef(() => InputComponent),
            multi: true
        }
    ],
    changeDetection: ChangeDetectionStrategy.OnPush
})
export class InputComponent implements ControlValueAccessor {
    private readonly changeDetectorRef = inject(ChangeDetectorRef);

    readonly label = input('');
    readonly placeholder = input('');
    readonly type = input<'text' | 'email' | 'tel' | 'password' | 'date' | 'time'>('text');
    readonly hint = input('');
    readonly id = input('');
    readonly disabled = input(false);
    readonly readonly = input(false);
    readonly required = input(false);
    protected readonly inputId = `app-input-${++nextInputId}`;

    protected value = '';
    protected isDisabled = false;
    private onChange: (value: string) => void = () => {};
    private onTouched: () => void = () => {};

    writeValue(value: string | null): void {
        this.value = value ?? '';
        this.changeDetectorRef.markForCheck();
    }

    registerOnChange(fn: (value: string) => void): void {
        this.onChange = fn;
    }

    registerOnTouched(fn: () => void): void {
        this.onTouched = fn;
    }

    setDisabledState(isDisabled: boolean): void {
        this.isDisabled = isDisabled;
        this.changeDetectorRef.markForCheck();
    }

    protected handleInput(event: Event): void {
        const target = event.target as HTMLInputElement;
        const value = target.value;
        this.value = value;
        this.onChange(value);
        this.changeDetectorRef.markForCheck();
    }

    protected handleBlur(): void {
        this.onTouched();
    }

    protected get resolvedInputId(): string {
        return this.id() || this.inputId;
    }
}
