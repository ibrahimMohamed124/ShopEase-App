import { createFileRoute, Link } from "@tanstack/react-router";
import { Search } from "lucide-react";
import { useMemo, useState } from "react";
import { AdminShell } from "@/components/admin/AdminShell";
import { Card, EmptyState, currency } from "@/components/admin/ui";
import { useAdminStore } from "@/lib/store";

export const Route = createFileRoute("/users/")({
  head: () => ({
    meta: [
      { title: "Users — ShopEase Admin" },
      { name: "description", content: "Browse ShopEase customer accounts and their order history." },
      { property: "og:title", content: "Users — ShopEase Admin" },
      {
        property: "og:description",
        content: "Browse ShopEase customer accounts and their order history.",
      },
    ],
  }),
  component: UsersPage,
});

function UsersPage() {
  const { users, orders } = useAdminStore();
  const [query, setQuery] = useState("");

  const rows = useMemo(() => {
    const q = query.toLowerCase();
    return users
      .filter(
        (u) =>
          u.name.toLowerCase().includes(q) ||
          u.email.toLowerCase().includes(q) ||
          u.phone.toLowerCase().includes(q),
      )
      .map((u) => {
        const own = orders.filter((o) => o.userId === u.id);
        return {
          user: u,
          orderCount: own.length,
          spent: own.reduce((sum, o) => (o.status === "cancelled" ? sum : sum + o.total), 0),
        };
      });
  }, [users, orders, query]);

  return (
    <AdminShell title="Users" subtitle={`${users.length} registered customers`}>
      <Card className="overflow-hidden">
        <div className="flex items-center gap-4 border-b border-border px-6 py-5">
          <div className="relative w-80">
            <Search className="absolute left-4 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
            <input
              className="se-input pl-11"
              placeholder="Search name, email or phone…"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
        </div>
        <table className="w-full">
          <thead className="bg-muted/60">
            <tr>
              <th className="se-th">Customer</th>
              <th className="se-th">Email</th>
              <th className="se-th">Phone</th>
              <th className="se-th">Address</th>
              <th className="se-th">Orders</th>
              <th className="se-th">Lifetime value</th>
              <th className="se-th text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {rows.map(({ user, orderCount, spent }) => (
              <tr key={user.id} className="border-t border-border">
                <td className="se-td">
                  <div className="flex items-center gap-3">
                    <img
                      src={user.avatarUrl ?? `https://picsum.photos/seed/${user.id}/72/72`}
                      alt={user.name}
                      className="size-9 rounded-full object-cover"
                    />
                    <span className="font-medium">{user.name}</span>
                  </div>
                </td>
                <td className="se-td text-muted-foreground">{user.email}</td>
                <td className="se-td text-muted-foreground">{user.phone}</td>
                <td className="se-td max-w-72 text-muted-foreground">{user.address}</td>
                <td className="se-td text-muted-foreground">{orderCount}</td>
                <td className="se-td font-semibold">{currency(spent)}</td>
                <td className="se-td text-right">
                  <Link
                    to="/users/$userId"
                    params={{ userId: user.id }}
                    className="se-btn se-btn-outline se-btn-sm"
                  >
                    View
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {rows.length === 0 ? <EmptyState message="No users match your search." /> : null}
      </Card>
    </AdminShell>
  );
}