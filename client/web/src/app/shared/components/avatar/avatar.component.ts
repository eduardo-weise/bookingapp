import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';

@Component({
    selector: 'app-avatar',
    standalone: true,
    templateUrl: './avatar.component.html',
    styleUrl: './avatar.component.scss',
    changeDetection: ChangeDetectionStrategy.OnPush
})
export class AvatarComponent {
    readonly name = input('Guest');
    readonly imageUrl = input('');
    readonly size = input<'sm' | 'md' | 'lg'>('md');

    protected readonly avatarClass = computed(() => `avatar avatar--${this.size()}`);
    protected readonly initials = computed(() => this.name()
        .split(' ')
        .filter(Boolean)
        .slice(0, 2)
        .map(part => part[0]?.toUpperCase() ?? '')
        .join(''));
}