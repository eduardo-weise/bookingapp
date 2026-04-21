import { useState } from "react";
import { useNavigate } from "react-router";
import { Mail, Phone, User, Key, Calendar } from "lucide-react";
import { motion } from "motion/react";
import Input from "../components/Input";
import Button from "../components/Button";
import BottomSheet from "../components/BottomSheet";

export default function Login() {
  const navigate = useNavigate();
  const [showRegister, setShowRegister] = useState(false);
  const [showRecovery, setShowRecovery] = useState(false);
  const [rememberMe, setRememberMe] = useState(false);

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    navigate("/client");
  };

  const handleRegister = (e: React.FormEvent) => {
    e.preventDefault();
    setShowRegister(false);
    navigate("/client");
  };

  const handleRecovery = (e: React.FormEvent) => {
    e.preventDefault();
    setShowRecovery(false);
    alert("Link de recuperação enviado!");
  };

  return (
    <div className="min-h-screen bg-[#f5f6f8] flex items-center justify-center p-6">
      <div className="w-full max-w-md">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="flex flex-col items-center mb-12"
        >
          {/* App Logo */}
          <div className="mb-6 flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-[#1a1a1a] to-[#2d2d2d] shadow-lg">
            <Calendar className="text-white" size={32} strokeWidth={1.5} />
          </div>

          <h1 className="text-[32px] font-bold leading-[40px] text-[#1a1a1a] mb-2">
            BookingApp
          </h1>
          <p className="text-[14px] leading-[20px] text-[#6b7280]">
            Agende seus serviços com facilidade
          </p>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="rounded-2xl bg-white p-8 shadow-[0_1px_3px_rgba(0,0,0,0.06)] border border-[#f3f4f6]"
        >
          <h2 className="mb-6 text-[20px] font-semibold leading-[28px] text-[#1a1a1a]">
            Entrar na sua conta
          </h2>

          <form onSubmit={handleLogin} className="flex flex-col gap-4">
            <Input
              type="email"
              label="Email"
              placeholder="seu@email.com"
              trailingIcon={<Mail size={18} />}
              required
            />

            <Input type="password" label="Senha" placeholder="••••••••" required />

            <div className="flex items-center justify-between">
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="h-4 w-4 rounded border-[#e5e7eb] text-[#1a1a1a] focus:ring-[#1a1a1a] focus:ring-offset-0"
                />
                <span className="text-[13px] leading-[18px] text-[#6b7280]">Lembrar-me</span>
              </label>
              <button
                type="button"
                onClick={() => setShowRecovery(true)}
                className="text-[13px] leading-[18px] text-[#1a1a1a] hover:text-[#4a5568]"
              >
                Esqueceu a senha?
              </button>
            </div>

            <Button variant="primary" fullWidth className="mt-2">
              Entrar
            </Button>

            <div className="my-2 flex items-center gap-4">
              <div className="h-[1px] flex-1 bg-[#e5e7eb]" />
              <span className="text-[12px] leading-[16px] text-[#9ca3af]">ou</span>
              <div className="h-[1px] flex-1 bg-[#e5e7eb]" />
            </div>

            <div className="flex justify-center gap-1.5 text-[13px]">
              <span className="text-[#6b7280]">Não tem uma conta?</span>
              <button
                type="button"
                onClick={() => setShowRegister(true)}
                className="font-medium text-[#1a1a1a] hover:text-[#4a5568]"
              >
                Cadastre-se
              </button>
            </div>
          </form>

          {/* Demo Access Buttons */}
          <div className="mt-6 flex flex-col gap-2 border-t border-[#f3f4f6] pt-6">
            <p className="text-center text-[11px] leading-[16px] text-[#9ca3af] mb-1">
              Acesso rápido (demonstração)
            </p>
            <Button variant="secondary" fullWidth onClick={() => navigate("/client")}>
              Entrar como Cliente
            </Button>
            <Button variant="ghost" fullWidth onClick={() => navigate("/admin")}>
              Entrar como Admin
            </Button>
          </div>
        </motion.div>
      </div>

      {/* Register Bottom Sheet */}
      <BottomSheet
        isOpen={showRegister}
        onClose={() => setShowRegister(false)}
        title="Criar Conta"
        height="large"
      >
        <form onSubmit={handleRegister} className="flex flex-col gap-4">
          <Input
            label="Nome Completo"
            placeholder="Seu nome"
            trailingIcon={<User size={18} />}
            required
          />
          <Input
            type="email"
            label="Email"
            placeholder="seu@email.com"
            trailingIcon={<Mail size={18} />}
            required
          />
          <Input
            type="tel"
            label="Telefone"
            placeholder="(11) 99999-9999"
            trailingIcon={<Phone size={18} />}
            required
          />
          <Input type="password" label="Senha" placeholder="••••••••" required />
          <Input type="password" label="Confirmar Senha" placeholder="••••••••" required />

          <Button variant="primary" fullWidth className="mt-6">
            Criar Conta
          </Button>
        </form>
      </BottomSheet>

      {/* Password Recovery Bottom Sheet */}
      <BottomSheet
        isOpen={showRecovery}
        onClose={() => setShowRecovery(false)}
        title=""
        height="small"
      >
        <div className="flex flex-col items-center">
          <div className="mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-[#f3f4f6]">
            <Key className="text-[#1a1a1a]" size={26} strokeWidth={1.5} />
          </div>
          <h2 className="mb-2 text-center text-[20px] font-semibold leading-[28px] text-[#1a1a1a]">
            Recuperar Senha
          </h2>
          <p className="mb-6 text-center text-[14px] leading-[20px] text-[#6b7280]">
            Digite seu email abaixo e enviaremos um link para redefinir sua senha
          </p>

          <form onSubmit={handleRecovery} className="w-full">
            <Input
              type="email"
              label="Email"
              placeholder="seu@email.com"
              trailingIcon={<Mail size={18} />}
              required
            />

            <Button variant="primary" fullWidth className="mt-6">
              Enviar Link de Recuperação
            </Button>

            <button
              type="button"
              onClick={() => setShowRecovery(false)}
              className="mt-4 w-full text-[13px] leading-[18px] text-[#6b7280] hover:text-[#1a1a1a]"
            >
              ← Voltar ao login
            </button>
          </form>
        </div>
      </BottomSheet>
    </div>
  );
}
