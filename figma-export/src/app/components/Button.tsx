import { ButtonHTMLAttributes, ReactNode } from "react";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "ghost" | "danger";
  children: ReactNode;
  fullWidth?: boolean;
  small?: boolean;
}

export default function Button({
  variant = "primary",
  children,
  fullWidth = false,
  small = false,
  className = "",
  ...props
}: ButtonProps) {
  const baseStyles = "h-[48px] px-6 rounded-[12px] font-medium transition-all duration-200";
  const smallStyles = small ? "h-8 px-3 text-sm" : "";
  const widthStyles = fullWidth ? "w-full" : "";

  const variants = {
    primary: "bg-[#1a1a1a] text-white hover:bg-[#2d2d2d] active:scale-[0.98]",
    secondary:
      "border border-[#e5e7eb] text-[#1a1a1a] bg-white hover:bg-[#f9fafb] active:scale-[0.98]",
    ghost: "text-[#6b7280] bg-transparent hover:bg-[#f3f4f6] active:scale-[0.98]",
    danger:
      "bg-[#fef2f2] text-[#ef4444] border border-[#fecaca] hover:bg-[#fee2e2] active:scale-[0.98]",
  };

  return (
    <button
      className={`${baseStyles} ${variants[variant]} ${widthStyles} ${smallStyles} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}
