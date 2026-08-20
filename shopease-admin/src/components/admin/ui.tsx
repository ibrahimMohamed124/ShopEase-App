import { Star } from "lucide-react";
import type { ReactNode } from "react";
import { cn } from "@/lib/utils";
import type { OrderStatus, ReturnStatus } from "@/lib/types";

export function Card({ className, children }: { className?: string; children: ReactNode }) {
  return <div className={cn("se-card", className)}>{children}</div>;
}

export function CardHeader({
  title,
  subtitle,
  action,
}: {
  title: string;
  subtitle?: string;
  action?: ReactNode;
}) {
  return (
    <div className="flex items-start justify-between gap-4 border-b border-border px-6 py-5">
      <div>
        <h2 className="text-base font-semibold text-foreground">{title}</h2>
        {subtitle ? <p className="mt-1 text-sm text-muted-foreground">{subtitle}</p> : null}
      </div>
      {action}
    </div>
  );
}

export function Chip({
  children,
  tone = "muted",
  className,
}: {
  children: ReactNode;
  tone?: "muted" | "primary" | "secondary" | "success" | "destructive" | "star";
  className?: string;
}) {
  const tones: Record<string, string> = {
    muted: "bg-muted text-muted-foreground",
    primary: "bg-primary/12 text-primary",
    secondary: "bg-secondary/12 text-secondary",
    success: "bg-success/12 text-success",
    destructive: "bg-destructive/12 text-destructive",
    star: "bg-star/15 text-star",
  };
  return <span className={cn("se-chip", tones[tone], className)}>{children}</span>;
}

const orderTone: Record<OrderStatus, "muted" | "secondary" | "success" | "destructive"> = {
  processing: "muted",
  shipped: "secondary",
  delivered: "success",
  cancelled: "destructive",
};

const orderLabel: Record<OrderStatus, string> = {
  processing: "Processing",
  shipped: "Shipped",
  delivered: "Delivered",
  cancelled: "Cancelled",
};

export function OrderStatusChip({ status }: { status: OrderStatus }) {
  return <Chip tone={orderTone[status]}>{orderLabel[status]}</Chip>;
}

const returnTone: Record<ReturnStatus, "muted" | "success" | "destructive"> = {
  inReview: "muted",
  refunded: "success",
  rejected: "destructive",
};
const returnLabel: Record<ReturnStatus, string> = {
  inReview: "In review",
  refunded: "Refunded",
  rejected: "Rejected",
};

export function ReturnStatusChip({ status }: { status: ReturnStatus }) {
  return <Chip tone={returnTone[status]}>{returnLabel[status]}</Chip>;
}

export function StockChip({ inStock }: { inStock: boolean }) {
  return <Chip tone={inStock ? "success" : "destructive"}>{inStock ? "In stock" : "Out of stock"}</Chip>;
}

export function Stars({ rating, showValue = true }: { rating: number; showValue?: boolean }) {
  return (
    <span className="inline-flex items-center gap-1">
      {[1, 2, 3, 4, 5].map((i) => (
        <Star
          key={i}
          className={cn("size-3.5", i <= Math.round(rating) ? "fill-star text-star" : "text-border")}
        />
      ))}
      {showValue ? (
        <span className="ml-1 text-xs font-semibold text-muted-foreground">{rating.toFixed(1)}</span>
      ) : null}
    </span>
  );
}

export function Modal({
  open,
  onClose,
  title,
  children,
  width = "max-w-2xl",
}: {
  open: boolean;
  onClose: () => void;
  title: string;
  children: ReactNode;
  width?: string;
}) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-foreground/25 p-8">
      <div className={cn("w-full overflow-hidden rounded-2xl border border-border bg-card", width)}>
        <div className="flex items-center justify-between border-b border-border px-6 py-5">
          <h3 className="text-base font-semibold">{title}</h3>
          <button
            onClick={onClose}
            className="rounded-full px-3 py-1 text-sm text-muted-foreground hover:bg-muted"
          >
            Close
          </button>
        </div>
        <div className="max-h-[70vh] overflow-y-auto p-6">{children}</div>
      </div>
    </div>
  );
}

export function ConfirmDialog({
  open,
  title,
  message,
  confirmLabel = "Delete",
  onConfirm,
  onCancel,
}: {
  open: boolean;
  title: string;
  message: string;
  confirmLabel?: string;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return (
    <Modal open={open} onClose={onCancel} title={title} width="max-w-md">
      <p className="text-sm text-muted-foreground">{message}</p>
      <div className="mt-6 flex justify-end gap-3">
        <button className="se-btn se-btn-outline se-btn-sm" onClick={onCancel}>
          Cancel
        </button>
        <button className="se-btn se-btn-danger se-btn-sm" onClick={onConfirm}>
          {confirmLabel}
        </button>
      </div>
    </Modal>
  );
}

export function Field({ label, children }: { label: string; children: ReactNode }) {
  return (
    <label className="block">
      <span className="mb-2 block text-xs font-semibold text-muted-foreground">{label}</span>
      {children}
    </label>
  );
}

export function EmptyState({ message }: { message: string }) {
  return <div className="px-6 py-16 text-center text-sm text-muted-foreground">{message}</div>;
}

export const currency = (value: number) =>
  value.toLocaleString("en-US", { style: "currency", currency: "USD" });

export const formatDate = (iso: string) =>
  new Date(iso).toLocaleDateString("en-US", { day: "2-digit", month: "short", year: "numeric" });