import { InputHTMLAttributes, ReactNode, useState } from "react";
import { Eye, EyeOff } from "lucide-react";

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  trailingIcon?: ReactNode;
  error?: boolean;
  errorMessage?: string;
}

export default function Input({
  label,
  trailingIcon,
  error = false,
  errorMessage,
  type = "text",
  className = "",
  ...props
}: InputProps) {
  const [showPassword, setShowPassword] = useState(false);
  const isPassword = type === "password";
  const inputType = isPassword && showPassword ? "text" : type;

  return (
    <div className="flex flex-col gap-1.5">
      {label && (
        <label className="text-[13px] font-medium leading-[18px] text-[#1a1a1a]">
          {label}
        </label>
      )}
      <div className="relative">
        <input
          type={inputType}
          className={`h-[48px] w-full rounded-xl bg-[#f9fafb] border border-[#f3f4f6] px-4 text-[14px] leading-[20px] text-[#1a1a1a] outline-none transition-all placeholder:text-[#9ca3af] focus:border-[#1a1a1a] focus:bg-white ${
            error ? "border-[#ef4444] bg-[#fef2f2]" : ""
          } ${trailingIcon || isPassword ? "pr-12" : ""} ${className}`}
          {...props}
        />
        {isPassword && (
          <button
            type="button"
            onClick={() => setShowPassword(!showPassword)}
            className="absolute right-4 top-1/2 -translate-y-1/2 text-[#9ca3af] hover:text-[#1a1a1a]"
          >
            {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
          </button>
        )}
        {!isPassword && trailingIcon && (
          <div className="absolute right-4 top-1/2 -translate-y-1/2 text-[#9ca3af]">
            {trailingIcon}
          </div>
        )}
      </div>
      {error && errorMessage && (
        <span className="text-[12px] leading-[16px] text-[#ef4444]">{errorMessage}</span>
      )}
    </div>
  );
}
