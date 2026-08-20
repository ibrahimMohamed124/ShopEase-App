import { createFileRoute } from "@tanstack/react-router";
import { Pencil, Plus, Search, Trash2 } from "lucide-react";
import { useMemo, useState } from "react";
import { toast } from "sonner";
import { AdminShell } from "@/components/admin/AdminShell";
import {
  Card,
  Chip,
  ConfirmDialog,
  EmptyState,
  Field,
  Modal,
  Stars,
  StockChip,
  currency,
} from "@/components/admin/ui";
import { useAdminStore } from "@/lib/store";
import type { Product } from "@/lib/types";

export const Route = createFileRoute("/products")({
  head: () => ({
    meta: [
      { title: "Products — ShopEase Admin" },
      { name: "description", content: "Create, edit and manage the ShopEase product catalogue." },
      { property: "og:title", content: "Products — ShopEase Admin" },
      {
        property: "og:description",
        content: "Create, edit and manage the ShopEase product catalogue.",
      },
    ],
  }),
  component: ProductsPage,
});

const emptyProduct = (): Product => ({
  id: `prod-${Date.now()}`,
  name: "",
  price: 0,
  description: "",
  category: "",
  rating: 0,
  reviewCount: 0,
  imageUrl: "https://picsum.photos/seed/newproduct/240/240",
  inStock: true,
});

function ProductsPage() {
  const { products, categories, subcategories, saveProduct, deleteProduct } = useAdminStore();
  const [query, setQuery] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("all");
  const [stockFilter, setStockFilter] = useState("all");
  const [editing, setEditing] = useState<Product | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Product | null>(null);

  const filtered = useMemo(
    () =>
      products.filter((p) => {
        const matchesQuery = p.name.toLowerCase().includes(query.toLowerCase());
        const matchesCategory = categoryFilter === "all" || p.category === categoryFilter;
        const matchesStock =
          stockFilter === "all" ||
          (stockFilter === "in" && p.inStock) ||
          (stockFilter === "out" && !p.inStock);
        return matchesQuery && matchesCategory && matchesStock;
      }),
    [products, query, categoryFilter, stockFilter],
  );

  const categoryName = (id: string) => categories.find((c) => c.id === id)?.name ?? "—";

  return (
    <AdminShell
      title="Products"
      subtitle={`${products.length} products in the catalogue`}
      actions={
        <button className="se-btn se-btn-primary se-btn-sm" onClick={() => setEditing(emptyProduct())}>
          <Plus className="size-4" /> New product
        </button>
      }
    >
      <Card className="overflow-hidden">
        <div className="flex items-center gap-4 border-b border-border px-6 py-5">
          <div className="relative w-80">
            <Search className="absolute left-4 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
            <input
              className="se-input pl-11"
              placeholder="Search products…"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
          <select
            className="se-input w-52"
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
          >
            <option value="all">All categories</option>
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
          <select
            className="se-input w-44"
            value={stockFilter}
            onChange={(e) => setStockFilter(e.target.value)}
          >
            <option value="all">All stock</option>
            <option value="in">In stock</option>
            <option value="out">Out of stock</option>
          </select>
        </div>

        <table className="w-full">
          <thead className="bg-muted/60">
            <tr>
              <th className="se-th">Product</th>
              <th className="se-th">Category</th>
              <th className="se-th">Price</th>
              <th className="se-th">Rating</th>
              <th className="se-th">Stock</th>
              <th className="se-th">Badge</th>
              <th className="se-th text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((p) => (
              <tr key={p.id} className="border-t border-border">
                <td className="se-td">
                  <div className="flex items-center gap-3">
                    <img src={p.imageUrl} alt={p.name} className="size-11 rounded-xl object-cover" />
                    <div>
                      <p className="font-medium">{p.name}</p>
                      <p className="max-w-md truncate text-xs text-muted-foreground">
                        {p.description}
                      </p>
                    </div>
                  </div>
                </td>
                <td className="se-td text-muted-foreground">{categoryName(p.category)}</td>
                <td className="se-td">
                  <span className="font-semibold">{currency(p.price)}</span>
                  {p.originalPrice ? (
                    <span className="ml-2 text-xs text-muted-foreground line-through">
                      {currency(p.originalPrice)}
                    </span>
                  ) : null}
                </td>
                <td className="se-td">
                  <Stars rating={p.rating} />
                  <span className="ml-1 text-xs text-muted-foreground">({p.reviewCount})</span>
                </td>
                <td className="se-td">
                  <StockChip inStock={p.inStock} />
                </td>
                <td className="se-td">{p.badge ? <Chip tone="primary">{p.badge}</Chip> : "—"}</td>
                <td className="se-td">
                  <div className="flex justify-end gap-2">
                    <button
                      className="se-btn se-btn-outline se-btn-sm"
                      onClick={() => setEditing(p)}
                      aria-label={`Edit ${p.name}`}
                    >
                      <Pencil className="size-4" />
                    </button>
                    <button
                      className="se-btn se-btn-outline se-btn-sm text-destructive"
                      onClick={() => setDeleteTarget(p)}
                      aria-label={`Delete ${p.name}`}
                    >
                      <Trash2 className="size-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 ? <EmptyState message="No products match your filters." /> : null}
      </Card>

      {editing ? (
        <ProductForm
          product={editing}
          categories={categories.map((c) => ({ id: c.id, name: c.name }))}
          subcategories={subcategories}
          onClose={() => setEditing(null)}
          onSave={(p) => {
            saveProduct(p);
            setEditing(null);
            toast.success("Product saved");
          }}
        />
      ) : null}

      <ConfirmDialog
        open={Boolean(deleteTarget)}
        title="Delete product"
        message={`Delete "${deleteTarget?.name}"? This cannot be undone.`}
        onCancel={() => setDeleteTarget(null)}
        onConfirm={() => {
          if (deleteTarget) deleteProduct(deleteTarget.id);
          setDeleteTarget(null);
          toast.success("Product deleted");
        }}
      />
    </AdminShell>
  );
}

function ProductForm({
  product,
  categories,
  subcategories,
  onClose,
  onSave,
}: {
  product: Product;
  categories: { id: string; name: string }[];
  subcategories: { id: string; name: string; categoryId: string }[];
  onClose: () => void;
  onSave: (product: Product) => void;
}) {
  const [draft, setDraft] = useState<Product>(product);
  const set = <K extends keyof Product>(key: K, value: Product[K]) =>
    setDraft((prev) => ({ ...prev, [key]: value }));

  return (
    <Modal open onClose={onClose} title={product.name ? "Edit product" : "New product"}>
      <form
        className="space-y-5"
        onSubmit={(e) => {
          e.preventDefault();
          onSave(draft);
        }}
      >
        <div className="grid grid-cols-2 gap-5">
          <Field label="Name">
            <input
              className="se-input"
              value={draft.name}
              onChange={(e) => set("name", e.target.value)}
              required
            />
          </Field>
          <Field label="Badge (optional)">
            <input
              className="se-input"
              value={draft.badge ?? ""}
              placeholder="New, Sale, Bestseller…"
              onChange={(e) =>
                setDraft((prev) => {
                  const { badge: _drop, ...rest } = prev;
                  return e.target.value ? { ...rest, badge: e.target.value } : rest;
                })
              }
            />
          </Field>
        </div>
        <Field label="Description">
          <textarea
            className="se-input min-h-24"
            value={draft.description}
            onChange={(e) => set("description", e.target.value)}
          />
        </Field>
        <div className="grid grid-cols-2 gap-5">
          <Field label="Price">
            <input
              className="se-input"
              type="number"
              step="0.01"
              value={draft.price}
              onChange={(e) => set("price", Number(e.target.value))}
              required
            />
          </Field>
          <Field label="Original price (optional)">
            <input
              className="se-input"
              type="number"
              step="0.01"
              value={draft.originalPrice ?? ""}
              onChange={(e) =>
                setDraft((prev) => {
                  const { originalPrice: _drop, ...rest } = prev;
                  return e.target.value ? { ...rest, originalPrice: Number(e.target.value) } : rest;
                })
              }
            />
          </Field>
        </div>
        <div className="grid grid-cols-2 gap-5">
          <Field label="Category">
            <select
              className="se-input"
              value={draft.category}
              onChange={(e) => set("category", e.target.value)}
              required
            >
              <option value="">Select a category</option>
              {categories.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}
                </option>
              ))}
            </select>
          </Field>
          <Field label="Subcategory">
            <select
              className="se-input"
              value={draft.subcategory ?? ""}
              onChange={(e) =>
                setDraft((prev) => {
                  const { subcategory: _drop, ...rest } = prev;
                  return e.target.value ? { ...rest, subcategory: e.target.value } : rest;
                })
              }
            >
              <option value="">None</option>
              {subcategories
                .filter((s) => s.categoryId === draft.category)
                .map((s) => (
                  <option key={s.id} value={s.id}>
                    {s.name}
                  </option>
                ))}
            </select>
          </Field>
        </div>
        <Field label="Product image">
          <div className="flex items-center gap-4">
            <img src={draft.imageUrl} alt="" className="size-16 rounded-2xl object-cover" />
            <input
              type="file"
              accept="image/*"
              className="se-input"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) set("imageUrl", URL.createObjectURL(file));
              }}
            />
          </div>
        </Field>
        <label className="flex items-center gap-3 text-sm font-medium">
          <input
            type="checkbox"
            className="size-4 accent-[var(--primary)]"
            checked={draft.inStock}
            onChange={(e) => set("inStock", e.target.checked)}
          />
          In stock
        </label>
        <div className="flex justify-end gap-3 pt-2">
          <button type="button" className="se-btn se-btn-outline se-btn-sm" onClick={onClose}>
            Cancel
          </button>
          <button type="submit" className="se-btn se-btn-primary se-btn-sm">
            Save product
          </button>
        </div>
      </form>
    </Modal>
  );
}