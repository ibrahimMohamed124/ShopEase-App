import { createFileRoute, Link } from "@tanstack/react-router";
import { ArrowLeft, CheckCircle2, Circle } from "lucide-react";
import { toast } from "sonner";
import { AdminShell } from "@/components/admin/AdminShell";
import { Card, CardHeader, OrderStatusChip, currency, formatDate } from "@/components/admin/ui";
import { paymentMethodLabels } from "@/lib/mock-data";
import { useAdminStore } from "@/lib/store";
import type { OrderStatus } from "@/lib/types";

export const Route = createFileRoute("/orders/$orderId")({
  head: () => ({
    meta: [
      { title: "Order detail — ShopEase Admin" },
      { name: "description", content: "Review order items, shipping and status history." },
      { property: "og:title", content: "Order detail — ShopEase Admin" },
      { property: "og:description", content: "Review order items, shipping and status history." },
    ],
  }),
  component: OrderDetailPage,
});

const flow: OrderStatus[] = ["processing", "shipped", "delivered"];

function OrderDetailPage() {
  const { orderId } = Route.useParams();
  const { orders, setOrderStatus } = useAdminStore();
  const order = orders.find((o) => o.id === orderId);

  if (!order) {
    return (
      <AdminShell title="Order not found">
        <Card className="p-10 text-center text-sm text-muted-foreground">
          We couldn&apos;t find order {orderId}.
          <div className="mt-5">
            <Link to="/orders" className="se-btn se-btn-outline se-btn-sm">
              Back to orders
            </Link>
          </div>
        </Card>
      </AdminShell>
    );
  }

  const nextStatus =
    order.status === "processing" ? "shipped" : order.status === "shipped" ? "delivered" : null;

  return (
    <AdminShell
      title={`Order ${order.id}`}
      subtitle={`Placed ${formatDate(order.date)} by ${order.customerName}`}
      actions={
        <div className="flex items-center gap-3">
          {nextStatus ? (
            <button
              className="se-btn se-btn-primary se-btn-sm"
              onClick={() => {
                setOrderStatus(order.id, nextStatus);
                toast.success(`Order marked as ${nextStatus}`);
              }}
            >
              Mark as {nextStatus}
            </button>
          ) : null}
          {order.status !== "cancelled" && order.status !== "delivered" ? (
            <button
              className="se-btn se-btn-outline se-btn-sm text-destructive"
              onClick={() => {
                setOrderStatus(order.id, "cancelled");
                toast.success("Order cancelled");
              }}
            >
              Cancel order
            </button>
          ) : null}
        </div>
      }
    >
      <div className="mb-5">
        <Link to="/orders" className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground">
          <ArrowLeft className="size-4" /> Back to orders
        </Link>
      </div>

      <div className="grid grid-cols-3 gap-6">
        <Card className="col-span-2 overflow-hidden">
          <CardHeader
            title="Items"
            subtitle={`${order.items.length} line items`}
            action={<OrderStatusChip status={order.status} />}
          />
          <div className="divide-y divide-border">
            {order.items.map((item) => (
              <div key={item.productId} className="flex items-center gap-4 px-6 py-4">
                <img src={item.imageUrl} alt={item.name} className="size-14 rounded-2xl object-cover" />
                <div className="flex-1">
                  <p className="text-sm font-medium">{item.name}</p>
                  <p className="text-xs text-muted-foreground">
                    {currency(item.price)} × {item.quantity}
                  </p>
                </div>
                <p className="text-sm font-semibold">{currency(item.price * item.quantity)}</p>
              </div>
            ))}
          </div>
          <div className="flex items-center justify-between border-t border-border px-6 py-5">
            <span className="text-sm font-semibold text-muted-foreground">Order total</span>
            <span className="text-lg font-bold">{currency(order.total)}</span>
          </div>
        </Card>

        <div className="space-y-6">
          <Card>
            <CardHeader title="Shipping & payment" />
            <dl className="space-y-4 p-6 text-sm">
              <div>
                <dt className="text-xs font-semibold text-muted-foreground">Customer</dt>
                <dd className="mt-1">{order.customerName}</dd>
              </div>
              <div>
                <dt className="text-xs font-semibold text-muted-foreground">Shipping address</dt>
                <dd className="mt-1">{order.shippingAddress}</dd>
              </div>
              <div>
                <dt className="text-xs font-semibold text-muted-foreground">Payment method</dt>
                <dd className="mt-1">
                  {order.paymentMethod ? paymentMethodLabels[order.paymentMethod.type] : "—"}
                  {order.paymentMethod?.lastFour ? ` •••• ${order.paymentMethod.lastFour}` : ""}
                </dd>
              </div>
              <div>
                <dt className="text-xs font-semibold text-muted-foreground">
                  {order.deliveredDate ? "Delivered" : "Estimated delivery"}
                </dt>
                <dd className="mt-1">
                  {formatDate(order.deliveredDate ?? order.estimatedDelivery ?? order.date)}
                </dd>
              </div>
            </dl>
          </Card>

          <Card>
            <CardHeader title="Status history" />
            <ol className="space-y-5 p-6">
              {(order.history ?? []).map((h, i) => (
                <li key={`${h.status}-${i}`} className="flex items-start gap-3">
                  <CheckCircle2 className="mt-0.5 size-4 text-success" />
                  <div>
                    <p className="text-sm font-medium capitalize">{h.status}</p>
                    <p className="text-xs text-muted-foreground">{formatDate(h.date)}</p>
                  </div>
                </li>
              ))}
              {order.status !== "cancelled"
                ? flow
                    .filter((s) => !(order.history ?? []).some((h) => h.status === s))
                    .map((s) => (
                      <li key={s} className="flex items-start gap-3 opacity-60">
                        <Circle className="mt-0.5 size-4 text-muted-foreground" />
                        <p className="text-sm font-medium capitalize">{s}</p>
                      </li>
                    ))
                : null}
            </ol>
          </Card>
        </div>
      </div>
    </AdminShell>
  );
}