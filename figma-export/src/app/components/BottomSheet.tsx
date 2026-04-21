import { ReactNode, useEffect } from "react";
import { motion, AnimatePresence } from "motion/react";
import { X } from "lucide-react";

interface BottomSheetProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  children: ReactNode;
  height?: "small" | "medium" | "large";
}

export default function BottomSheet({
  isOpen,
  onClose,
  title,
  children,
  height = "medium",
}: BottomSheetProps) {
  const heights = {
    small: "35%",
    medium: "55%",
    large: "85%",
  };

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "unset";
    }
    return () => {
      document.body.style.overflow = "unset";
    };
  }, [isOpen]);

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Overlay */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-40 bg-black/30 backdrop-blur-sm"
            onClick={onClose}
          />

          {/* Bottom Sheet */}
          <motion.div
            initial={{ y: "100%" }}
            animate={{ y: 0 }}
            exit={{ y: "100%" }}
            transition={{ type: "spring", damping: 35, stiffness: 400 }}
            className="fixed bottom-0 left-0 right-0 z-50 rounded-t-[28px] bg-white px-6 pb-8 pt-4 shadow-[0_-4px_16px_rgba(0,0,0,0.08)]"
            style={{ maxHeight: heights[height], overflowY: "auto" }}
          >
            {/* Handle Bar */}
            <div className="mb-4 flex justify-center">
              <div className="h-1 w-10 rounded-full bg-[#e5e7eb]" />
            </div>

            {/* Header */}
            {title && (
              <div className="mb-6 flex items-center justify-between">
                <h2 className="text-[20px] font-semibold leading-[28px] text-[#1a1a1a]">
                  {title}
                </h2>
                <button
                  onClick={onClose}
                  className="rounded-xl p-2 text-[#9ca3af] hover:bg-[#f3f4f6] hover:text-[#1a1a1a]"
                >
                  <X size={22} strokeWidth={1.5} />
                </button>
              </div>
            )}

            {/* Content */}
            <div>{children}</div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
