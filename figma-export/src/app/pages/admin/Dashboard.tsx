import { useState } from "react";
import {
  Bell, Calendar, Users, DollarSign, BarChart3,
  Plus, Pencil, Trash2, ChevronRight, ListChecks
} from "lucide-react";
import { motion } from "motion/react";
import Avatar from "../../components/Avatar";
import Card from "../../components/Card";
import Badge from "../../components/Badge";
import Button from "../../components/Button";
import BottomSheet from "../../components/BottomSheet";
import Input from "../../components/Input";

const debts = [
  {
    id: 1,
    clientName: "Maria Silva",
    service: "Corte de Cabelo",
    date: "10 Mar 2026",
    amount: 150.0,
  },
  {
    id: 2,
    clientName: "João Santos",
    service: "Manicure",
    date: "12 Mar 2026",
    amount: 80.0,
  },
];

const todayAppointments = [
  {
    id: 1,
    clientName: "Maria Silva",
    service: "Corte de Cabelo",
    time: "14:00",
    status: "confirmed" as const,
  },
  {
    id: 2,
    clientName: "João Santos",
    service: "Manicure",
    time: "15:30",
    status: "pending" as const,
  },
];

const services = [
  { id: 1, name: "Corte de Cabelo", duration: "45min", price: 50.0 },
  { id: 2, name: "Manicure", duration: "30min", price: 40.0 },
  { id: 3, name: "Massagem", duration: "60min", price: 120.0 },
];

export default function AdminDashboard() {
  const [showDebtDetail, setShowDebtDetail] = useState(false);
  const [showServiceForm, setShowServiceForm] = useState(false);
  const [showServicesSheet, setShowServicesSheet] = useState(false);
  const [showClientsSheet, setShowClientsSheet] = useState(false);
  const [showScheduleSheet, setShowScheduleSheet] = useState(false);
  const [selectedDebt, setSelectedDebt] = useState<(typeof debts)[0] | null>(null);
  const [editingService, setEditingService] = useState<(typeof services)[0] | null>(null);

  const handleDebtClick = (debt: (typeof debts)[0]) => {
    setSelectedDebt(debt);
    setShowDebtDetail(true);
  };

  const handleMarkAsPaid = () => {
    setShowDebtDetail(false);
    alert("Débito marcado como pago!");
  };

  const handleEditService = (service: (typeof services)[0]) => {
    setEditingService(service);
    setShowServiceForm(true);
  };

  const handleSaveService = (e: React.FormEvent) => {
    e.preventDefault();
    setShowServiceForm(false);
    setEditingService(null);
    alert("Serviço salvo!");
  };

  return (
    <div className="min-h-screen bg-[#f5f6f8] pb-6">
      {/* Header */}
      <div className="px-6 pt-12 pb-6">
        <div className="mb-2 flex items-start justify-between">
          <div>
            <p className="text-[12px] leading-[16px] text-[#9ca3af] mb-1">
              Bem-vindo de volta
            </p>
            <h1 className="text-[28px] font-bold leading-[36px] text-[#1a1a1a]">
              Admin João
            </h1>
          </div>
          <button className="relative rounded-xl p-2.5 hover:bg-white transition-colors">
            <Bell className="text-[#1a1a1a]" size={22} strokeWidth={1.5} />
            <span className="absolute right-2 top-2 h-2 w-2 rounded-full bg-[#ef4444]" />
          </button>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="px-6 mb-6">
        <div className="grid grid-cols-4 gap-2">
          <motion.button
            whileTap={{ scale: 0.97 }}
            onClick={() => setShowScheduleSheet(true)}
            className="flex flex-col items-center justify-center rounded-2xl bg-white p-4 shadow-sm border border-[#f3f4f6] hover:shadow-md transition-all"
          >
            <div className="mb-2 flex h-11 w-11 items-center justify-center rounded-xl bg-[#f3f4f6]">
              <Calendar className="text-[#1a1a1a]" size={18} strokeWidth={1.5} />
            </div>
            <span className="text-[11px] font-medium text-[#1a1a1a] text-center">Agenda</span>
          </motion.button>

          <motion.button
            whileTap={{ scale: 0.97 }}
            onClick={() => setShowClientsSheet(true)}
            className="flex flex-col items-center justify-center rounded-2xl bg-white p-4 shadow-sm border border-[#f3f4f6] hover:shadow-md transition-all"
          >
            <div className="mb-2 flex h-11 w-11 items-center justify-center rounded-xl bg-[#f3f4f6]">
              <Users className="text-[#1a1a1a]" size={18} strokeWidth={1.5} />
            </div>
            <span className="text-[11px] font-medium text-[#1a1a1a] text-center">Clientes</span>
          </motion.button>

          <motion.button
            whileTap={{ scale: 0.97 }}
            onClick={() => setShowServicesSheet(true)}
            className="flex flex-col items-center justify-center rounded-2xl bg-white p-4 shadow-sm border border-[#f3f4f6] hover:shadow-md transition-all"
          >
            <div className="mb-2 flex h-11 w-11 items-center justify-center rounded-xl bg-[#f3f4f6]">
              <ListChecks className="text-[#1a1a1a]" size={18} strokeWidth={1.5} />
            </div>
            <span className="text-[11px] font-medium text-[#1a1a1a] text-center">Serviços</span>
          </motion.button>

          <motion.button
            whileTap={{ scale: 0.97 }}
            className="flex flex-col items-center justify-center rounded-2xl bg-white p-4 shadow-sm border border-[#f3f4f6] hover:shadow-md transition-all"
          >
            <div className="mb-2 flex h-11 w-11 items-center justify-center rounded-xl bg-[#f3f4f6]">
              <BarChart3 className="text-[#1a1a1a]" size={18} strokeWidth={1.5} />
            </div>
            <span className="text-[11px] font-medium text-[#1a1a1a] text-center">Relatórios</span>
          </motion.button>
        </div>
      </div>

      {/* Stats Cards - Bento Grid */}
      <div className="px-6 mb-6">
        <div className="grid grid-cols-2 gap-4">
          <Card className="!p-6">
            <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-[#f3f4f6] to-[#e5e7eb]">
              <Users className="text-[#1a1a1a]" size={22} strokeWidth={1.5} />
            </div>
            <p className="text-[12px] leading-[16px] text-[#9ca3af] mb-1">Clientes</p>
            <p className="text-[32px] font-bold leading-[40px] text-[#1a1a1a]">48</p>
          </Card>

          <Card className="!p-6">
            <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-[#d1fae5] to-[#a7f3d0]">
              <DollarSign className="text-[#059669]" size={22} strokeWidth={2} />
            </div>
            <p className="text-[12px] leading-[16px] text-[#9ca3af] mb-1">Receita (mês)</p>
            <p className="text-[32px] font-bold leading-[40px] text-[#1a1a1a]">8.5k</p>
          </Card>
        </div>
      </div>

      {/* Débitos Pendentes */}
      <div className="px-6 mb-6">
        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-[20px] font-semibold leading-[28px] text-[#1a1a1a]">
            Débitos Pendentes
          </h2>
          <button className="text-[13px] font-medium text-[#6b7280] hover:text-[#1a1a1a] flex items-center gap-1">
            Ver todos
            <ChevronRight size={14} />
          </button>
        </div>

        <div className="flex gap-3 overflow-x-auto pb-2 -mx-6 px-6">
          {debts.map((debt, index) => (
            <motion.div
              key={debt.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: index * 0.1 }}
            >
              <Card
                className="w-[160px] flex-shrink-0 cursor-pointer !p-4"
                onClick={() => handleDebtClick(debt)}
              >
                <div className="mb-3 flex items-center gap-2">
                  <Avatar size={32} />
                  <div className="flex-1 overflow-hidden">
                    <p className="truncate text-[13px] font-semibold text-[#1a1a1a]">
                      {debt.clientName.split(" ")[0]}
                    </p>
                  </div>
                </div>
                <p className="truncate text-[11px] text-[#9ca3af] mb-2">{debt.service}</p>
                <Badge variant="pending">Pendente</Badge>
                <p className="mt-3 text-[16px] font-bold text-[#1a1a1a]">
                  R$ {debt.amount.toFixed(2)}
                </p>
              </Card>
            </motion.div>
          ))}
        </div>
      </div>

      {/* Agendamentos de Hoje */}
      <div className="px-6">
        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-[20px] font-semibold leading-[28px] text-[#1a1a1a]">
            Hoje
          </h2>
          <button className="rounded-xl p-2 bg-[#f3f4f6] hover:bg-[#e5e7eb]">
            <Plus className="text-[#1a1a1a]" size={18} strokeWidth={2} />
          </button>
        </div>

        <div className="mb-3">
          <Badge variant="confirmed">Hoje, 20 de Abril</Badge>
        </div>

        <div className="grid gap-3">
          {todayAppointments.map((appointment, index) => (
            <motion.div
              key={appointment.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.1 }}
            >
              <Card className="!p-4">
                <div className="flex items-start gap-3">
                  <div
                    className={`h-full w-1 rounded-full ${
                      appointment.status === "confirmed" ? "bg-[#10b981]" : "bg-[#f59e0b]"
                    }`}
                  />

                  <div className="flex-1">
                    <div className="mb-1 flex items-start justify-between">
                      <div>
                        <h3 className="text-[15px] font-semibold text-[#1a1a1a]">
                          {appointment.service}
                        </h3>
                        <p className="text-[12px] text-[#9ca3af]">{appointment.clientName}</p>
                      </div>
                      <Badge variant={appointment.status}>
                        {appointment.status === "confirmed" ? "Confirmado" : "Pendente"}
                      </Badge>
                    </div>

                    <p className="text-[13px] font-medium text-[#6b7280] mt-2">
                      {appointment.time}
                    </p>
                  </div>
                </div>
              </Card>
            </motion.div>
          ))}
        </div>
      </div>

      {/* Services Bottom Sheet */}
      <BottomSheet
        isOpen={showServicesSheet}
        onClose={() => setShowServicesSheet(false)}
        title="Serviços"
        height="large"
      >
        <div className="mb-4">
          <Button
            variant="primary"
            small
            onClick={() => {
              setEditingService(null);
              setShowServiceForm(true);
            }}
            className="flex items-center gap-1"
          >
            <Plus size={16} />
            Novo Serviço
          </Button>
        </div>

        <div className="space-y-3">
          {services.map((service) => (
            <Card key={service.id} className="!p-4">
              <div className="flex items-start gap-3">
                <div className="flex-1">
                  <h3 className="text-[15px] font-semibold text-[#1a1a1a] mb-1">
                    {service.name}
                  </h3>
                  <p className="text-[12px] text-[#9ca3af] mb-2">Duração: {service.duration}</p>
                  <p className="text-[14px] font-bold text-[#1a1a1a]">
                    R$ {service.price.toFixed(2)}
                  </p>
                </div>

                <div className="flex gap-1">
                  <button
                    onClick={() => handleEditService(service)}
                    className="rounded-lg p-2 text-[#6b7280] hover:bg-[#f3f4f6]"
                  >
                    <Pencil size={16} />
                  </button>
                  <button className="rounded-lg p-2 text-[#ef4444] hover:bg-[#fef2f2]">
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      </BottomSheet>

      {/* Service Form Bottom Sheet */}
      <BottomSheet
        isOpen={showServiceForm}
        onClose={() => {
          setShowServiceForm(false);
          setEditingService(null);
        }}
        title={editingService ? "Editar Serviço" : "Novo Serviço"}
        height="large"
      >
        <form onSubmit={handleSaveService} className="flex flex-col gap-4">
          <Input
            label="Nome do Serviço"
            placeholder="Ex: Corte de Cabelo"
            defaultValue={editingService?.name}
            required
          />

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Duração (min)"
              type="number"
              placeholder="45"
              defaultValue={editingService?.duration.replace("min", "")}
              required
            />

            <Input
              label="Preço (R$)"
              type="number"
              step="0.01"
              placeholder="50.00"
              defaultValue={editingService?.price}
              required
            />
          </div>

          <Button variant="primary" fullWidth className="mt-4">
            Salvar Serviço
          </Button>
        </form>
      </BottomSheet>

      {/* Debt Detail Bottom Sheet */}
      <BottomSheet
        isOpen={showDebtDetail}
        onClose={() => setShowDebtDetail(false)}
        title=""
        height="medium"
      >
        {selectedDebt && (
          <div className="flex flex-col items-center">
            <Avatar size={56} />
            <h2 className="mt-3 text-center text-[20px] font-semibold text-[#1a1a1a]">
              {selectedDebt.clientName}
            </h2>
            <p className="mb-6 text-[12px] text-[#9ca3af]">Débito pendente</p>

            <div className="mb-6 w-full space-y-4">
              <div className="flex items-center justify-between">
                <p className="text-[12px] text-[#9ca3af]">Serviço</p>
                <p className="text-[14px] font-medium text-[#1a1a1a]">{selectedDebt.service}</p>
              </div>

              <div className="flex items-center justify-between">
                <p className="text-[12px] text-[#9ca3af]">Data</p>
                <p className="text-[14px] font-medium text-[#1a1a1a]">{selectedDebt.date}</p>
              </div>

              <div className="flex items-center justify-between">
                <p className="text-[12px] text-[#9ca3af]">Valor</p>
                <p className="text-[18px] font-bold text-[#1a1a1a]">
                  R$ {selectedDebt.amount.toFixed(2)}
                </p>
              </div>
            </div>

            <Button variant="primary" fullWidth onClick={handleMarkAsPaid}>
              Marcar como Pago
            </Button>

            <Button
              variant="ghost"
              fullWidth
              className="mt-2 !text-[#ef4444]"
              onClick={() => {
                setShowDebtDetail(false);
                alert("Cobrança cancelada!");
              }}
            >
              Cancelar Cobrança
            </Button>
          </div>
        )}
      </BottomSheet>

      {/* Clients Placeholder */}
      <BottomSheet
        isOpen={showClientsSheet}
        onClose={() => setShowClientsSheet(false)}
        title="Clientes"
        height="large"
      >
        <div className="text-center py-12 text-[#9ca3af]">
          <Users size={48} strokeWidth={1.5} className="mx-auto mb-3 opacity-30" />
          <p className="text-[14px]">Lista de clientes</p>
        </div>
      </BottomSheet>

      {/* Schedule Placeholder */}
      <BottomSheet
        isOpen={showScheduleSheet}
        onClose={() => setShowScheduleSheet(false)}
        title="Agenda"
        height="large"
      >
        <div className="text-center py-12 text-[#9ca3af]">
          <Calendar size={48} strokeWidth={1.5} className="mx-auto mb-3 opacity-30" />
          <p className="text-[14px]">Visualização da agenda</p>
        </div>
      </BottomSheet>
    </div>
  );
}
