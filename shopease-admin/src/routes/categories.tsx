import { createFileRoute } from "@tanstack/react-router";
import { ChevronDown, ChevronRight, Pencil, Plus, Trash2 } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";
import { AdminShell } from "@/components/admin/AdminShell";
import { Card, ConfirmDialog, Field, Modal } from "@/components/admin/ui";
import { useAdminStore } from "@/lib/store";
import type { Category, Subcategory } from "@/lib/types";

export const Route = createFileRoute("/categories")({
  head: () => ({
    meta: [
      { title: "Categories — ShopEase Admin" },
      { name: "description", content: "Manage ShopEase categories and subcategories." },
      { property: "og:title", content: "Categories — ShopEase Admin" },
      { property: "og:description", content: "Manage ShopEase categories and subcategories." },
    ],
  }),
  component: CategoriesPage,
});

function CategoriesPage() {
  const {
    categories,
    subcategories,
    saveCategory,
    deleteCategory,
    saveSubcategory,
    deleteSubcategory,
  } = useAdminStore();
  const [expanded, setExpanded] = useState<string[]>([categories[0]?.id ?? ""]);
  const [editingCategory, setEditingCategory] = useState<Category | null>(null);
  const [editingSub, setEditingSub] = useState<Subcategory | null>(null);
  const [deleteCat, setDeleteCat] = useState<Category | null>(null);
  const [deleteSub, setDeleteSub] = useState<Subcategory | null>(null);

  const toggle = (id: string) =>
    setExpanded((prev) => (prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]));

  return (
    <AdminShell
      title="Categories"
      subtitle={`${categories.length} categories · ${subcategories.length} subcategories`}
      actions={
        <button
          className="se-btn se-btn-primary se-btn-sm"
          onClick={() =>
            setEditingCategory({
              id: `cat-${Date.now()}`,
              name: "",
              icon: "Tag",
              colorHex: "#FF6B6B",
              productCount: 0,
              imageUrl: "https://picsum.photos/seed/newcat/240/240",
              subcategories: [],
            })
          }
        >
          <Plus className="size-4" /> New category
        </button>
      }
    >
      <div className="space-y-4">
        {categories.map((c) => {
          const subs = subcategories.filter((s) => s.categoryId === c.id);
          const open = expanded.includes(c.id);
          return (
            <Card key={c.id} className="overflow-hidden">
              <div className="flex items-center gap-4 px-6 py-5">
                <button
                  onClick={() => toggle(c.id)}
                  className="rounded-full p-1 text-muted-foreground hover:bg-muted"
                  aria-label={open ? "Collapse" : "Expand"}
                >
                  {open ? <ChevronDown className="size-4" /> : <ChevronRight className="size-4" />}
                </button>
                <img src={c.imageUrl} alt={c.name} className="size-12 rounded-2xl object-cover" />
                <div className="flex-1">
                  <p className="font-semibold">{c.name}</p>
                  <p className="text-xs text-muted-foreground">
                    {c.icon} · {c.productCount} products · {subs.length} subcategories
                  </p>
                </div>
                <span className="flex items-center gap-2 text-xs font-medium text-muted-foreground">
                  <span
                    className="size-5 rounded-full border border-border"
                    style={{ background: c.colorHex }}
                  />
                  {c.colorHex}
                </span>
                <button
                  className="se-btn se-btn-outline se-btn-sm"
                  onClick={() =>
                    setEditingSub({
                      id: `sub-${Date.now()}`,
                      name: "",
                      categoryId: c.id,
                      imageUrl: "https://picsum.photos/seed/newsub/240/240",
                    })
                  }
                >
                  <Plus className="size-4" /> Subcategory
                </button>
                <button className="se-btn se-btn-outline se-btn-sm" onClick={() => setEditingCategory(c)}>
                  <Pencil className="size-4" />
                </button>
                <button
                  className="se-btn se-btn-outline se-btn-sm text-destructive"
                  onClick={() => setDeleteCat(c)}
                >
                  <Trash2 className="size-4" />
                </button>
              </div>
              {open ? (
                <div className="border-t border-border bg-muted/40 px-6 py-4">
                  {subs.length === 0 ? (
                    <p className="py-4 text-sm text-muted-foreground">No subcategories yet.</p>
                  ) : (
                    <div className="grid grid-cols-3 gap-4">
                      {subs.map((s) => (
                        <div
                          key={s.id}
                          className="flex items-center gap-3 rounded-2xl border border-border bg-card px-4 py-3"
                        >
                          <img src={s.imageUrl} alt={s.name} className="size-9 rounded-xl object-cover" />
                          <p className="flex-1 text-sm font-medium">{s.name}</p>
                          <button
                            className="rounded-full p-1.5 text-muted-foreground hover:bg-muted"
                            onClick={() => setEditingSub(s)}
                            aria-label={`Edit ${s.name}`}
                          >
                            <Pencil className="size-3.5" />
                          </button>
                          <button
                            className="rounded-full p-1.5 text-destructive hover:bg-muted"
                            onClick={() => setDeleteSub(s)}
                            aria-label={`Delete ${s.name}`}
                          >
                            <Trash2 className="size-3.5" />
                          </button>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              ) : null}
            </Card>
          );
        })}
      </div>

      {editingCategory ? (
        <CategoryForm
          category={editingCategory}
          onClose={() => setEditingCategory(null)}
          onSave={(c) => {
            saveCategory(c);
            setEditingCategory(null);
            toast.success("Category saved");
          }}
        />
      ) : null}

      {editingSub ? (
        <SubcategoryForm
          subcategory={editingSub}
          categories={categories}
          onClose={() => setEditingSub(null)}
          onSave={(s) => {
            saveSubcategory(s);
            setEditingSub(null);
            toast.success("Subcategory saved");
          }}
        />
      ) : null}

      <ConfirmDialog
        open={Boolean(deleteCat)}
        title="Delete category"
        message={`Delete "${deleteCat?.name}" and all of its subcategories?`}
        onCancel={() => setDeleteCat(null)}
        onConfirm={() => {
          if (deleteCat) deleteCategory(deleteCat.id);
          setDeleteCat(null);
          toast.success("Category deleted");
        }}
      />
      <ConfirmDialog
        open={Boolean(deleteSub)}
        title="Delete subcategory"
        message={`Delete "${deleteSub?.name}"?`}
        onCancel={() => setDeleteSub(null)}
        onConfirm={() => {
          if (deleteSub) deleteSubcategory(deleteSub.id);
          setDeleteSub(null);
          toast.success("Subcategory deleted");
        }}
      />
    </AdminShell>
  );
}

function CategoryForm({
  category,
  onClose,
  onSave,
}: {
  category: Category;
  onClose: () => void;
  onSave: (c: Category) => void;
}) {
  const [draft, setDraft] = useState(category);
  return (
    <Modal open onClose={onClose} title={category.name ? "Edit category" : "New category"} width="max-w-xl">
      <form
        className="space-y-5"
        onSubmit={(e) => {
          e.preventDefault();
          onSave(draft);
        }}
      >
        <Field label="Name">
          <input
            className="se-input"
            value={draft.name}
            onChange={(e) => setDraft({ ...draft, name: e.target.value })}
            required
          />
        </Field>
        <div className="grid grid-cols-2 gap-5">
          <Field label="Icon name">
            <input
              className="se-input"
              value={draft.icon}
              onChange={(e) => setDraft({ ...draft, icon: e.target.value })}
            />
          </Field>
          <Field label="Colour">
            <div className="flex items-center gap-3">
              <input
                type="color"
                className="size-11 rounded-[14px] border border-border bg-card"
                value={draft.colorHex}
                onChange={(e) => setDraft({ ...draft, colorHex: e.target.value })}
              />
              <input
                className="se-input"
                value={draft.colorHex}
                onChange={(e) => setDraft({ ...draft, colorHex: e.target.value })}
              />
            </div>
          </Field>
        </div>
        <Field label="Image">
          <div className="flex items-center gap-4">
            <img src={draft.imageUrl} alt="" className="size-16 rounded-2xl object-cover" />
            <input
              type="file"
              accept="image/*"
              className="se-input"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) setDraft({ ...draft, imageUrl: URL.createObjectURL(file) });
              }}
            />
          </div>
        </Field>
        <div className="flex justify-end gap-3">
          <button type="button" className="se-btn se-btn-outline se-btn-sm" onClick={onClose}>
            Cancel
          </button>
          <button className="se-btn se-btn-primary se-btn-sm">Save category</button>
        </div>
      </form>
    </Modal>
  );
}

function SubcategoryForm({
  subcategory,
  categories,
  onClose,
  onSave,
}: {
  subcategory: Subcategory;
  categories: Category[];
  onClose: () => void;
  onSave: (s: Subcategory) => void;
}) {
  const [draft, setDraft] = useState(subcategory);
  return (
    <Modal
      open
      onClose={onClose}
      title={subcategory.name ? "Edit subcategory" : "New subcategory"}
      width="max-w-lg"
    >
      <form
        className="space-y-5"
        onSubmit={(e) => {
          e.preventDefault();
          onSave(draft);
        }}
      >
        <Field label="Name">
          <input
            className="se-input"
            value={draft.name}
            onChange={(e) => setDraft({ ...draft, name: e.target.value })}
            required
          />
        </Field>
        <Field label="Parent category">
          <select
            className="se-input"
            value={draft.categoryId}
            onChange={(e) => setDraft({ ...draft, categoryId: e.target.value })}
          >
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
        </Field>
        <Field label="Image">
          <div className="flex items-center gap-4">
            <img src={draft.imageUrl} alt="" className="size-14 rounded-2xl object-cover" />
            <input
              type="file"
              accept="image/*"
              className="se-input"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) setDraft({ ...draft, imageUrl: URL.createObjectURL(file) });
              }}
            />
          </div>
        </Field>
        <div className="flex justify-end gap-3">
          <button type="button" className="se-btn se-btn-outline se-btn-sm" onClick={onClose}>
            Cancel
          </button>
          <button className="se-btn se-btn-primary se-btn-sm">Save subcategory</button>
        </div>
      </form>
    </Modal>
  );
}