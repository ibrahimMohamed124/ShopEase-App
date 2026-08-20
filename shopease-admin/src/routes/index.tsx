import { createFileRoute, Link } from "@tanstack/react-router";
import { AlertTriangle, DollarSign, Package, ShoppingBag, Undo2, Users } from "lucide-react";
import { useMemo } from "react";
import {
  Area,
  AreaChart,
  Cell,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { AdminShell } from "@/components/admin/AdminShell";
import { Card, CardHeader, OrderStatusChip, currency, formatDate } from "@/components/admin/ui";
import { useAdminStore } from "@/lib/store";
import type { OrderStatus } from "@/lib/types";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Dashboard — ShopEase Admin" },
      { name: "description", content: "Revenue, orders, stock and returns overview for ShopEase." },
      { property: "og:title", content: "Dashboard — ShopEase Admin" },
      {
        property: "og:description",
        content: "Revenue, orders, stock and returns overview for ShopEase.",
      },
    ],
  }),
  component: DashboardPage,
});

const statusColors: Record<OrderStatus, string> = {
  processing: "var(--muted-foreground)",
  shipped: "var(--secondary)",
  delivered: "var(--success)",
  cancelled: "var(--destructive)",
};

function DashboardPage() {
  const { orders, products, users, returns } = useAdminStore();

  const revenue = orders
    .filter((o) => o.status !== "cancelled")
    .reduce((sum, o) => sum + o.total, 0);
  const pendingReturns = returns.filter((r) => r.status === "inReview").length;

  const revenueSeries = useMemo(() => {
    const days: { day: string; revenue: number }[] = [];
    for (let i = 29; i >= 0; i--) {
      const d = new Date("2026-08-20T12:00:00Z");
      d.setDate(d.getDate() - i);
      const key = d.toISOString().slice(0, 10);
      const total = orders
        .filter((o) => o.status !== "cancelled" && o.date.slice(0, 10) === key)
        .reduce((sum, o) => sum + o.total, 0);
      days.push({
        day: d.toLocaleDateString("en-US", { day: "2-digit", month: "short" }),
        revenue: Number(total.toFixed(2)),
      });
    }
    return days;
  }, [orders]);

  const statusData = (["processing", "shipped", "delivered", "cancelled"] as OrderStatus[]).map(
    (status) => ({
      name: status,
      value: orders.filter((o) => o.status === status).length,
    }),
  );

  const recent = [...orders].sort((a, b) => b.date.localeCompare(a.date)).slice(0, 10);
  const lowStock = products.filter((p) => !p.inStock);

  const kpis = [
    { label: "Total revenue", value: currency(revenue), icon: DollarSign, tone: "text-primary" },
    { label: "Total orders", value: String(orders.length), icon: ShoppingBag, tone: "text-secondary" },
    { label: "Total products", value: String(products.length), icon: Package, tone: "text-success" },
    { label: "Total users", value: String(users.length), icon: Users, tone: "text-star" },
    {
      label: "Pending returns",
      value: String(pendingReturns),
      icon: Undo2,
      tone: "text-destructive",
    },
  ];

  return (
    <AdminShell title="Dashboard" subtitle="Store performance at a glance">
      <div className="grid grid-cols-5 gap-5">
        {kpis.map((kpi) => {
          const Icon = kpi.icon;
          return (
            <Card key={kpi.label} className="p-6">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold text-muted-foreground">{kpi.label}</span>
                <Icon className={`size-4.5 ${kpi.tone}`} />
              </div>
              <p className="mt-4 text-2xl font-bold tracking-tight">{kpi.value}</p>
            </Card>
          );
        })}
      </div>

      <div className="mt-6 grid grid-cols-3 gap-6">
        <Card className="col-span-2">
          <CardHeader title="Revenue" subtitle="Last 30 days" />
          <div className="h-72 p-6">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={revenueSeries}>
                <defs>
                  <linearGradient id="rev" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="var(--primary)" stopOpacity={0.25} />
                    <stop offset="100%" stopColor="var(--primary)" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <XAxis
                  dataKey="day"
                  tickLine={false}
                  axisLine={false}
                  interval={4}
                  tick={{ fontSize: 11, fill: "var(--muted-foreground)" }}
                />
                <YAxis
                  tickLine={false}
                  axisLine={false}
                  width={56}
                  tick={{ fontSize: 11, fill: "var(--muted-foreground)" }}
                />
                <Tooltip
                  contentStyle={{
                    borderRadius: 14,
                    border: "1px solid var(--border)",
                    fontSize: 12,
                  }}
                  formatter={(v: number) => currency(v)}
                />
                <Area
                  type="monotone"
                  dataKey="revenue"
                  stroke="var(--primary)"
                  strokeWidth={2.5}
                  fill="url(#rev)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </Card>

        <Card>
          <CardHeader title="Orders by status" subtitle="All time" />
          <div className="h-72 p-6">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={statusData}
                  dataKey="value"
                  nameKey="name"
                  innerRadius={55}
                  outerRadius={85}
                  paddingAngle={3}
                  stroke="none"
                >
                  {statusData.map((entry) => (
                    <Cell key={entry.name} fill={statusColors[entry.name as OrderStatus]} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{ borderRadius: 14, border: "1px solid var(--border)", fontSize: 12 }}
                />
              </PieChart>
            </ResponsiveContainer>
            <div className="-mt-4 flex flex-wrap justify-center gap-3">
              {statusData.map((s) => (
                <span key={s.name} className="flex items-center gap-2 text-xs text-muted-foreground">
                  <span
                    className="size-2.5 rounded-full"
                    style={{ background: statusColors[s.name as OrderStatus] }}
                  />
                  {s.name} ({s.value})
                </span>
              ))}
            </div>
          </div>
        </Card>
      </div>

      <div className="mt-6 grid grid-cols-3 gap-6">
        <Card className="col-span-2 overflow-hidden">
          <CardHeader
            title="Recent orders"
            subtitle="Last 10 orders"
            action={
              <Link to="/orders" className="se-btn se-btn-outline se-btn-sm">
                View all
              </Link>
            }
          />
          <table className="w-full">
            <thead className="bg-muted/60">
              <tr>
                <th className="se-th">Order</th>
                <th className="se-th">Date</th>
                <th className="se-th">Customer</th>
                <th className="se-th">Total</th>
                <th className="se-th">Status</th>
              </tr>
            </thead>
            <tbody>
              {recent.map((o) => (
                <tr key={o.id} className="border-t border-border">
                  <td className="se-td font-semibold">
                    <Link to="/orders/$orderId" params={{ orderId: o.id }} className="hover:text-primary">
                      {o.id}
                    </Link>
                  </td>
                  <td className="se-td text-muted-foreground">{formatDate(o.date)}</td>
                  <td className="se-td">{o.customerName}</td>
                  <td className="se-td font-semibold">{currency(o.total)}</td>
                  <td className="se-td">
                    <OrderStatusChip status={o.status} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </Card>

        <Card className="overflow-hidden">
          <CardHeader title="Low stock" subtitle={`${lowStock.length} products out of stock`} />
          <div className="divide-y divide-border">
            {lowStock.map((p) => (
              <div key={p.id} className="flex items-center gap-3 px-6 py-4">
                <img src={p.imageUrl} alt={p.name} className="size-10 rounded-xl object-cover" />
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium">{p.name}</p>
                  <p className="text-xs text-muted-foreground">{currency(p.price)}</p>
                </div>
                <AlertTriangle className="size-4 text-destructive" />
              </div>
            ))}
            {lowStock.length === 0 ? (
              <p className="px-6 py-10 text-center text-sm text-muted-foreground">
                Everything is in stock.
              </p>
            ) : null}
          </div>
        </Card>
      </div>
    </AdminShell>
  );
}
