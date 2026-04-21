import { ReactNode } from "react";

interface BadgeProps {
  variant: "confirmed" | "pending" | "cancelled";
  children: ReactNode;
}

export default function Badge({ variant, children }: BadgeProps) {
  const variants = {
    confirmed: "bg-[#d1fae5] text-[#059669] border-[#a7f3d0]",
    pending: "bg-[#fef3c7] text-[#d97706] border-[#fde68a]",
    cancelled: "bg-[#fee2e2] text-[#dc2626] border-[#fecaca]",
  };

  return (
    <span
      className={`inline-flex h-[24px] items-center rounded-lg px-2.5 text-[12px] font-medium leading-[16px] border ${variants[variant]}`}
    >
      {children}
    </span>
  );
}
