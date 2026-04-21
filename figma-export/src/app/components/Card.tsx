import { ReactNode } from "react";

interface CardProps {
  children: ReactNode;
  className?: string;
  onClick?: () => void;
}

export default function Card({ children, className = "", onClick }: CardProps) {
  return (
    <div
      className={`rounded-2xl bg-white p-5 shadow-[0_1px_3px_rgba(0,0,0,0.06)] border border-[#f3f4f6] ${
        onClick ? "cursor-pointer hover:shadow-[0_4px_6px_rgba(0,0,0,0.04)] transition-all duration-200" : ""
      } ${className}`}
      onClick={onClick}
    >
      {children}
    </div>
  );
}
