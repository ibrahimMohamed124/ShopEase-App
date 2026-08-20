import { createFileRoute, Link } from "@tanstack/react-router";
import { Search } from "lucide-react";
import { useMemo, useState } from "react";
import { AdminShell } from "@/components/admin/AdminShell";
import { Card, EmptyState, OrderStatusChip, currency, formatDate } from "@/components/admin/ui";
import { paymentMethodLabels } from "@/lib/mock-data";
import { useAdminStore } from "@/lib/store";

export const Route = createFileRoute("/orders/")({
  head: () => ({
    meta: [
      { title: "Orders — ShopEase Admin" },
      { name: "description", content: "Track and update ShopEase customer orders." },
      { property: "og:title", content: "Orders — ShopEase Admin" },
      { property: "og:description", content: "Track and update ShopEase customer orders." },
    ],
  }),
  component: OrdersPage,
});

function OrdersPage() {
  const { orders } = useAdminStore();
  const [query, setQuery] = useState("");
  const [status, setStatus] = useState("all");
  const [payment, setPayment] = useState("all");

  const filtered = useMemo(
    () =>
      [...orders]
        .sort((a, b) => b.date.localeCompare(a.date))
        .filter((o) => {
          const q = query.toLowerCase();
          const matches =
            o.id.toLowerCase().includes(q) || (o.customerName ?? "").toLowerCase().includes(q);
          const matchesStatus = status === "all" || o.status === status;
          const matchesPayment = payment === "all" || o.paymentMethod?.type === payment;
          return matches && matchesStatus && matchesPayment;
        }),
    [orders, query, status, payment],
  );

  return (
    <AdminShell title="Orders" subtitle={`${orders.length} orders total`}>
      <Card className="overflow-hidden">
        <div className="flex items-center gap-4 border-b border-border px-6 py-5">
          <div className="relative w-80">
            <Search className="absolute left-4 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
            <input
              className="se-input pl-11"
              placeholder="Search by order ID or customer…"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
          <select className="se-input w-48" value={status} onChange={(e) => setStatus(e.target.value)}>
            <option value="all">All statuses</option>
            <option value="processing">Processing</option>
            <option value="shipped">Shipped</option>
            <option value="delivered">Delivered</option>
            <option value="cancelled">Cancelled</option>
          </select>
          <select className="se-input w-56" value={payment} onChange={(e) => setPayment(e.target.value)}>
            <option value="all">All payment methods</option>
            {Object.entries(paymentMethodLabels).map(([key, label]) => (
              <option key={key} value={key}>
                {label}
              </option>
            ))}
          </select>
        </div>
        <table className="w-full">
          <thead className="bg-muted/60">
            <tr>
              <th className="se-th">Order ID</th>
              <th className="se-th">Date</th>
              <th className="se-th">Customer</th>
              <th className="se-th">Items</th>
              <th className="se-th">Total</th>
              <th className="se-th">Payment</th>
              <th className="se-th">Status</th>
              <th className="se-th text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((o) => (
              <tr key={o.id} className="border-t border-border">
                <td className="se-td font-semibold">{o.id}</td>
                <td className="se-td text-muted-foreground">{formatDate(o.date)}</td>
                <td className="se-td">{o.customerName}</td>
                <td className="se-td text-muted-foreground">
                  {o.items.reduce((n, i) => n + i.quantity, 0)}
                </td>
                <td className="se-td font-semibold">{currency(o.total)}</td>
                <td className="se-td text-muted-foreground">
                  {o.paymentMethod ? paymentMethodLabels[o.paymentMethod.type] : "—"}
                </td>
                <td className="se-td">
                  <OrderStatusChip status={o.status} />
                </td>
                <td className="se-td text-right">
                  <Link
                    to="/orders/$orderId"
                    params={{ orderId: o.id }}
                    className="se-btn se-btn-outline se-btn-sm"
                  >
                    View
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 ? <EmptyState message="No orders match your filters." /> : null}
      </Card>
    </AdminShell>
  );
}