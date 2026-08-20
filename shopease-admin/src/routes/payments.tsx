import { createFileRoute } from "@tanstack/react-router";
import { CreditCard, Wallet } from "lucide-react";
import { useMemo } from "react";
import { AdminShell } from "@/components/admin/AdminShell";
import { Card, CardHeader, Chip, currency } from "@/components/admin/ui";
import { paymentMethodLabels } from "@/lib/mock-data";
import { useAdminStore } from "@/lib/store";
import type { PaymentMethodType } from "@/lib/types";

export const Route = createFileRoute("/payments")({
  head: () => ({
    meta: [
      { title: "Payment methods — ShopEase Admin" },
      {
        name: "description",
        content: "Reference overview of payment methods used across ShopEase orders.",
      },
      { property: "og:title", content: "Payment methods — ShopEase Admin" },
      {
        property: "og:description",
        content: "Reference overview of payment methods used across ShopEase orders.",
      },
    ],
  }),
  component: PaymentsPage,
});

const types = Object.keys(paymentMethodLabels) as PaymentMethodType[];

function PaymentsPage() {
  const { orders, paymentMethods } = useAdminStore();

  const stats = useMemo(() => {
    const paid = orders.filter((o) => o.status !== "cancelled");
    const total = paid.reduce((sum, o) => sum + o.total, 0);
    return types.map((type) => {
      const own = paid.filter((o) => o.paymentMethod?.type === type);
      const volume = own.reduce((sum, o) => sum + o.total, 0);
      return {
        type,
        orders: own.length,
        volume,
        share: total > 0 ? (volume / total) * 100 : 0,
        stored: paymentMethods.filter((m) => m.type === type).length,
      };
    });
  }, [orders, paymentMethods]);

  return (
    <AdminShell
      title="Payment methods"
      subtitle="Read-only reference of the payment types customers use"
    >
      <div className="grid grid-cols-5 gap-4">
        {stats.map((s) => (
          <Card key={s.type} className="px-5 py-5">
            <div className="flex size-9 items-center justify-center rounded-xl bg-muted text-secondary">
              {s.type === "cashOnDelivery" ? (
                <Wallet className="size-4.5" />
              ) : (
                <CreditCard className="size-4.5" />
              )}
            </div>
            <p className="mt-4 text-sm font-semibold">{paymentMethodLabels[s.type]}</p>
            <p className="mt-1 text-xl font-bold">{currency(s.volume)}</p>
            <p className="mt-1 text-xs text-muted-foreground">
              {s.orders} orders · {s.share.toFixed(1)}% of volume
            </p>
          </Card>
        ))}
      </div>

      <Card className="mt-6 overflow-hidden">
        <CardHeader
          title="Methods in use"
          subtitle="Aggregated from customer orders — managed inside the mobile app"
        />
        <table className="w-full">
          <thead className="bg-muted/60">
            <tr>
              <th className="se-th">Method</th>
              <th className="se-th">Orders</th>
              <th className="se-th">Volume</th>
              <th className="se-th">Share</th>
              <th className="se-th">Stored cards</th>
            </tr>
          </thead>
          <tbody>
            {stats.map((s) => (
              <tr key={s.type} className="border-t border-border">
                <td className="se-td font-medium">{paymentMethodLabels[s.type]}</td>
                <td className="se-td text-muted-foreground">{s.orders}</td>
                <td className="se-td font-semibold">{currency(s.volume)}</td>
                <td className="se-td">
                  <Chip tone={s.share > 25 ? "secondary" : "muted"}>{s.share.toFixed(1)}%</Chip>
                </td>
                <td className="se-td text-muted-foreground">
                  {s.type === "cashOnDelivery" ? "—" : s.stored}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </Card>

      <Card className="mt-6 overflow-hidden">
        <CardHeader title="Saved payment instruments" subtitle="Reference only, no edits from admin" />
        <table className="w-full">
          <thead className="bg-muted/60">
            <tr>
              <th className="se-th">Type</th>
              <th className="se-th">Holder</th>
              <th className="se-th">Card</th>
              <th className="se-th">Expiry</th>
              <th className="se-th">Default</th>
            </tr>
          </thead>
          <tbody>
            {paymentMethods.map((m) => (
              <tr key={m.id} className="border-t border-border">
                <td className="se-td font-medium">{paymentMethodLabels[m.type]}</td>
                <td className="se-td text-muted-foreground">{m.holderName ?? "—"}</td>
                <td className="se-td text-muted-foreground">
                  {m.lastFour ? `•••• ${m.lastFour}` : "—"}
                </td>
                <td className="se-td text-muted-foreground">{m.expiry ?? "—"}</td>
                <td className="se-td">
                  {m.isDefault ? <Chip tone="primary">Default</Chip> : <span className="text-muted-foreground">—</span>}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </Card>
    </AdminShell>
  );
}