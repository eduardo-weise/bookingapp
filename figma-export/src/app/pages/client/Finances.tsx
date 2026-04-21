import { CreditCard, Calendar, TrendingUp } from "lucide-react";
import { motion } from "motion/react";
import Card from "../../components/Card";
import Button from "../../components/Button";
import Badge from "../../components/Badge";

const transactions = [
  {
    id: 1,
    service: "Corte de Cabelo",
    date: "10 Mar 2026",
    amount: 150.0,
    status: "pending" as const,
  },
  {
    id: 2,
    service: "Manicure",
    date: "25 Fev 2026",
    amount: 80.0,
    status: "paid" as const,
  },
  {
    id: 3,
    service: "Massagem",
    date: "15 Fev 2026",
    amount: 200.0,
    status: "paid" as const,
  },
];

export default function ClientFinances() {
  const totalPending = transactions
    .filter((t) => t.status === "pending")
    .reduce((sum, t) => sum + t.amount, 0);

  const totalPaid = transactions
    .filter((t) => t.status !== "pending")
    .reduce((sum, t) => sum + t.amount, 0);

  return (
    <div className="min-h-screen bg-[#f5f6f8] pb-6">
      <div className="px-6 pt-12 pb-6">
        <h1 className="text-[28px] font-bold leading-[36px] text-[#1a1a1a] mb-6">
          Finanças
        </h1>

        {/* Balance Cards */}
        <div className="grid gap-4 mb-6">
          {/* Pending Debt Card */}
          <Card className="!bg-gradient-to-br from-[#1a1a1a] to-[#2d2d2d] !border-0 !p-6">
            <div className="flex items-start justify-between mb-4">
              <div>
                <p className="text-[12px] leading-[16px] text-white/70 mb-2">Débito Pendente</p>
                <p className="text-[36px] font-bold leading-[44px] text-white">
                  R$ {totalPending.toFixed(2)}
                </p>
                <p className="text-[11px] leading-[16px] text-white/60 mt-1">
                  {transactions.filter((t) => t.status === "pending").length} serviço(s) pendente(s)
                </p>
              </div>
              <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-white/10">
                <CreditCard className="text-white" size={22} strokeWidth={1.5} />
              </div>
            </div>
            <Button
              variant="secondary"
              fullWidth
              className="!bg-white !text-[#1a1a1a] !border-0"
              onClick={() => alert("Processando pagamento...")}
            >
              Pagar Agora
            </Button>
          </Card>

          {/* Paid Card */}
          <Card className="!p-6">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-[12px] leading-[16px] text-[#9ca3af] mb-2">Total Pago</p>
                <p className="text-[28px] font-bold leading-[36px] text-[#10b981]">
                  R$ {totalPaid.toFixed(2)}
                </p>
              </div>
              <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-[#d1fae5]">
                <TrendingUp className="text-[#10b981]" size={22} strokeWidth={1.5} />
              </div>
            </div>
          </Card>
        </div>

        {/* Transaction History */}
        <h2 className="text-[20px] font-semibold leading-[28px] text-[#1a1a1a] mb-4">
          Histórico de Transações
        </h2>

        <div className="grid gap-3">
          {transactions.map((transaction, index) => (
            <motion.div
              key={transaction.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.1 }}
            >
              <Card className="!p-5">
                <div className="flex items-start gap-4">
                  <div
                    className={`flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-xl ${
                      transaction.status === "paid"
                        ? "bg-[#d1fae5]"
                        : "bg-[#fef3c7]"
                    }`}
                  >
                    <CreditCard
                      className={
                        transaction.status === "paid" ? "text-[#059669]" : "text-[#d97706]"
                      }
                      size={20}
                      strokeWidth={1.5}
                    />
                  </div>

                  <div className="flex-1">
                    <h3 className="text-[16px] font-semibold leading-[24px] text-[#1a1a1a] mb-1">
                      {transaction.service}
                    </h3>

                    <p className="flex items-center gap-1.5 text-[12px] text-[#9ca3af] mb-3">
                      <Calendar size={14} strokeWidth={1.5} />
                      {transaction.date}
                    </p>

                    <div className="flex items-center justify-between">
                      <p className="text-[18px] font-bold leading-[24px] text-[#1a1a1a]">
                        R$ {transaction.amount.toFixed(2)}
                      </p>

                      <Badge variant={transaction.status === "paid" ? "confirmed" : "pending"}>
                        {transaction.status === "paid" ? "Pago" : "Pendente"}
                      </Badge>
                    </div>
                  </div>
                </div>
              </Card>
            </motion.div>
          ))}
        </div>
      </div>
    </div>
  );
}
