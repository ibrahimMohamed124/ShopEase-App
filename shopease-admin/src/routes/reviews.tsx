import { createFileRoute } from "@tanstack/react-router";
import { Search, Trash2 } from "lucide-react";
import { useMemo, useState } from "react";
import { AdminShell } from "@/components/admin/AdminShell";
import {
  Card,
  Chip,
  ConfirmDialog,
  EmptyState,
  Stars,
  formatDate,
} from "@/components/admin/ui";
import { useAdminStore } from "@/lib/store";

export const Route = createFileRoute("/reviews")({
  head: () => ({
    meta: [
      { title: "Reviews — ShopEase Admin" },
      { name: "description", content: "Moderate customer product reviews across ShopEase." },
      { property: "og:title", content: "Reviews — ShopEase Admin" },
      {
        property: "og:description",
        content: "Moderate customer product reviews across ShopEase.",
      },
    ],
  }),
  component: ReviewsPage,
});

function ReviewsPage() {
  const { reviews, products, deleteReview } = useAdminStore();
  const [query, setQuery] = useState("");
  const [rating, setRating] = useState("all");
  const [toDelete, setToDelete] = useState<string | null>(null);

  const productName = (id: string) => products.find((p) => p.id === id)?.name ?? "Unknown product";

  const filtered = useMemo(
    () =>
      [...reviews]
        .sort((a, b) => b.date.localeCompare(a.date))
        .filter((r) => {
          const q = query.toLowerCase();
          const matches =
            r.name.toLowerCase().includes(q) ||
            r.text.toLowerCase().includes(q) ||
            productName(r.productId).toLowerCase().includes(q);
          return matches && (rating === "all" || r.rating === Number(rating));
        }),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [reviews, products, query, rating],
  );

  const average =
    reviews.length > 0 ? reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length : 0;

  return (
    <AdminShell
      title="Reviews"
      subtitle={`${reviews.length} reviews · ${average.toFixed(1)} average rating`}
    >
      <Card className="overflow-hidden">
        <div className="flex items-center gap-4 border-b border-border px-6 py-5">
          <div className="relative w-80">
            <Search className="absolute left-4 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
            <input
              className="se-input pl-11"
              placeholder="Search reviewer, product or text…"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
          <select
            className="se-input w-44"
            value={rating}
            onChange={(e) => setRating(e.target.value)}
          >
            <option value="all">All ratings</option>
            {[5, 4, 3, 2, 1].map((n) => (
              <option key={n} value={n}>
                {n} star{n > 1 ? "s" : ""}
              </option>
            ))}
          </select>
        </div>
        <table className="w-full">
          <thead className="bg-muted/60">
            <tr>
              <th className="se-th">Product</th>
              <th className="se-th">Reviewer</th>
              <th className="se-th">Rating</th>
              <th className="se-th">Date</th>
              <th className="se-th">Review</th>
              <th className="se-th">Helpful</th>
              <th className="se-th text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((r) => (
              <tr key={r.id} className="border-t border-border align-top">
                <td className="se-td max-w-56 font-medium">{productName(r.productId)}</td>
                <td className="se-td">
                  <div className="flex flex-col gap-1.5">
                    <span className="font-medium">{r.name}</span>
                    {r.verified ? <Chip tone="success">Verified purchase</Chip> : null}
                  </div>
                </td>
                <td className="se-td">
                  <Stars rating={r.rating} />
                </td>
                <td className="se-td text-muted-foreground">{formatDate(r.date)}</td>
                <td className="se-td max-w-96 text-muted-foreground">{r.text}</td>
                <td className="se-td text-muted-foreground">{r.helpfulCount}</td>
                <td className="se-td text-right">
                  <button
                    className="se-btn se-btn-outline se-btn-sm text-destructive"
                    onClick={() => setToDelete(r.id)}
                  >
                    <Trash2 className="size-4" />
                    Remove
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 ? <EmptyState message="No reviews match your filters." /> : null}
      </Card>

      <ConfirmDialog
        open={toDelete !== null}
        title="Remove review"
        message="This permanently removes the review from the storefront."
        confirmLabel="Remove review"
        onCancel={() => setToDelete(null)}
        onConfirm={() => {
          if (toDelete) deleteReview(toDelete);
          setToDelete(null);
        }}
      />
    </AdminShell>
  );
}