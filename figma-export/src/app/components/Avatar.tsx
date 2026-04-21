import { User, Pencil } from "lucide-react";

interface AvatarProps {
  src?: string;
  alt?: string;
  size?: 40 | 56 | 80;
  showEditBadge?: boolean;
  onEdit?: () => void;
}

export default function Avatar({
  src,
  alt = "Avatar",
  size = 40,
  showEditBadge = false,
  onEdit,
}: AvatarProps) {
  return (
    <div className="relative inline-block">
      <div
        className="overflow-hidden rounded-full bg-gradient-to-br from-[#f3f4f6] to-[#e5e7eb] border-2 border-white shadow-sm"
        style={{ width: `${size}px`, height: `${size}px` }}
      >
        {src ? (
          <img src={src} alt={alt} className="h-full w-full object-cover" />
        ) : (
          <div className="flex h-full w-full items-center justify-center">
            <User className="text-[#6b7280]" size={size * 0.45} strokeWidth={1.5} />
          </div>
        )}
      </div>
      {showEditBadge && (
        <button
          onClick={onEdit}
          className="absolute bottom-0 right-0 flex h-6 w-6 items-center justify-center rounded-full bg-[#1a1a1a] hover:bg-[#2d2d2d] shadow-md border-2 border-white"
        >
          <Pencil className="text-white" size={11} strokeWidth={2} />
        </button>
      )}
    </div>
  );
}
