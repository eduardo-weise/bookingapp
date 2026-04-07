import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';

@Component({
    selector: 'app-badge',
    standalone: true,
    templateUrl: './badge.component.html',
    styleUrl: './badge.component.scss',
    changeDetection: ChangeDetectionStrategy.OnPush
})
export class BadgeComponent {
    readonly label = input('Badge');
    readonly tone = input<'neutral' | 'accent' | 'inverse'>('neutral');

    protected readonly badgeClass = computed(() => `badge badge--${this.tone()}`);
}