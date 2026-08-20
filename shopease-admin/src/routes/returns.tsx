import { createFileRoute } from "@tanstack/react-router";
import { Search } from "lucide-react";
import { useMemo, useState } from "react";
import { AdminShell } from "@/components/admin/AdminShell";
import {
  Card,
  ConfirmDialog,
  EmptyState,
  ReturnStatusChip,
  currency,
  formatDate,
} from "@/components/admin/ui";
import { useAdminStore } from "@/lib/store";
import type { ReturnStatus } from "@/lib/types";

export const Route = createFileRoute("/returns")({
  head: () => ({
    meta: [
      { title: "Returns — ShopEase Admin" },
      { name: "description", content: "Review, refund or reject ShopEase return requests." },
      { property: "og:title", content: "Returns — ShopEase Admin" },
      {
        property: "og:description",
        content: "Review, refund or reject ShopEase return requests.",
      },
    ],
  }),
  component: ReturnsPage,
});

function ReturnsPage() {
  const { returns, setReturnStatus } = useAdminStore();
  const [query, setQuery] = useState("");
  const [status, setStatus] = useState("all");
  const [pending, setPending] = useState<{ id: string; next: ReturnStatus } | null>(null);

  const filtered = useMemo(
    () =>
      [...returns]
        .sort((a, b) => b.requestedDate.localeCompare(a.requestedDate))
        .filter((r) => {
          const q = query.toLowerCase();
          const matches =
            r.id.toLowerCase().includes(q) ||
            r.orderId.toLowerCase().includes(q) ||
            r.productName.toLowerCase().includes(q);
          return matches && (status === "all" || r.status === status);
        }),
    [returns, query, status],
  );

  const inReview = returns.filter((r) => r.status === "inReview").length;

  return (
    <AdminShell title="Returns" subtitle={`${inReview} awaiting review of ${returns.length} total`}>
      <Card className="overflow-hidden">
        <div className="flex items-center gap-4 border-b border-border px-6 py-5">
          <div className="relative w-80">
            <Search className="absolute left-4 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
            <input
              className="se-input pl-11"
              placeholder="Search return, order or product…"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
          <select
            className="se-input w-48"
            value={status}
            onChange={(e) => setStatus(e.target.value)}
          >
            <option value="all">All statuses</option>
            <option value="inReview">In review</option>
            <option value="refunded">Refunded</option>
            <option value="rejected">Rejected</option>
          </select>
        </div>
        <table className="w-full">
          <thead className="bg-muted/60">
            <tr>
              <th className="se-th">Return ID</th>
              <th className="se-th">Order</th>
              <th className="se-th">Product</th>
              <th className="se-th">Requested</th>
              <th className="se-th">Reason</th>
              <th className="se-th">Refund</th>
              <th className="se-th">Status</th>
              <th className="se-th text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((r) => (
              <tr key={r.id} className="border-t border-border align-top">
                <td className="se-td font-semibold">{r.id}</td>
                <td className="se-td text-muted-foreground">{r.orderId}</td>
                <td className="se-td max-w-64">{r.productName}</td>
                <td className="se-td text-muted-foreground">{formatDate(r.requestedDate)}</td>
                <td className="se-td max-w-72 text-muted-foreground">{r.reason ?? "—"}</td>
                <td className="se-td font-semibold">{currency(r.refundAmount)}</td>
                <td className="se-td">
                  <ReturnStatusChip status={r.status} />
                </td>
                <td className="se-td text-right">
                  {r.status === "inReview" ? (
                    <div className="flex justify-end gap-2">
                      <button
                        className="se-btn se-btn-primary se-btn-sm"
                        onClick={() => setPending({ id: r.id, next: "refunded" })}
                      >
                        Approve refund
                      </button>
                      <button
                        className="se-btn se-btn-outline se-btn-sm"
                        onClick={() => setPending({ id: r.id, next: "rejected" })}
                      >
                        Reject
                      </button>
                    </div>
                  ) : (
                    <span className="text-xs text-muted-foreground">Resolved</span>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 ? <EmptyState message="No return requests match your filters." /> : null}
      </Card>

      <ConfirmDialog
        open={pending !== null}
        title={pending?.next === "refunded" ? "Approve refund" : "Reject return"}
        message={
          pending?.next === "refunded"
            ? "This marks the return as refunded and notifies the customer."
            : "This rejects the return request. The customer keeps the item and no refund is issued."
        }
        confirmLabel={pending?.next === "refunded" ? "Mark refunded" : "Reject return"}
        onCancel={() => setPending(null)}
        onConfirm={() => {
          if (pending) setReturnStatus(pending.id, pending.next);
          setPending(null);
        }}
      />
    </AdminShell>
  );
}