import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';

@Component({
    selector: 'app-bottom-sheet',
    standalone: true,
    templateUrl: './bottom-sheet.component.html',
    styleUrl: './bottom-sheet.component.scss',
    changeDetection: ChangeDetectionStrategy.OnPush
})
export class BottomSheetComponent {
    readonly title = input('');
    readonly description = input('');
    readonly open = input(false);
    readonly closed = output<void>();

    close(): void {
        this.closed.emit();
    }
}