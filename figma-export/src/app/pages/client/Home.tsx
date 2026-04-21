import { useState } from "react";
import {
  Bell, Calendar, Clock, MoreVertical, Plus,
  History, User as UserIcon, ChevronRight, Wallet
} from "lucide-react";
import { motion } from "motion/react";
import { useNavigate } from "react-router";
import Avatar from "../../components/Avatar";
import Card from "../../components/Card";
import Badge from "../../components/Badge";
import Button from "../../components/Button";
import BottomSheet from "../../components/BottomSheet";
import Input from "../../components/Input";

const appointments = [
  {
    id: 1,
    service: "Corte de Cabelo",
    location: "Barbearia Central",
    date: "15 Abr",
    time: "14:00",
    status: "confirmed" as const,
  },
  {
    id: 2,
    service: "Manicure",
    location: "Studio Bella",
    date: "18 Abr",
    time: "10:30",
    status: "pending" as const,
  },
];

const services = [
  { id: 1, name: "Corte de Cabelo", duration: "45min", price: 50.0 },
  { id: 2, name: "Manicure", duration: "30min", price: 40.0 },
  { id: 3, name: "Massagem", duration: "60min", price: 120.0 },
  { id: 4, name: "Depilação", duration: "40min", price: 80.0 },
];

const availableTimes = ["09:00", "10:00", "11:00", "14:00", "15:00", "16:00", "17:00", "18:00"];

export default function ClientHome() {
  const navigate = useNavigate();
  const [showBooking, setShowBooking] = useState(false);
  const [showOptions, setShowOptions] = useState(false);
  const [showHistory, setShowHistory] = useState(false);
  const [showProfile, setShowProfile] = useState(false);
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [selectedTime, setSelectedTime] = useState<string | null>(null);
  const [selectedService, setSelectedService] = useState<string>("");

  const handleBooking = () => {
    if (!selectedService || !selectedDate || !selectedTime) {
      alert("Por favor, preencha todos os campos");
      return;
    }
    setShowBooking(false);
    setSelectedService("");
    setSelectedDate(null);
    setSelectedTime(null);
    alert("Agendamento confirmado!");
  };

  return (
    <div className="min-h-screen bg-[#f5f6f8] pb-6">
      {/* Header */}
      <div className="px-6 pt-12 pb-6">
        <div className="mb-6 flex items-start justify-between">
          <div>
            <h1 className="text-[28px] font-bold leading-[36px] text-[#1a1a1a]">
              Olá, Maria
            </h1>
            <p className="text-[13px] leading-[18px] text-[#6b7280] mt-1">
              Bem-vindo ao seu painel
            </p>
          </div>
          <button className="relative rounded-xl p-2.5 hover:bg-white transition-colors">
            <Bell className="text-[#1a1a1a]" size={22} strokeWidth={1.5} />
            <span className="absolute right-2 top-2 h-2 w-2 rounded-full bg-[#ef4444]" />
          </button>
        </div>

        <div className="flex justify-center">
          <Avatar size={80} showEditBadge />
        </div>
      </div>

      {/* Quick Actions - Bento Style */}
      <div className="px-6 mb-6">
        <div className="grid grid-cols-3 gap-3">
          <motion.button
            whileTap={{ scale: 0.97 }}
            onClick={() => setShowBooking(true)}
            className="flex flex-col items-center justify-center rounded-2xl bg-white p-5 shadow-sm border border-[#f3f4f6] hover:shadow-md transition-all"
          >
            <div className="mb-3 flex h-12 w-12 items-center justify-center rounded-xl bg-[#f3f4f6]">
              <Plus className="text-[#1a1a1a]" size={20} strokeWidth={2} />
            </div>
            <span className="text-[12px] font-medium text-[#1a1a1a]">Agendar</span>
          </motion.button>

          <motion.button
            whileTap={{ scale: 0.97 }}
            onClick={() => setShowHistory(true)}
            className="flex flex-col items-center justify-center rounded-2xl bg-white p-5 shadow-sm border border-[#f3f4f6] hover:shadow-md transition-all"
          >
            <div className="mb-3 flex h-12 w-12 items-center justify-center rounded-xl bg-[#f3f4f6]">
              <History className="text-[#1a1a1a]" size={20} strokeWidth={1.5} />
            </div>
            <span className="text-[12px] font-medium text-[#1a1a1a]">Histórico</span>
          </motion.button>

          <motion.button
            whileTap={{ scale: 0.97 }}
            onClick={() => setShowProfile(true)}
            className="flex flex-col items-center justify-center rounded-2xl bg-white p-5 shadow-sm border border-[#f3f4f6] hover:shadow-md transition-all"
          >
            <div className="mb-3 flex h-12 w-12 items-center justify-center rounded-xl bg-[#f3f4f6]">
              <UserIcon className="text-[#1a1a1a]" size={20} strokeWidth={1.5} />
            </div>
            <span className="text-[12px] font-medium text-[#1a1a1a]">Perfil</span>
          </motion.button>
        </div>
      </div>

      {/* Saldo/Débito Card */}
      <div className="px-6 mb-6">
        <Card className="!bg-gradient-to-br from-[#1a1a1a] to-[#2d2d2d] !border-0 !p-6">
          <div className="flex items-start justify-between mb-4">
            <div>
              <p className="text-[12px] leading-[16px] text-white/70 mb-1">Débito Pendente</p>
              <p className="text-[32px] font-bold leading-[40px] text-white">R$ 150,00</p>
            </div>
            <Button
              variant="secondary"
              small
              className="!bg-white !text-[#1a1a1a] !border-0"
              onClick={() => navigate("/client/finances")}
            >
              Pagar
            </Button>
          </div>
          <p className="text-[11px] leading-[16px] text-white/60">
            Referente ao serviço de 10 Mar 2026
          </p>
        </Card>
      </div>

      {/* Próximos Agendamentos */}
      <div className="px-6">
        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-[20px] font-semibold leading-[28px] text-[#1a1a1a]">
            Próximos Agendamentos
          </h2>
          <button className="text-[13px] font-medium text-[#6b7280] hover:text-[#1a1a1a] flex items-center gap-1">
            Ver todos
            <ChevronRight size={14} />
          </button>
        </div>

        <div className="grid gap-4">
          {appointments.map((appointment, index) => (
            <motion.div
              key={appointment.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.1 }}
            >
              <Card>
                <div className="flex items-start gap-4">
                  <div className="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-xl bg-[#f3f4f6]">
                    <Calendar className="text-[#1a1a1a]" size={20} strokeWidth={1.5} />
                  </div>

                  <div className="flex-1">
                    <div className="mb-1.5 flex items-start justify-between">
                      <div>
                        <h3 className="text-[16px] font-semibold leading-[24px] text-[#1a1a1a]">
                          {appointment.service}
                        </h3>
                        <p className="text-[12px] leading-[16px] text-[#9ca3af]">
                          {appointment.location}
                        </p>
                      </div>
                      <button className="rounded-lg p-1.5 hover:bg-[#f3f4f6]">
                        <MoreVertical className="text-[#9ca3af]" size={16} />
                      </button>
                    </div>

                    <div className="mb-3 flex items-center gap-3 text-[12px] text-[#6b7280]">
                      <span className="flex items-center gap-1.5">
                        <Calendar size={14} strokeWidth={1.5} />
                        {appointment.date}
                      </span>
                      <span>·</span>
                      <span className="flex items-center gap-1.5">
                        <Clock size={14} strokeWidth={1.5} />
                        {appointment.time}
                      </span>
                    </div>

                    <Badge variant={appointment.status}>
                      {appointment.status === "confirmed" ? "Confirmado" : "Pendente"}
                    </Badge>
                  </div>
                </div>
              </Card>
            </motion.div>
          ))}
        </div>
      </div>

      {/* Booking Bottom Sheet */}
      <BottomSheet
        isOpen={showBooking}
        onClose={() => setShowBooking(false)}
        title="Agendar Serviço"
        height="large"
      >
        <div className="flex flex-col gap-6">
          <div>
            <label className="mb-2 block text-[13px] font-medium leading-[18px] text-[#1a1a1a]">
              Selecione o Serviço
            </label>
            <select
              value={selectedService}
              onChange={(e) => setSelectedService(e.target.value)}
              className="h-[48px] w-full rounded-xl bg-[#f9fafb] border border-[#f3f4f6] px-4 text-[14px] leading-[20px] text-[#1a1a1a] outline-none focus:border-[#1a1a1a] focus:bg-white"
            >
              <option value="">Escolha um serviço</option>
              {services.map((service) => (
                <option key={service.id} value={service.name}>
                  {service.name} - R$ {service.price.toFixed(2)}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="mb-2 block text-[13px] font-medium leading-[18px] text-[#1a1a1a]">
              Selecione a Data
            </label>
            <Input
              type="date"
              value={selectedDate?.toISOString().split("T")[0] || ""}
              onChange={(e) => setSelectedDate(new Date(e.target.value))}
            />
          </div>

          {selectedDate && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: "auto" }}
              className="overflow-hidden"
            >
              <p className="mb-3 text-[12px] leading-[16px] font-medium text-[#6b7280]">
                Horários Disponíveis — {selectedDate.toLocaleDateString("pt-BR")}
              </p>
              <div className="grid grid-cols-3 gap-2">
                {availableTimes.map((time) => (
                  <button
                    key={time}
                    onClick={() => setSelectedTime(time)}
                    className={`h-11 rounded-xl border text-[14px] font-medium transition-all ${
                      selectedTime === time
                        ? "border-[#1a1a1a] bg-[#f3f4f6] text-[#1a1a1a]"
                        : "border-[#e5e7eb] bg-white text-[#6b7280] hover:border-[#6b7280]"
                    }`}
                  >
                    {time}
                  </button>
                ))}
              </div>
            </motion.div>
          )}

          <Button variant="primary" fullWidth onClick={handleBooking} className="mt-4">
            Confirmar Agendamento
          </Button>
        </div>
      </BottomSheet>

      {/* History Bottom Sheet */}
      <BottomSheet
        isOpen={showHistory}
        onClose={() => setShowHistory(false)}
        title="Histórico"
        height="large"
      >
        <div className="text-center py-12 text-[#9ca3af]">
          <History size={48} strokeWidth={1.5} className="mx-auto mb-3 opacity-30" />
          <p className="text-[14px]">Nenhum agendamento no histórico</p>
        </div>
      </BottomSheet>

      {/* Profile Bottom Sheet */}
      <BottomSheet
        isOpen={showProfile}
        onClose={() => setShowProfile(false)}
        title="Perfil"
        height="large"
      >
        <div className="flex flex-col items-center mb-6">
          <Avatar size={80} showEditBadge />
          <h2 className="mt-4 text-[18px] font-semibold text-[#1a1a1a]">Maria Silva</h2>
          <p className="text-[13px] text-[#6b7280]">maria@email.com</p>
        </div>

        <div className="space-y-2">
          <button className="w-full flex items-center justify-between p-4 rounded-xl bg-white border border-[#f3f4f6] hover:border-[#e5e7eb] transition-colors">
            <span className="text-[14px] font-medium text-[#1a1a1a]">Editar dados pessoais</span>
            <ChevronRight size={16} className="text-[#9ca3af]" />
          </button>
          <button className="w-full flex items-center justify-between p-4 rounded-xl bg-white border border-[#f3f4f6] hover:border-[#e5e7eb] transition-colors">
            <span className="text-[14px] font-medium text-[#1a1a1a]">Alterar senha</span>
            <ChevronRight size={16} className="text-[#9ca3af]" />
          </button>
          <button className="w-full flex items-center justify-between p-4 rounded-xl bg-white border border-[#f3f4f6] hover:border-[#e5e7eb] transition-colors">
            <span className="text-[14px] font-medium text-[#1a1a1a]">Notificações</span>
            <ChevronRight size={16} className="text-[#9ca3af]" />
          </button>
          <button
            className="w-full flex items-center justify-between p-4 rounded-xl bg-[#fef2f2] border border-[#fecaca] hover:bg-[#fee2e2] transition-colors"
            onClick={() => navigate("/")}
          >
            <span className="text-[14px] font-medium text-[#ef4444]">Sair da conta</span>
            <ChevronRight size={16} className="text-[#ef4444]" />
          </button>
        </div>
      </BottomSheet>
    </div>
  );
}
