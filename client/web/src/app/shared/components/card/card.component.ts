import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
    selector: 'app-card',
    standalone: true,
    templateUrl: './card.component.html',
    styleUrl: './card.component.scss',
    changeDetection: ChangeDetectionStrategy.OnPush
})
export class CardComponent {
    readonly title = input('');
    readonly subtitle = input('');
    readonly variant = input<'glass' | 'solid'>('glass');
}
