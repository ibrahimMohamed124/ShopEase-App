import { createFileRoute, Link } from "@tanstack/react-router";
import { ArrowLeft, Mail, MapPin, Phone } from "lucide-react";
import { AdminShell } from "@/components/admin/AdminShell";
import {
  Card,
  CardHeader,
  EmptyState,
  OrderStatusChip,
  currency,
  formatDate,
} from "@/components/admin/ui";
import { paymentMethodLabels } from "@/lib/mock-data";
import { useAdminStore } from "@/lib/store";

export const Route = createFileRoute("/users/$userId")({
  head: () => ({
    meta: [
      { title: "Customer profile — ShopEase Admin" },
      { name: "description", content: "Customer profile details and full order history." },
      { property: "og:title", content: "Customer profile — ShopEase Admin" },
      {
        property: "og:description",
        content: "Customer profile details and full order history.",
      },
    ],
  }),
  component: UserDetailPage,
});

function UserDetailPage() {
  const { userId } = Route.useParams();
  const { users, orders } = useAdminStore();
  const user = users.find((u) => u.id === userId);

  if (!user) {
    return (
      <AdminShell title="Customer not found">
        <Card>
          <EmptyState message="This customer no longer exists." />
        </Card>
      </AdminShell>
    );
  }

  const own = [...orders]
    .filter((o) => o.userId === user.id)
    .sort((a, b) => b.date.localeCompare(a.date));
  const spent = own.reduce((sum, o) => (o.status === "cancelled" ? sum : sum + o.total), 0);

  return (
    <AdminShell title={user.name} subtitle={user.email}>
      <Link to="/users" className="se-btn se-btn-outline se-btn-sm mb-6">
        <ArrowLeft className="size-4" />
        Back to users
      </Link>

      <div className="grid grid-cols-[340px_1fr] gap-6">
        <Card>
          <div className="flex flex-col items-center gap-3 border-b border-border px-6 py-8">
            <img
              src={user.avatarUrl ?? `https://picsum.photos/seed/${user.id}/160/160`}
              alt={user.name}
              className="size-20 rounded-full object-cover"
            />
            <div className="text-center">
              <p className="text-base font-semibold">{user.name}</p>
              <p className="text-xs text-muted-foreground">Customer ID {user.id}</p>
            </div>
          </div>
          <div className="space-y-4 px-6 py-6 text-sm">
            <div className="flex items-start gap-3">
              <Mail className="mt-0.5 size-4 text-muted-foreground" />
              <span>{user.email}</span>
            </div>
            <div className="flex items-start gap-3">
              <Phone className="mt-0.5 size-4 text-muted-foreground" />
              <span>{user.phone}</span>
            </div>
            <div className="flex items-start gap-3">
              <MapPin className="mt-0.5 size-4 text-muted-foreground" />
              <span className="text-muted-foreground">{user.address}</span>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4 border-t border-border px-6 py-6">
            <div>
              <p className="text-xs font-semibold text-muted-foreground">Orders</p>
              <p className="mt-1 text-lg font-bold">{own.length}</p>
            </div>
            <div>
              <p className="text-xs font-semibold text-muted-foreground">Lifetime value</p>
              <p className="mt-1 text-lg font-bold">{currency(spent)}</p>
            </div>
          </div>
        </Card>

        <Card className="overflow-hidden">
          <CardHeader title="Order history" subtitle={`${own.length} orders placed`} />
          <table className="w-full">
            <thead className="bg-muted/60">
              <tr>
                <th className="se-th">Order ID</th>
                <th className="se-th">Date</th>
                <th className="se-th">Items</th>
                <th className="se-th">Total</th>
                <th className="se-th">Payment</th>
                <th className="se-th">Status</th>
                <th className="se-th text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {own.map((o) => (
                <tr key={o.id} className="border-t border-border">
                  <td className="se-td font-semibold">{o.id}</td>
                  <td className="se-td text-muted-foreground">{formatDate(o.date)}</td>
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
          {own.length === 0 ? <EmptyState message="This customer has no orders yet." /> : null}
        </Card>
      </div>
    </AdminShell>
  );
}